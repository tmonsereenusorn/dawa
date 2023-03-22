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
        HStack(spacing: 80) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.name)
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(CustomColors.gray_2)
                }
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
            VStack(alignment: .trailing, spacing: 6) {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(CustomColors.secondary)
                    Text(event.host)
                }
                HStack {
                    Image(systemName: "pin")
                        .foregroundColor(CustomColors.secondary)
                    Text(event.location)
                }
                
                Text(event.time.timeAgoDisplay())
                    .foregroundColor(CustomColors.gray_1)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(15)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: Event.preview[0])
    }
}
