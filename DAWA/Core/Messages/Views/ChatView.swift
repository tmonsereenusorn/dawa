//
//  ChatView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var mode
    @State private var messageText = ""
    @State private var navigateToActivityView = false
    @StateObject var viewModel: ChatViewModel
    private let activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
        self._viewModel = StateObject(wrappedValue: ChatViewModel(activity: activity))
    }
    
    var body: some View {
        VStack {
            ChatContent(viewModel: viewModel)
            
            MessageInputView(messageText: $messageText, viewModel: viewModel)
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
        }
        .onDisappear {
            PushNotificationHandler.shared.currentChatActivityId = nil
            viewModel.removeChatListener()
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
                    VStack {
                        ForEach(viewModel.messages) { message in
                            MessageCell(message: message,
                                        nextMessage: viewModel.nextMessage(forIndex: viewModel.messages.firstIndex(of: message) ?? 0),
                                        prevMessage: viewModel.prevMessage(forIndex: viewModel.messages.firstIndex(of: message) ?? 0))
                        }
                    }
                    .padding(.vertical)
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
