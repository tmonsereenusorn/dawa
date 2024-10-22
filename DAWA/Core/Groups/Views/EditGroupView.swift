import SwiftUI
import PhotosUI

struct EditGroupView: View {
    @State private var name = ""
    @State private var handle = ""
    @StateObject var viewModel = EditGroupViewModel()
    @Binding var group: Groups
    @Environment(\.presentationMode) var mode
    
    // Error state variables
    @State private var groupNameError: String?
    @State private var handleError: String?
    
    var body: some View {
        ZStack {
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
            .blur(radius: viewModel.errorMessage != nil ? 5 : 0)
            .disabled(viewModel.errorMessage != nil)
            
            // Error view overlay if there is an error message
            if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.errorMessage = nil // Dismiss error message
                }
                .zIndex(1) // Ensure the error message is shown above other content
            }
        }
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
    
    // Group name and handle input fields with validation
    var groupNameInput: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Group name")
                    .foregroundColor(Color.theme.primaryText)
                    .fontWeight(.semibold)
                    .font(.footnote)
                
                TextField("Enter a new group name", text: $name)
                    .modifier(TextFieldModifier())
                    .onChange(of: name) { newValue in
                        validateGroupName(newValue)
                    }
                
                if let groupNameError = groupNameError {
                    Text(groupNameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
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
                        .onChange(of: handle) { newValue in
                            validateGroupHandle(newValue)
                        }
                }
                
                if let handleError = handleError {
                    Text(handleError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Validation functions
    private func validateGroupName(_ name: String) {
        if name.count > GroupConstants.maxNameLength {
            groupNameError = "Group name cannot exceed \(GroupConstants.maxNameLength) characters."
        } else if name.count < GroupConstants.minNameLength {
            groupNameError = "Group name must contain at least \(GroupConstants.minNameLength) characters."
        } else {
            groupNameError = nil
        }
    }
    
    private func validateGroupHandle(_ handle: String) {
        if handle.count > GroupConstants.maxHandleLength {
            handleError = "Group handle cannot exceed \(GroupConstants.maxHandleLength) characters."
        } else if handle.count < GroupConstants.minHandleLength {
            handleError = "Group handle must contain at least \(GroupConstants.minHandleLength) characters."
        } else {
            handleError = nil
        }
    }
    
    // Form validation
    private func validateForm() -> Bool {
        validateGroupName(name)
        validateGroupHandle(handle)
        return groupNameError == nil && handleError == nil
    }
}
