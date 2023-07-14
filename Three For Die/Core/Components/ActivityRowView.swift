//
//  EventView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import SwiftUI

struct ActivityRowView: View {
    let activity: Activity
    
    var body: some View {
        if let user = activity.user {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.black)
                    Text(user.username)
                        .foregroundColor(.black)
                    Text("2m")
                        .foregroundColor(CustomColors.gray_2)
                }
                HStack {
                    Text(activity.title)
                        .font(.title)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "pin")
                        .foregroundColor(.black)
                    Text(activity.location)
                        .foregroundColor(.black)
                }
                HStack {
                    Text(activity.notes)
                        .font(.body)
                        .foregroundColor(CustomColors.gray_2)
                    Spacer()
                    HStack {
                        ForEach(0..<activity.numCurrent, id: \.self) { i in
                            Image(systemName: "circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(.green)
                        }
                        ForEach(activity.numCurrent...(activity.numRequired - 1),   id: \.self) { i in
                            Image(systemName: "circle.fill")
                                .foregroundColor(CustomColors.gray_1)
                        }
                    }
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(12)
        }
    }
}

//struct ActivityRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityRowView(activity: Activity.MOCK_ACTIVITY)
//    }
//}
