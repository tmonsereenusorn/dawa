import firebase_admin
from firebase_admin import firestore, messaging
from firebase_admin.messaging import APNSConfig, APNSPayload, Aps, Message, Notification  # Add this line
from firebase_functions import firestore_fn
from google.cloud.firestore_v1.base_query import FieldFilter

# Initialize Firebase Admin SDK if not already initialized
if not firebase_admin._apps:
    firebase_admin.initialize_app()

def get_firestore_client():
    return firestore.client()

def get_apns_config(thread_id):
    return APNSConfig(
        payload=APNSPayload(
            aps=Aps(
                sound='default',
                thread_id=thread_id
            )
        )
    )

@firestore_fn.on_document_updated(document="users/{userId}/user-activities/{activityId}")
def send_dm_notification(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot]]) -> None:
    db = get_firestore_client()

    before_data = event.data.before.to_dict() if event.data.before else {}
    after_data = event.data.after.to_dict() if event.data.after else {}

    if before_data.get('recentMessageId') == after_data.get('recentMessageId'):
        return

    user_id, activity_id = event.params['userId'], event.params['activityId']
    
    activity_ref = db.collection('activities').document(activity_id)
    
    recent_message_id = after_data.get('recentMessageId')
    message_doc = activity_ref.collection('messages').document(recent_message_id).get()

    if not message_doc.exists:
        print(f"Message document not found: {recent_message_id}")
        return

    message_data = message_doc.to_dict()
    from_user_id = message_data.get('fromUserId')

    # Move this check here, right after we have the necessary information
    if from_user_id == user_id:
        print(f"Skipping notification as the sender and receiver are the same: {user_id}")
        return

    message_type = message_data.get('messageType')

    if message_type == "system":
        print(f"Skipping notification for system message: {user_id}")
        return

    user_ref = db.collection('users').document(user_id)
    
    user_doc = user_ref.get()
    activity_doc = activity_ref.get()

    if not (user_doc.exists and activity_doc.exists):
        print(f"User or Activity document not found: {user_id}, {activity_id}")
        return

    user_data = user_doc.to_dict()
    fcm_tokens = user_data.get('fcmTokens', [])
    
    if not fcm_tokens:
        print(f"No FCM tokens for user: {user_id}")
        return

    from_user_doc = db.collection('users').document(from_user_id).get()

    if not from_user_doc.exists:
        print(f"Sender document not found")
        return

    # Build notification content
    sender_username = from_user_doc.to_dict().get('username', 'Unknown User')
    notification_body = f"{sender_username}: {message_data.get('messageText', 'No Message Text')}"
    notification_title = f"{activity_doc.to_dict().get('title', 'Unidentified Activity')}"

    invalid_tokens = []
    for token_info in fcm_tokens:
        if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
            print(f"Invalid token format: {token_info}")
            invalid_tokens.append(token_info)
            continue

        token = token_info['token']
        device_id = token_info['deviceId']

        message = Message(
            notification=Notification(
                title=notification_title,
                body=notification_body
            ),
            apns=get_apns_config(f'{activity_id}'),  # Grouping DM notifications separately
            data={
                'activityId': activity_id
            },
            token=token
        )
        try:
            response = messaging.send(message)
            print(f"Sent message to device {device_id} with token {token}: {response}")
        except Exception as e:
            print(f"Error sending to device {device_id} with token {token}: {str(e)}")
            if isinstance(e, messaging.ApiCallError) and e.code == 'messaging/registration-token-not-registered':
                invalid_tokens.append(token_info)

    if invalid_tokens:
        user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
        print(f"Removed invalid tokens: {invalid_tokens}")

