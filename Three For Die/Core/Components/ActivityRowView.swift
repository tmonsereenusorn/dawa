//
//  EventView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import SwiftUI

struct ActivityRowView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.black)
                Text("Tee")
                    .foregroundColor(.black)
                Text("2m")
                    .foregroundColor(CustomColors.gray_2)
            }
            HStack {
                Text("3 For Die")
                    .font(.title)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "pin")
                    .foregroundColor(.black)
                Text("Phi Psi Lawn")
                    .foregroundColor(.black)
            }
            HStack {
                Text("No noobs plz")
                    .font(.body)
                    .foregroundColor(CustomColors.gray_2)
                Spacer()
                HStack {
                    ForEach(1...1, id: \.self) { i in
                        Image(systemName: "circle.fill")
                            .renderingMode(.template)
                            .foregroundColor(.green)
                    }
                    ForEach(1...(3 - 1), id: \.self) { i in
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

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView()
    }
}
