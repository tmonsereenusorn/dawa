import Foundation
import SwiftUI
import Combine

struct AddActivityView: View {
    @State private var title = ""
    @State private var numRequired = ""
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
            
            // Group name, Title, notes, location for activity
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
                            if newLocation.count > 15 {
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
                    TextField("Number of additional people needed", text: $numRequired)
                        .keyboardType(.numberPad)
                        .modifier(TextFieldModifier())
                        .padding(.horizontal, 0)
                        .onReceive(Just(numRequired)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.numRequired = filtered
                            }
                            if Int(filtered) ?? 0 > 30 {
                                self.numRequired = "30"
                                self.showWarningMessage = true
                            }
                        }
                    
                    if showWarningMessage {
                        Text("Warning: Max number of people is 30")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
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
                        HStack {
                            ForEach(ActivityFilters.allCases, id: \.rawValue) { option in
                                Button {
                                    if selectedTag != option.label {
                                        selectedTag = option.label
                                    } else {
                                        selectedTag = ""
                                    }
                                } label: {
                                    Text(option.label)
                                        .padding(.vertical, 8) // Adjust vertical padding
                                        .padding(.horizontal, 12) // Adjust horizontal padding
                                        .foregroundColor(Color.theme.primaryText)
                                        .background(option.color)
                                        .opacity(self.selectedTag == option.label ? 1 : 0.5)
                                        .cornerRadius(15)
                                        .font(.caption).bold()
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Divider()
                
                VStack {
                    Button {
                        Task {
                            try await viewModel.addActivity(groupId: groupsViewModel.currSelectedGroup!.id,
                                                            title: title,
                                                            location: location,
                                                            notes: notes,
                                                            numRequired: Int(numRequired)!,
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
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.theme.background)
        .edgesIgnoringSafeArea(.all)
    }
}

extension AddActivityView: AddActivityFormProtocol {
    var formIsValid: Bool {
        return !title.isEmpty
        && !location.isEmpty
        && !numRequired.isEmpty
    }
}


//struct Previews_AddActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddActivityView(user: User.MOCK_USER)
//    }
//}

