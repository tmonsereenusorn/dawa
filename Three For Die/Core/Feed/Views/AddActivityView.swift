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
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            Text("Create a new activity")
                .font(.title2)
            // Title, notes, location for activity
            VStack {
                InputView(text: $title,
                          title: "Title",
                          placeholder: "Enter a title for your activity")
                .padding()
                
                InputView(text: $location,
                          title: "Location",
                          placeholder: "Enter a location for your activity")
                .padding()
                
                InputView(text: $notes,
                          title: "Details (optional)",
                          placeholder: "Activity details (level, time required etc.)")
                .padding()
            }
            
            // Number of people needed
            HStack {
                InputView(text: $numRequired,
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
                                    .foregroundColor(.white)
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
            
            // Cancel and Submit button
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
                
                Spacer ()
                
                Button {
                    Task {
                        try await viewModel.addActivity(title: title, location: location, notes: notes, numRequired: numRequired, category: selectedTag)
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    HStack {
                        Text("Create")
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
            .padding()
            
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

//struct Previews_AddActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddActivityView()
//    }
//}

extension AddActivityView: AddActivityFormProtocol {
    var formIsValid: Bool {
        return !title.isEmpty
        && !location.isEmpty
        && !numRequired.isEmpty
    }
}
