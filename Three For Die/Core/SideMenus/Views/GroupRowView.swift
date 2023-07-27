//
//  GroupRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupRowView: View {
    @ObservedObject var viewModel: GroupRowViewModel
    
    init(group: Groups) {
        self.viewModel = GroupRowViewModel(group: group)
    }
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 48, height: 48)
            
            Text(viewModel.group.name)
            
            Spacer()
            
            Image(systemName: "ellipsis")
        }
        .padding()
    }
}

//struct LeftSideMenuRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuRowView()
//    }
//}
