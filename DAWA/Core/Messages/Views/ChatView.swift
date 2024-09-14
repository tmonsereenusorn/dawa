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
            if viewModel.messages.isEmpty {
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
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages.indices, id: \.self) { index in
                                ChatMessageCell(message: viewModel.messages[index],
                                                nextMessage: viewModel.nextMessage(forIndex: index),
                                                prevMessage: viewModel.prevMessage(forIndex: index))
                                    .id(viewModel.messages[index].id) // Unique ID for scrolling
                            }
                        }
                        .padding(.vertical)
                    }
                    .onAppear {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.spring()) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.spring()) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
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
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    navigateToActivityView = true
                }) {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToActivityView) {
            ActivityView(activity: activity)
        }
        .tint(Color.theme.primaryText)
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
