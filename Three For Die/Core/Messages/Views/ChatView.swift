//
//  ChatView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    let activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
        self._viewModel = StateObject(wrappedValue: ChatViewModel(activity: activity))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    ChatMessageCell(message: message)
                }
            }
            Spacer()
            // Message input view
            ZStack(alignment: .trailing) {
                TextField("Message...", text: $viewModel.messageText, axis: .vertical)
                    .padding(12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
