import SwiftUI
import PhotosUI

struct CreateGroupView: View {
    @State private var groupName = ""
    @State private var handle = ""
    @ObservedObject var viewModel = CreateGroupViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var groupNameError: String?
    @State private var handleError: String?
    
    var body: some View {
        ZStack {
            Color.theme.background
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            VStack {
                HStack(alignment: .bottom) {
                    Spacer()
                                        
                    Text("Create New Group")
                        .foregroundColor(Color.theme.primaryText)
                        .font(.headline)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    groupImageInput
                    
                    groupNameInput
                    
                    groupHandleInput
                }
                
                Spacer()
                
                Divider()
                
                VStack {
                    Button {
                        Task {
                            try await viewModel.createGroup(name: groupName, handle: handle)
                            if let newGroupId = viewModel.groupId {
                                groupsViewModel.currSelectedGroup = try await GroupService.fetchGroup(groupId: newGroupId)
                                try await feedViewModel.fetchActivities(groupId: newGroupId)
                            }
                            await groupsViewModel.fetchUserGroups()
                        }
                    } label: {
                        Text("Create Group")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.theme.appTheme)
                            .cornerRadius(10)
                            .font(.headline).bold()
                    }
                    .disabled(!formIsValid || viewModel.isLoading)  // Disable button when loading
                    .opacity(formIsValid && !viewModel.isLoading ? 1.0 : 0.5)  // Change opacity when loading
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel and return to group list")
                            .foregroundColor(Color.theme.secondaryText)
                            .font(.footnote)
                            .underline()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .blur(radius: viewModel.isLoading ? 3.0 : 0)  // Blur when loading
            .disabled(viewModel.isLoading)  // Disable interaction when loading
            .onReceive(viewModel.$didCreateGroup) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            // Error view overlay if there is an error message
            if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.errorMessage = nil
                }
                .zIndex(1) // Ensure the error message is shown above other content
            }
        }
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
                    SquareGroupImageView(group: nil, size: .xLarge)
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
    
    var groupNameInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Group Name")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            TextField("Enter a new group name", text: $groupName)
                .modifier(TextFieldModifier())
                .autocapitalization(.none)
                .onChange(of: groupName) { newValue in
                    self.groupName = newValue
                    if newValue.count > GroupConstants.maxNameLength {
                        self.groupNameError = "Group name cannot exceed \(GroupConstants.maxNameLength) characters."
                    } else if newValue.count < GroupConstants.minNameLength {
                        self.groupNameError = "Group name must contain at least \(GroupConstants.minNameLength) characters."
                    } else {
                        self.groupNameError = nil
                    }
                }
            
            if let groupNameError = groupNameError {
                Text(groupNameError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var groupHandleInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Group Handle")
                .foregroundColor(Color.theme.primaryText)
                .fontWeight(.semibold)
                .font(.footnote)
            
            HStack {
                Text("@").font(.system(size: 20)).foregroundColor(Color.theme.primaryText)
                
                TextField("Enter a new group handle", text: $handle)
                    .modifier(TextFieldModifier())
                    .autocapitalization(.none)
                    .onChange(of: handle) { newValue in
                        self.handle = newValue.filter { !$0.isWhitespace }
                        if newValue.count > GroupConstants.maxHandleLength {
                            self.handleError = "Group handle cannot exceed \(ProfileConstants.maxUsernameLength) characters."
                        } else if newValue.count < GroupConstants.minHandleLength {
                            self.handleError = "Group handle must contain at least \(ProfileConstants.minUsernameLength) characters."
                        } else {
                            self.handleError = nil
                        }
                    }
            }
            
            if let handleError = handleError {
                Text(handleError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
    }
}

extension CreateGroupView: CreateGroupFormProtocol {
    var formIsValid: Bool {
        return groupName.count >= 3 && groupName.count <= 15 &&
               handle.count >= 3 && handle.count <= 15 &&
               groupNameError == nil && handleError == nil
    }
}
