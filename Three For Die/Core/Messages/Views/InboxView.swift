//
//  InboxView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                List {
                    ForEach(viewModel.userActivities, id: \.self) { userActivity in
                        InboxRowView(userActivity: userActivity)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: UIScreen.main.bounds.height - 120)
            }
        }
    }
}
//
//struct InboxView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityInboxView()
//    }
//}
