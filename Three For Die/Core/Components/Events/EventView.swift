//
//  EventView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import SwiftUI

struct EventView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.black)
                Text(event.host)
                    .foregroundColor(.black)
                Text(event.time.timeAgoDisplay())
                    .foregroundColor(CustomColors.gray_2)
            }
            HStack {
                Text(event.name)
                    .font(.title)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "pin")
                    .foregroundColor(.black)
                Text(event.location)
                    .foregroundColor(.black)
            }
            HStack {
                Text(event.description)
                    .font(.body)
                    .foregroundColor(CustomColors.gray_2)
                Spacer()
                HStack {
                    ForEach(1...event.numPeopleCur, id: \.self) { i in
                        Image(systemName: "circle.fill")
                            .renderingMode(.template)
                            .foregroundColor(.green)
                    }
                    ForEach(event.numPeopleCur...(event.numPeopleReq - 1), id: \.self) { i in
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

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView(event: Event.preview[0])
//    }
//}
