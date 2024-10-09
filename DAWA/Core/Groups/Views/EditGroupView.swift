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
        .padding(.horizontal, 16)
        .onAppear {
            self.name = group.name
            self.handle = group.handle
        }
        .background(Color.theme.background)
    }
}

extension EditGroupView {
    // Header with Cancel and Save buttons
    var headerView: some View {
        HStack {
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
        .padding(.vertical, 10)
    }
    
    // Group image picker using PhotosPicker
    var groupImageInput: some View {
        PhotosPicker(selection: $viewModel.selectedItem) {
            ZStack(alignment: .bottomTrailing) {
                if let image = viewModel.groupImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
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
        .padding(.vertical, 16)
    }
    
    // Group name and handle input fields
    var groupNameInput: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Group name")
                    .foregroundColor(Color.theme.primaryText)
                    .fontWeight(.semibold)
                    .font(.footnote)
                
                TextField("Enter a new group name", text: $name)
                    .modifier(TextFieldModifier())
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Group handle")
                    .foregroundColor(Color.theme.primaryText)
                    .fontWeight(.semibold)
                    .font(.footnote)
                
                HStack {
                    Text("@")
                        .font(.system(size: 20))
                        .foregroundColor(Color.theme.primaryText)
                    
                    TextField("Enter a new group handle", text: $handle)
                        .modifier(TextFieldModifier())
                }
                
                if viewModel.showGroupHandleErrorMessage {
                    Text("Group handle already exists. Please choose a different one.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
