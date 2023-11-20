//
//  EditGroupView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/21/23.
//

import SwiftUI
import PhotosUI

struct EditGroupView: View {
    @State private var name = ""
    @State private var handle = ""
    @StateObject var viewModel = EditGroupViewModel()
    @Binding var group: Groups
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        VStack {
            headerView
            
            groupImageInput
            
            groupNameInput
            
            Spacer()
        }
        .onAppear {
            self.name = group.name
            self.handle = group.handle
        }
    }
}

extension EditGroupView{
    var headerView: some View {
        HStack(alignment: .bottom) {
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
            
            Spacer()
            
            Text("Edit Group")
                .foregroundColor(Color.theme.primaryText)
                .font(.headline)
            
            Spacer()
            
            Button {
                Task {
                    try await viewModel.editGroup(withGroupId: group.id, name: name, handle: handle)
                }
            } label: {
                Text("Save")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
        .onReceive(viewModel.$didEditGroup) { success in
            if success {
                if let newGroup = viewModel.group {
                    self.group = newGroup
                }
                mode.wrappedValue.dismiss()
            }
        }
        .padding(10)
    }
    
    var groupImageInput: some View {
        HStack {
            PhotosPicker(selection: $viewModel.selectedItem) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = viewModel.groupImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: ProfileImageSize.xLarge.dimension, height: ProfileImageSize.xLarge.dimension)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        SquareGroupImageView(group: group, size: .xLarge)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.theme.background)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "camera.circle.fill")
                            .foregroundColor(Color.theme.primaryText)
                            .frame(width: 18, height: 18)
                    }
                }
            }
        }
    }
    
    var groupNameInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Group name")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("Enter a new group name", text: $name)
                    .font(.system(size: 20))
                    .foregroundColor(Color.theme.primaryText)
                
                Divider()
                    .background(Color.theme.secondaryText)
            }
            
            Text("Group handle")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            HStack(spacing: 0) {
                Text("@")
                    .font(.system(size: 20))
                    .foregroundColor(Color.theme.primaryText)
                
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Enter a new group handle", text: $handle)
                        .font(.system(size: 20))
                        .foregroundColor(Color.theme.primaryText)
                    
                    Divider()
                        .background(Color.theme.secondaryText)
                }
            }
            
        }
        .padding()
        .autocapitalization(.none)
    }
}

//#Preview {
//    EditGroupView()
//}
