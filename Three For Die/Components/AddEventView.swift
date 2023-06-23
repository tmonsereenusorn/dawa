import Foundation
import SwiftUI

struct AddEventView: View {
    @State var title: String = ""
    @State var numRequired: String = ""
    @State var notes: String = ""
    @State var tags: [String] = []
    
    @ViewBuilder
    func activityTag (text: String) -> some View {
        HStack {
            Text (text)
            Button () {
                
            } label: {
                Image (systemName: "xmark")
                    .resizable ()
                    .frame (width: 10, height: 10)
                    .foregroundColor(Color.gray.opacity (0.7))
            }
        }.padding (6)
        .overlay (
            RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)
                .stroke (Color (red: 0.60, green: 0.87, blue: 0.87))
        )
    }

    var body: some View {
        VStack (spacing: UIScreen.main.bounds.height / 40) {
            HStack {
                Spacer ()
                RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)
                    .frame (width: UIScreen.main.bounds.width / 5, height: 5)
                    .foregroundColor (Color.gray.opacity(0.5))
                Spacer ()
            }
            
            TextField ("Activity Title", text: $title)
                .padding (8)
                .background (Color.gray.opacity (0.2)
                    .clipShape (RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)))
            
            ScrollView (.horizontal) {
                Button () {
                    
                } label: {
                    Image (systemName: "plus")
                        .foregroundColor(Color.primary)
                }
                ForEach (tags, id: \.self) { tag in
                    activityTag(text: tag)
                }
            }
            
            HStack {
                Text ("How many people?")
                TextField ("", text: $numRequired)
                    .keyboardType(.numberPad)
                    .padding (5)
                    .background (Color.gray.opacity (0.2)
                        .clipShape (RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)))
                    .frame (width: 30)
                Spacer ()
            }
            
            if #available(iOS 16.0, *) {
                TextField ("Notes", text: $notes, axis: .vertical)
                    .padding (8)
                    .background (Color.gray.opacity (0.2)
                        .clipShape (RoundedRectangle (cornerRadius: UIScreen.main.bounds.height / 100)))
            }
            
            Spacer ()
            
            HStack {
                Spacer ()
                Button () {
                    Task.init {
                        let data: [String: Any] = [
                            "name": title,
                            "numPeopleReq": Int (numRequired) ?? 0,
                            "description": notes
                        ]
                        let event: Event = await UserAPI.createEvent (data: data)
                        await UserAPI.addEvent (event: event)
                        
                    }
                } label: {
                    Image (systemName: "checkmark.rectangle.fill")
                        .resizable ()
                        .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.height / 25)
                        .foregroundColor(Color (red: 0.60, green: 0.87, blue: 0.87))
                }
            }
        }.padding ()
    }
}
