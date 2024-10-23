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
                    
                    // Title field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Title")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Enter a title for your activity", text: $title)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onReceive(Just(title)) { newTitle in
                                if newTitle.count > 25 {
                                    self.title = String(newTitle.prefix(25))
                                }
                            }
                    }
                    
                    // Location field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Enter a location for your activity", text: $location)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onReceive(Just(location)) { newLocation in
                                if newLocation.count > 30 {
                                    self.location = String(newLocation.prefix(15))
                                }
                            }
                    }
                    
                    // Number of people required
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
                                .onReceive(Just(numRequired)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.numRequired = filtered
                                    }
                                }
                        } else {
                            Text("Unlimited Participants")
                                .modifier(TextFieldModifier())
                                .padding(.horizontal, 0)
                                .foregroundColor(.gray)
                        }

                        Toggle("Unlimited Participants", isOn: $unlimitedParticipants)
                            .toggleStyle(SwitchToggleStyle(tint: Color.theme.appTheme))
                    }
                    
                    // Notes field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Details (Optional)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.primaryText)
                        TextField("Activity details (time required, skill level, etc.)", text: $notes)
                            .modifier(TextFieldModifier())
                            .padding(.horizontal, 0)
                            .onReceive(Just(notes)) { newNotes in
                                if newNotes.count > 50 {
                                    self.notes = String(newNotes.prefix(50))
                                }
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
                                let participantsRequired = unlimitedParticipants ? -1 : Int(numRequired)!
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
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.theme.background)
        .edgesIgnoringSafeArea(.all)
    }
}

extension AddActivityView: AddActivityFormProtocol {
    var formIsValid: Bool {
        return !title.isEmpty
        && !location.isEmpty
        && (unlimitedParticipants || (!numRequired.isEmpty && Int(numRequired)! > 0))
    }
}