@firestore_fn.on_document_created(document="activities/{activityId}/participants/{participantId}")
def send_participant_joined_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    db = get_firestore_client()

    activity_id = event.params['activityId']
    participant_id = event.params['participantId']
    
    activity_ref = db.collection('activities').document(activity_id)
    activity_doc = activity_ref.get()

    if not activity_doc.exists:
        print(f"Activity document not found: {activity_id}")
        return

    activity_data = activity_doc.to_dict()
    activity_title = activity_data.get('title', 'Activity')

    # Fetch the participant's user data
    participant_user_ref = db.collection('users').document(participant_id)
    participant_user_doc = participant_user_ref.get()

    if not participant_user_doc.exists:
        print(f"User document not found: {participant_id}")
        return

    participant_user_data = participant_user_doc.to_dict()
    participant_username = participant_user_data.get('username', 'Unknown User')

    notification_body = f"{participant_username} has joined the activity."

    # Get all participants of the activity
    participants_ref = activity_ref.collection('participants')
    participants_docs = participants_ref.stream()

    for participant_doc in participants_docs:
        participant_data = participant_doc.to_dict()
        user_id = participant_doc.id

        if user_id == participant_id:
            continue

        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()

        if not user_doc.exists:
            print(f"User document not found for participant: {user_id}")
            continue

        user_data = user_doc.to_dict()
        fcm_tokens = user_data.get('fcmTokens', [])

        if not fcm_tokens:
            print(f"No FCM tokens for user: {user_id}")
            continue

        invalid_tokens = []
        for token_info in fcm_tokens:
            if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
                print(f"Invalid token format: {token_info}")
                invalid_tokens.append(token_info)
                continue

            token = token_info['token']
            device_id = token_info['deviceId']

            message = messaging.Message(
                notification=messaging.Notification(
                    title=f"{activity_title}",
                    body=notification_body
                ),
                apns=get_apns_config(f'{activity_id}'),
                data={
                    'activityId': activity_id
                },
                token=token
            )
            try:
                response = messaging.send(message)
                print(f"Sent message to device {device_id} with token {token}: {response}")
            except Exception as e:
                print(f"Error sending to device {device_id} with token {token}: {str(e)}")
                if isinstance(e, messaging.ApiCallError) and e.code == 'messaging/registration-token-not-registered':
                    invalid_tokens.append(token_info)

        if invalid_tokens:
            user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
            print(f"Removed invalid tokens: {invalid_tokens}")

@firestore_fn.on_document_deleted(document="activities/{activityId}/participants/{participantId}")
def send_participant_left_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    db = get_firestore_client()

    activity_id = event.params['activityId']
    participant_id = event.params['participantId']

    activity_ref = db.collection('activities').document(activity_id)
    activity_doc = activity_ref.get()

    if not activity_doc.exists:
        print(f"Activity document not found: {activity_id}")
        return

    activity_data = activity_doc.to_dict()
    activity_title = activity_data.get('title', 'Activity')

    # Fetch the participant's user data
    participant_user_ref = db.collection('users').document(participant_id)
    participant_user_doc = participant_user_ref.get()

    if not participant_user_doc.exists:
        print(f"User document not found: {participant_id}")
        return

    participant_user_data = participant_user_doc.to_dict()
    participant_username = participant_user_data.get('username', 'Unknown User')

    notification_body = f"{participant_username} has left the activity."

    # Get all participants of the activity
    participants_ref = activity_ref.collection('participants')
    participants_docs = participants_ref.stream()

    for participant_doc in participants_docs:
        participant_data = participant_doc.to_dict()
        user_id = participant_doc.id

        if user_id == participant_id:
            continue

        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()

        if not user_doc.exists:
            print(f"User document not found for participant: {user_id}")
            continue

        user_data = user_doc.to_dict()
        fcm_tokens = user_data.get('fcmTokens', [])

        if not fcm_tokens:
            print(f"No FCM tokens for user: {user_id}")
            continue

        invalid_tokens = []
        for token_info in fcm_tokens:
            if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
                print(f"Invalid token format: {token_info}")
                invalid_tokens.append(token_info)
                continue

            token = token_info['token']
            device_id = token_info['deviceId']

            message = messaging.Message(
                notification=messaging.Notification(
                    title=f"{activity_title}",
                    body=notification_body
                ),
                apns=get_apns_config(f'{activity_id}'),
                data={
                    'activityId': activity_id
                },
                token=token
            )
            try:
                response = messaging.send(message)
                print(f"Sent message to device {device_id} with token {token}: {response}")
            except Exception as e:
                print(f"Error sending to device {device_id} with token {token}: {str(e)}")
                if isinstance(e, messaging.ApiCallError) and e.code == 'messaging/registration-token-not-registered':
                    invalid_tokens.append(token_info)

        if invalid_tokens:
            user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
            print(f"Removed invalid tokens: {invalid_tokens}")
