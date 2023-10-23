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
    @Environment(\.presentationMode) var presentationMode
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
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text("Create New Activity")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
                
                Spacer()
                
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
                    Text("Create")
                        .font(.caption)
                        .foregroundColor(formIsValid ? .green : .gray)
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
            .onReceive(viewModel.$didUploadActivity) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(10)
            
            // Title, notes, location for activity
            VStack {
                FormInputView(text: $title,
                          title: "Title",
                          placeholder: "Enter a title for your activity")
                .padding()
                .onReceive(Just(title)) { newTitle in
                    if newTitle.count > 25 {
                        self.title = String(newTitle.prefix(25))
                    }
                }
                
                FormInputView(text: $location,
                          title: "Location",
                          placeholder: "Enter a location for your activity")
                .padding()
                .onReceive(Just(location)) { newLocation in
                    if newLocation.count > 15 {
                        self.location = String(newLocation.prefix(15))
                    }
                }
                
                FormInputView(text: $notes,
                          title: "Details (optional)",
                          placeholder: "Activity details (level, time required etc.)")
                .padding()
                .onReceive(Just(notes)) { newNotes in
                    if newNotes.count > 50 {
                        self.notes = String(newNotes.prefix(50))
                    }
                }
            }
            
            // Number of people needed
            HStack {
                FormInputView(text: $numRequired,
                          title: "How many more people?",
                          placeholder: "Number of additional people needed")
                .keyboardType(.numberPad)
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
                .padding()
                if self.showWarningMessage {
                    Text("Warning: Max number of people is 30")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                Spacer ()
            }
            
            // Filters
            VStack(alignment: .leading) {
                Text("Select a category")
                    .foregroundColor(Color(.darkGray))
                    .fontWeight(.semibold)
                    .font(.footnote)
                ScrollView() {
                    LazyHStack() {
                        ForEach(ActivityFilters.allCases, id: \.rawValue) { option in
                            Button {
                                if (selectedTag != option.label) {
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .background(Color.theme.background)
    }

}

//struct Previews_AddActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddActivityView(user: User.MOCK_USER)
//    }
//}

extension AddActivityView: AddActivityFormProtocol {
    var formIsValid: Bool {
        return !title.isEmpty
        && !location.isEmpty
        && !numRequired.isEmpty
    }
}
