import firebase_admin
from firebase_admin import firestore, messaging
from firebase_admin.messaging import APNSConfig, APNSPayload, Aps, Message, MulticastMessage, Notification
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

    if from_user_id == user_id:
        print(f"Skipping notification as the sender and receiver are the same: {user_id}")
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

@firestore_fn.on_document_created(document="activities/{activityId}")
def send_group_activity_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    db = get_firestore_client()
    
    activity_data = event.data.to_dict()
    if not activity_data:
        print(f"No activity data found.")
        return
    
    group_id = activity_data.get('groupId')
    activity_title = activity_data.get('title', 'Activity')
    creator_user_id = activity_data.get('userId')  # Assuming the creator's userId is stored here
    if not group_id:
        print(f"Activity does not have a groupId field.")
        return

    group_doc = db.collection('groups').document(group_id).get()
    if not group_doc.exists:
        print(f"Group document not found for groupId: {group_id}")
        return

    group_data = group_doc.to_dict()
    group_name = group_data.get('name', 'Group')

    group_members_ref = db.collection('groups').document(group_id).collection('members')
    members_with_notifications_enabled = group_members_ref.where('notificationsEnabled', '==', True).stream()

    tokens_to_notify = []
    invalid_tokens = []
    for member_doc in members_with_notifications_enabled:
        user_id = member_doc.id

        # Skip sending notification to the creator of the activity
        if user_id == creator_user_id:
            continue

        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            fcm_tokens = user_data.get('fcmTokens', [])
            
            for token_info in fcm_tokens:
                if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
                    print(f"Invalid token format: {token_info}")
                    invalid_tokens.append(token_info)
                    continue

                token = token_info['token']
                tokens_to_notify.append(token)
        else:
            print(f"User document not found for user: {user_id}")

    if not tokens_to_notify:
        print("No FCM tokens found for users with notifications enabled.")
        return

    notification_title = group_name
    notification_body = f"New activity posted: {activity_title}"

    apns_config = get_apns_config(thread_id=group_id)

    multicast_message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=notification_title,
            body=notification_body,
        ),
        apns=apns_config,
        tokens=tokens_to_notify
    )

    try:
        response = messaging.send_each_for_multicast(multicast_message)
        print(f"Successfully sent {response.success_count} messages. Failed {response.failure_count} messages.")
        
        # If there are invalid tokens, remove them from Firestore
        if invalid_tokens:
            for member_doc in members_with_notifications_enabled:
                user_ref = db.collection('users').document(member_doc.id)
                user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
            print(f"Removed invalid tokens: {invalid_tokens}")

    except Exception as e:
        print(f"Error sending notifications: {str(e)}")

