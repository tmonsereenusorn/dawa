//
//  GroupView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/18/23.
//

import SwiftUI

struct GroupView: View {
    @Environment(\.presentationMode) var mode
    @State private var group: Groups
    
    init(group: Groups) {
        _group = State(initialValue: group)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(Color.theme.primaryText)
                        .offset(x: 16, y: 12)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Edit Group")
                        .font(.subheadline).bold()
                        .frame(width: 120, height: 32)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                        .foregroundColor(Color.theme.primaryText)
                }
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    SquareGroupImageView(size: .medium)
                    
                    Text(group.name)
                        .foregroundColor(Color.theme.primaryText)
                    
                }
                Spacer()
            }
            
            Spacer()
            
            
        }
        .padding()
        .navigationBarHidden(true)
        .background(Color.theme.background)
    }
}

#Preview {
    GroupView(group: Groups.MOCK_GROUP)
}
