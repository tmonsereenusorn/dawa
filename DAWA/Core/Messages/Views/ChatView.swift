//
//  ChatView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @Environment(\.presentationMode) var mode
    @State private var messageText = ""
    @State private var navigateToActivityView = false
    @State private var isRemovedFromActivity = false
    @StateObject var viewModel: ChatViewModel
    private let activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
        self._viewModel = StateObject(wrappedValue: ChatViewModel(activity: activity))
    }
    
    var body: some View {
        VStack {
            if isRemovedFromActivity {
                // Show a message when the user has been removed from the activity
                VStack {
                    Text("You have been removed from this activity and can no longer participate in the chat.")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Back to Activity Feed") {
                        mode.wrappedValue.dismiss()
                    }
                    .padding()
                }
            } else {
                // Normal chat UI
                ChatContent(viewModel: viewModel)
                MessageInputView(messageText: $messageText, viewModel: viewModel)
                    .disabled(isRemovedFromActivity)  // Disable message input if removed
            }
        }
        .navigationTitle(activity.title)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(mode: mode)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(navigateToActivityView: $navigateToActivityView)
            }
        }
        .navigationDestination(isPresented: $navigateToActivityView) {
            ActivityView(activity: activity)
        }
        .tint(Color.theme.primaryText)
        .onAppear {
            PushNotificationHandler.shared.currentChatActivityId = activity.id
            listenForParticipantChanges()  // Start listening for participant changes
        }
        .onDisappear {
            PushNotificationHandler.shared.currentChatActivityId = nil
            viewModel.removeChatListener()
        }
    }
    
    // Listen for participant changes
    private func listenForParticipantChanges() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let participantsRef = FirestoreConstants.ActivitiesCollection.document(activity.id).collection("participants")
            
            // Set up a Firestore listener to detect participant removal in real-time
            participantsRef.document(uid).addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for participant changes: \(error)")
                    return
                }
                
                // If the document no longer exists, the user has been removed
                if snapshot?.exists == false {
                    DispatchQueue.main.async {
                        self.isRemovedFromActivity = true  // User is no longer a participant
                    }
                }
            }
        }
    }
}

struct ChatContent: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if viewModel.messages.isEmpty {
                    VStack {
                        EmptyMessagesView()
                    }
                    .frame(minHeight: UIScreen.main.bounds.height - 200)
                } else {
                    ZStack {
                        Color.theme.appBackground
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                UIApplication.shared.dismissKeyboard()
                            }
                        
                        VStack {
                            ForEach(viewModel.messages) { message in
                                MessageCell(message: message,
                                            nextMessage: viewModel.nextMessage(forIndex: viewModel.messages.firstIndex(of: message) ?? 0),
                                            prevMessage: viewModel.prevMessage(forIndex: viewModel.messages.firstIndex(of: message) ?? 0))
                            }
                        }
                        .padding(.vertical)
                    }
                }
                Color.clear.frame(height: 1).id("bottomAnchor")
            }
            .onChange(of: viewModel.messages) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo("bottomAnchor", anchor: .bottom)
            }
        }
    }
}

struct EmptyMessagesView: View {
    var body: some View {
        Spacer()
        VStack(spacing: 8) {
            Text("No messages yet.")
                .font(.system(size: 24, weight: .semibold))
            Text("Start a conversation!")
                .font(.system(size: 20, weight: .regular))
        }
        .foregroundColor(Color.theme.secondaryText)
        .multilineTextAlignment(.center)
        .padding()
        Spacer()
    }
}

struct MessageCell: View {
    let message: Message
    var nextMessage: Message?
    var prevMessage: Message?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if shouldShowTimestamp(for: message, comparedTo: prevMessage) {
                // Display the formatted timestamp
                Text(message.timestamp.dateValue().formattedDisplay())
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
            }
            
            if message.messageType == .system {
                SystemMessageCell(message: message)
            } else {
                ChatMessageCell(message: message, nextMessage: nextMessage, prevMessage: prevMessage)
            }
        }
    }
    
    private func shouldShowTimestamp(for message: Message, comparedTo prevMessage: Message?) -> Bool {
        guard let prevMessage = prevMessage else {
            // Show timestamp for the first message
            return true
        }
        
        let messageDate = message.timestamp.dateValue()
        let prevMessageDate = prevMessage.timestamp.dateValue()
        let timeInterval = messageDate.timeIntervalSince(prevMessageDate)
        
        // Show the timestamp if the time difference is greater than 20 minutes (1200 seconds)
        return timeInterval > 20 * 60
    }
}

struct BackButton: View {
    @Binding var mode: PresentationMode
    
    var body: some View {
        Button {
            $mode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .imageScale(.large)
        }
    }
}

struct InfoButton: View {
    @Binding var navigateToActivityView: Bool
    
    var body: some View {
        Button(action: {
            navigateToActivityView = true
        }) {
            Image(systemName: "info.circle")
                .imageScale(.large)
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
