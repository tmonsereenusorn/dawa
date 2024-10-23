import SwiftUI
import Combine

struct AddActivityView: View {
    @State private var title = ""
    @State private var numRequired = ""
    @State private var unlimitedParticipants = false
    @State private var notes = ""
    @State private var location = ""
    @State private var showWarningMessage = false
    @State private var selectedTag = ""
    
    @State private var titleError: String?
    @State private var locationError: String?
    @State private var numRequiredError: String?
    @State private var notesError: String?
    
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel = AddActivityViewModel()
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            VStack {
                HStack(alignment: .bottom) {
                    Spacer()
                    Text("Create New Activity")
                        .foregroundColor(Color.theme.primaryText)
                        .font(.headline)
                    Spacer()
                }
                .onReceive(viewModel.$didUploadActivity) { success in
                    if success {
                        mode.wrappedValue.dismiss()
                    }
                }
                .padding(10)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Group name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Creating activity in group")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        Text("\(groupsViewModel.currSelectedGroup?.name ?? "Unknown Group")")
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .foregroundColor(Color.theme.primaryText)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Title field with validation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Title")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Enter a title for your activity", text: $title)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onChange(of: title) { newValue in
                                if newValue.count < ActivityConstants.minTitleLength {
                                    self.titleError = "Title is required."
                                } else if newValue.count > ActivityConstants.maxTitleLength {
                                    self.titleError = "Title cannot exceed \(ActivityConstants.maxTitleLength) characters."
                                } else {
                                    self.titleError = nil
                                }
                            }
                        if let titleError = titleError {
                            Text(titleError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    // Location field with validation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Enter a location for your activity", text: $location)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onChange(of: location) { newValue in
                                if newValue.count < ActivityConstants.minLocationLength {
                                    self.locationError = "Location is required."
                                } else if newValue.count > ActivityConstants.maxLocationLength {
                                    self.locationError = "Location cannot exceed \(ActivityConstants.maxLocationLength) characters."
                                } else {
                                    self.locationError = nil
                                }
                            }
                        if let locationError = locationError {
                            Text(locationError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    // Number of participants with validation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Number of Participants")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        
                        if !unlimitedParticipants {
                            TextField("Number of additional people needed", text: $numRequired)
                                .keyboardType(.numberPad)
                                .modifier(TextFieldModifier())
                                .padding(.horizontal, 0)
                                .onChange(of: numRequired) { newValue in
                                    if let value = Int(newValue), value >= ActivityConstants.minParticipants && value <= ActivityConstants.maxParticipants {
                                        numRequiredError = nil
                                    } else if newValue.isEmpty {
                                        numRequiredError = "Number of participants is required."
                                    } else {
                                        numRequiredError = "Enter a value between \(ActivityConstants.minParticipants) and \(ActivityConstants.maxParticipants)."
                                    }
                                }
                        } else {
                            Text("Unlimited Participants")
                                .modifier(TextFieldModifier())
                                .padding(.horizontal, 0)
                                .foregroundColor(.gray)
                        }
                        if let numRequiredError = numRequiredError {
                            Text(numRequiredError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        Toggle("Unlimited Participants", isOn: $unlimitedParticipants)
                            .toggleStyle(SwitchToggleStyle(tint: Color.theme.appTheme))
                    }
                    
                    // Notes field with validation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Details (Optional)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Activity details (time required, skill level, etc.)", text: $notes)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onChange(of: notes) { newValue in
                                if newValue.count > ActivityConstants.maxActivityDetails {
                                    self.notesError = "Activity details cannot exceed \(ActivityConstants.maxActivityDetails) characters."
                                } else {
                                    self.notesError = nil
                                }
                            }
                        if let notesError = notesError {
                            Text(notesError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    // Filters
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select a category")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ActivityFilters.allCases, id: \.rawValue) { option in
                                    Text(option.label)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .foregroundColor(Color.theme.primaryText)
                                        .background(option.color)
                                        .opacity(selectedTag == option.label ? 1 : 0.5)
                                        .cornerRadius(15)
                                        .font(.caption).bold()
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTag = (selectedTag == option.label) ? "" : option.label
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    VStack {
                        Button {
                            Task {
                                let participantsRequired = unlimitedParticipants ? -1 : Int(numRequired) ?? 0
                                try await viewModel.addActivity(groupId: groupsViewModel.currSelectedGroup!.id,
                                                                title: title,
                                                                location: location,
                                                                notes: notes,
                                                                numRequired: participantsRequired,
                                                                category: selectedTag)
                                try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                            }
                        } label: {
                            Text("Create Activity")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.theme.appTheme)
                                .cornerRadius(10)
                                .font(.headline).bold()
                        }
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                        
                        Button(action: {
                            mode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel and return to activity feed")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.footnote)
                                .underline()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal)
            }
            .blur(radius: (viewModel.isLoading || viewModel.errorMessage != nil) ? 5.0 : 0)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            // Error view overlay if there is an error message
            if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.errorMessage = nil // Dismiss error message
                }
                .zIndex(1) // Ensure the error message is shown above other content
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.theme.background)
        .edgesIgnoringSafeArea(.all)
    }
}

// Extension for form validation
extension AddActivityView {
    var formIsValid: Bool {
        return !title.isEmpty
        && title.count >= ActivityConstants.minTitleLength
        && title.count <= ActivityConstants.maxTitleLength
        && !location.isEmpty
        && location.count >= ActivityConstants.minLocationLength
        && location.count <= ActivityConstants.maxLocationLength
        && (unlimitedParticipants || (!numRequired.isEmpty && Int(numRequired) != nil && Int(numRequired)! >= ActivityConstants.minParticipants && Int(numRequired)! <= ActivityConstants.maxParticipants))
    }
}
