//
//  FeedView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import Foundation
import SwiftUI

struct FeedView: View{
    var body: some View {
        NavigationView {
            ZStack {
                CustomColors.primary.ignoresSafeArea()
                ScrollView(.vertical) {
                    VStack (spacing: 15) {
                        ForEach(Event.preview) { event in
                            EventView(event: event)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationTitle("Feed")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .accentColor(CustomColors.primary)
        }
    }
}

struct FeedViews_Preview: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
