//
//  ChatMessageCell.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI
import Firebase
import Kingfisher

struct ChatMessageCell: View {
    let message: Message
    var nextMessage: Message?
    var prevMessage: Message?
    
    init(message: Message, nextMessage: Message?, prevMessage: Message?) {
        self.message = message
        self.nextMessage = nextMessage
        self.prevMessage = prevMessage
    }
    
    private var shouldShowChatPartnerImage: Bool {
        if nextMessage == nil && !message.isFromCurrentUser { return true }
        guard let next = nextMessage else { return message.isFromCurrentUser }
        return next.fromUserId != message.fromUserId
    }
    
    private var shouldShowChatPartnerName: Bool {
        guard let prev = prevMessage else { return true }
        return prev.fromUserId != message.fromUserId
    }
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
                
                if let imageUrl = message.imageUrl {
                    MessageImageView(imageUrlString: imageUrl)
                } else {
                    Text(message.messageText)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                        .padding(.horizontal)
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                }
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    if shouldShowChatPartnerImage {
                        CircularProfileImageView(user: message.user, size: .xxSmall)
                    }
                    
                    if let imageUrl = message.imageUrl {
                        MessageImageView(imageUrlString: imageUrl)

                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            if shouldShowChatPartnerName {
                                Text(message.user!.username)
                                    .font(.caption)
                                    .foregroundColor(Color.theme.secondaryText)
                                    .padding(.leading, shouldShowChatPartnerImage ? 12 : 44)
                            }
                            
                            Text(message.messageText)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .foregroundColor(Color.theme.primaryText)
                                .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}

struct MessageImageView: View {
    let imageUrlString: String
    
    var body: some View {
        KFImage(URL(string: imageUrlString))
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
            .cornerRadius(10)
            .padding(.trailing)
    }
}

//struct ChatMessageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatMessageCell(isFromCurrentUser: true)
//    }
//}
