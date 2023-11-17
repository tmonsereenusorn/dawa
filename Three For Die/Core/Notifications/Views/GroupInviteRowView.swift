//
//  GroupInviteRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import SwiftUI

struct GroupInviteRowView: View {
    let groupInvite: GroupInvite
    
    var body: some View {
        if let group = groupInvite.group {
            HStack {
                SquareGroupImageView(group: group, size: .medium)
                
                Text("\(group.name)")
                    .foregroundColor(Color.theme.primaryText)
                
                Spacer()
                
                Button("Confirm") {
                    // Action to perform when the button is tapped
                }
                .padding()
                .foregroundColor(.white) // Text color
                .background(Color.blue) // System blue background
                .cornerRadius(10) // Rounded corners
                
                Button("Delete") {
                    // Action to perform when the button is tapped
                }
                .padding()
                .foregroundColor(.white) // Text color
                .background(Color.theme.secondaryBackground) // System blue background
                .cornerRadius(10) // Rounded corners
            }
        }
    }
}

//#Preview {
//    GroupInviteRowView()
//}
