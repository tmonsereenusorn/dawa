//
//  ChatBubble.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct ChatBubble: Shape {
    var isFromCurrentUser: Bool
    var shouldRoundAllCorners: Bool
    
    var corners: UIRectCorner {
        if shouldRoundAllCorners {
            return [.allCorners]
        } else {
            return [
                .topLeft,
                .topRight,
                isFromCurrentUser ? .bottomLeft : .bottomRight
            ]
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        return Path(path.cgPath)
    }
}

//struct ChatBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: true)
//    }
//}
