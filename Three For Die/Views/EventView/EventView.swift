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
        VStack(spacing: 20) {
            HStack(spacing: 100) {
                Text(event.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "pin")
                    Text(event.location)
                }
            }
            Text(event.description)
                .font(.title2)
            
            HStack {
                ForEach(1...event.numPeopleCur, id: \.self) { i in
                    Image(systemName: "circle")
                        .renderingMode(.template)
                        .foregroundColor(.green)
                }
                ForEach(event.numPeopleCur...(event.numPeopleReq - 1), id: \.self) { i in
                    Image(systemName: "circle")
                }
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: Event.preview[0])
    }
}