@firestore_fn.on_document_created(document="users/{userId}/group-invites/{inviteId}")
def send_group_invitation_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    db = get_firestore_client()

    invite_data = event.data.to_dict()
    if not invite_data:
        print(f"No invite data found.")
        return

    to_user_id = invite_data.get('toUserId')
    from_user_id = invite_data.get('fromUserId')
    for_group_id = invite_data.get('forGroupId')

    if not to_user_id or not from_user_id or not for_group_id:
        print(f"Invalid invite data: {invite_data}")
        return

    # Fetch the group document
    group_ref = db.collection('groups').document(for_group_id)
    group_doc = group_ref.get()

    if not group_doc.exists:
        print(f"Group document not found: {for_group_id}")
        return

    group_data = group_doc.to_dict()
    group_name = group_data.get('name', 'Unknown Group')

    # Fetch the receiver's user document
    to_user_ref = db.collection('users').document(to_user_id)
    to_user_doc = to_user_ref.get()

    if not to_user_doc.exists:
        print(f"User document not found for: {to_user_id}")
        return

    to_user_data = to_user_doc.to_dict()
    fcm_tokens = to_user_data.get('fcmTokens', [])

    if not fcm_tokens:
        print(f"No FCM tokens for user: {to_user_id}")
        return

    # Fetch the sender's username
    from_user_ref = db.collection('users').document(from_user_id)
    from_user_doc = from_user_ref.get()

    if not from_user_doc.exists:
        print(f"Sender document not found for: {from_user_id}")
        return

    from_user_data = from_user_doc.to_dict()
    sender_username = from_user_data.get('username', 'Unknown User')

    notification_title = "Group Invitation"
    notification_body = f"{sender_username} has invited you to join the group: {group_name}"

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
            apns=get_apns_config(f'group-invitation'),
            data={
                'forGroupId': for_group_id,
                'inviteId': event.params['inviteId']
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
        to_user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
        print(f"Removed invalid tokens: {invalid_tokens}")

# @firestore_fn.on_document_created(document="activities/{activityId}/participants/{participantId}")
# def send_participant_joined_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
#     db = get_firestore_client()

#     activity_id = event.params['activityId']
#     participant_id = event.params['participantId']
    
#     activity_ref = db.collection('activities').document(activity_id)
#     activity_doc = activity_ref.get()

#     if not activity_doc.exists:
#         print(f"Activity document not found: {activity_id}")
#         return

#     activity_data = activity_doc.to_dict()
#     activity_title = activity_data.get('title', 'Activity')

#     # Fetch the participant's user data
#     participant_user_ref = db.collection('users').document(participant_id)
#     participant_user_doc = participant_user_ref.get()

#     if not participant_user_doc.exists:
#         print(f"User document not found: {participant_id}")
#         return

#     participant_user_data = participant_user_doc.to_dict()
#     participant_username = participant_user_data.get('username', 'Unknown User')

#     notification_body = f"{participant_username} has joined the activity."

#     # Get all participants of the activity
#     participants_ref = activity_ref.collection('participants')
#     participants_docs = participants_ref.stream()

#     for participant_doc in participants_docs:
#         participant_data = participant_doc.to_dict()
#         user_id = participant_doc.id

#         if user_id == participant_id:
#             continue

#         user_ref = db.collection('users').document(user_id)
#         user_doc = user_ref.get()

#         if not user_doc.exists:
#             print(f"User document not found for participant: {user_id}")
#             continue

#         user_data = user_doc.to_dict()
#         fcm_tokens = user_data.get('fcmTokens', [])

#         if not fcm_tokens:
#             print(f"No FCM tokens for user: {user_id}")
#             continue

#         invalid_tokens = []
#         for token_info in fcm_tokens:
#             if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
#                 print(f"Invalid token format: {token_info}")
#                 invalid_tokens.append(token_info)
#                 continue

#             token = token_info['token']
#             device_id = token_info['deviceId']

#             message = messaging.Message(
#                 notification=messaging.Notification(
#                     title=f"{activity_title}",
#                     body=notification_body
#                 ),
#                 apns=get_apns_config(f'{activity_id}'),
#                 data={
#                     'activityId': activity_id
#                 },
#                 token=token
#             )
#             try:
#                 response = messaging.send(message)
#                 print(f"Sent message to device {device_id} with token {token}: {response}")
#             except Exception as e:
#                 print(f"Error sending to device {device_id} with token {token}: {str(e)}")
#                 if isinstance(e, messaging.ApiCallError) and e.code == 'messaging/registration-token-not-registered':
#                     invalid_tokens.append(token_info)

#         if invalid_tokens:
#             user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
#             print(f"Removed invalid tokens: {invalid_tokens}")

# @firestore_fn.on_document_deleted(document="activities/{activityId}/participants/{participantId}")
# def send_participant_left_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
#     db = get_firestore_client()

#     activity_id = event.params['activityId']
#     participant_id = event.params['participantId']

#     activity_ref = db.collection('activities').document(activity_id)
#     activity_doc = activity_ref.get()

#     if not activity_doc.exists:
#         print(f"Activity document not found: {activity_id}")
#         return

#     activity_data = activity_doc.to_dict()
#     activity_title = activity_data.get('title', 'Activity')

#     # Fetch the participant's user data
#     participant_user_ref = db.collection('users').document(participant_id)
#     participant_user_doc = participant_user_ref.get()

#     if not participant_user_doc.exists:
#         print(f"User document not found: {participant_id}")
#         return

#     participant_user_data = participant_user_doc.to_dict()
#     participant_username = participant_user_data.get('username', 'Unknown User')

#     notification_body = f"{participant_username} has left the activity."

#     # Get all participants of the activity
#     participants_ref = activity_ref.collection('participants')
#     participants_docs = participants_ref.stream()

#     for participant_doc in participants_docs:
#         participant_data = participant_doc.to_dict()
#         user_id = participant_doc.id

#         if user_id == participant_id:
#             continue

#         user_ref = db.collection('users').document(user_id)
#         user_doc = user_ref.get()

#         if not user_doc.exists:
#             print(f"User document not found for participant: {user_id}")
#             continue

#         user_data = user_doc.to_dict()
#         fcm_tokens = user_data.get('fcmTokens', [])

#         if not fcm_tokens:
#             print(f"No FCM tokens for user: {user_id}")
#             continue

#         invalid_tokens = []
#         for token_info in fcm_tokens:
#             if not isinstance(token_info, dict) or 'token' not in token_info or 'deviceId' not in token_info:
#                 print(f"Invalid token format: {token_info}")
#                 invalid_tokens.append(token_info)
#                 continue

#             token = token_info['token']
#             device_id = token_info['deviceId']

#             message = messaging.Message(
#                 notification=messaging.Notification(
#                     title=f"{activity_title}",
#                     body=notification_body
#                 ),
#                 apns=get_apns_config(f'{activity_id}'),
#                 data={
#                     'activityId': activity_id
#                 },
#                 token=token
#             )
#             try:
#                 response = messaging.send(message)
#                 print(f"Sent message to device {device_id} with token {token}: {response}")
#             except Exception as e:
#                 print(f"Error sending to device {device_id} with token {token}: {str(e)}")
#                 if isinstance(e, messaging.ApiCallError) and e.code == 'messaging/registration-token-not-registered':
#                     invalid_tokens.append(token_info)

#         if invalid_tokens:
#             user_ref.update({'fcmTokens': firestore.ArrayRemove(invalid_tokens)})
#             print(f"Removed invalid tokens: {invalid_tokens}")
