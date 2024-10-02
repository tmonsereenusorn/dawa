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
        .onDisappear {
            viewModel.removeChatListener()
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
    }
}

struct ChatContent: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        if viewModel.messages.isEmpty {
            EmptyMessagesView()
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            MessageCell(message: viewModel.messages[index],
                                        nextMessage: viewModel.nextMessage(forIndex: index),
                                        prevMessage: viewModel.prevMessage(forIndex: index))
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear { scrollToBottom(proxy: proxy) }
                .onChange(of: viewModel.messages) { _ in scrollToBottom(proxy: proxy) }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation(.spring()) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
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
        if message.messageType == .system {
            SystemMessageCell(message: message)
        } else {
            ChatMessageCell(message: message, nextMessage: nextMessage, prevMessage: prevMessage)
        }
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
