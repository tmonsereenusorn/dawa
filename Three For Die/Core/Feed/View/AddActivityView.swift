import Foundation
import SwiftUI
import Combine

struct AddActivityView: View {
    @State var title = ""
    @State var numPeople = ""
    @State var notes = ""
    @State var showWarningMessage = false
    @State var selectedTag = ""
    @State var tags: [String] = []
    
    var body: some View {
        VStack {
            Text("Create a new activity")
                .font(.title2)
            // Title and notes for activity
            VStack {
                InputView(text: $title,
                          title: "Title",
                          placeholder: "Enter a title for your activity")
                .padding()
                
                InputView(text: $notes,
                          title: "Notes (optional)",
                          placeholder: "Enter notes about your activity (level, time etc.)")
                .padding()
            }
            
            
            // Number of people needed
            HStack {
                TextField("Number of people needed", text: $numPeople)
                    .keyboardType(.numberPad)
                    .onReceive(Just(numPeople)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.numPeople = filtered
                        }
                        if Int(filtered) ?? 0 > 30 {
                            self.numPeople = "30"
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
            ScrollView() {
                LazyHStack() {
                    ForEach(AddActivityViewModel.allCases, id: \.rawValue) { option in
                        Button {
                            selectedTag = option.label
                        } label: {
                            Text(option.label)
                                .padding()
                                .foregroundColor(.white)
                                .background(option.color)
                                .opacity(self.selectedTag == option.label ? 1 : 0.5)
                                .cornerRadius(15)
                                .font(.caption).bold()
                        }
                    }
                }
            }
            
            
            // Submit button
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
//    @ViewBuilder
//    func activityTag (text: String) -> some View {
//        HStack {
//            Text (text)
//            Button () {
//
//            } label: {
//                Image (systemName: "xmark")
//                    .resizable ()
//                    .frame (width: 10, height: 10)
//                    .foregroundColor(Color.gray.opacity (0.7))
//            }
//        }.padding (6)
//        .overlay (
//            RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)
//                .stroke (Color (red: 0.60, green: 0.87, blue: 0.87))
//        )
//    }

//    var body: some View {
//        VStack (spacing: UIScreen.main.bounds.height / 40) {
//            HStack {
//                Spacer ()
//                RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)
//                    .frame (width: UIScreen.main.bounds.width / 5, height: 5)
//                    .foregroundColor (Color.gray.opacity(0.5))
//                Spacer ()
//            }
//
//            TextField ("Activity Title", text: $title)
//                .padding (8)
//                .background (Color.gray.opacity (0.2)
//                    .clipShape (RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)))
//
//            ScrollView (.horizontal) {
//                Button () {
//
//                } label: {
//                    Image (systemName: "plus")
//                        .foregroundColor(Color.primary)
//                }
//                ForEach (tags, id: \.self) { tag in
//                    activityTag(text: tag)
//                }
//            }
//
//            HStack {
//                TextField("Total number of people", text: $numRequired)
//                    .keyboardType(.numberPad)
//                    .onReceive(Just(numRequired)) { newValue in
//                        let filtered = newValue.filter { "0123456789".contains($0) }
//                        if filtered != newValue {
//                            self.numRequired = filtered
//                        }
//                        if Int(filtered) ?? 0 > 30 {
//                            self.numRequired = "30"
//                            self.showWarningMessage = true
//                        }
//                    }
//                if self.showWarningMessage {
//                    Text("Warning: Max number of people is 30")
//                        .font(.caption)
//                        .foregroundColor(.red)
//                }
//                Spacer ()
//            }
//
//            TextField ("Notes", text: $notes, axis: .vertical)
//                .padding (8)
//                .background (Color.gray.opacity(0.2).clipShape (RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)))
//
//            Spacer ()
//
//            HStack {
//                Spacer ()
//                Button () {
//                    Task.init {
//                        let data: [String: Any] = [
//                            "name": title,
//                            "numPeopleReq": Int (numRequired) ?? 0,
//                            "description": notes
//                        ]
//                        let event: Event = await UserAPI.createEvent (data: data)
//                        await UserAPI.addEvent (event: event)
//
//                    }
//                } label: {
//                    Image (systemName: "checkmark.rectangle.fill")
//                        .resizable ()
//                        .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.height / 25)
//                        .foregroundColor(Color (red: 0.60, green: 0.87, blue: 0.87))
//                }
//            }
//        }.padding ()
//    }
}

//struct Previews_AddActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddActivityView()
//    }
//}
