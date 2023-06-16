//
//  ContentView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/16/23.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State var selectedTab: TabType = .home
    
    var body: some View {
        VStack {
            if selectedTab == .home {
                FeedView()
            }
            
            TabView(selectedTab: $selectedTab)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
