//
//  ContentView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/16/23.
//

import Foundation
import SwiftUI

struct ContentView: View {
    init() {
        UITableView.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    @State var selectedTab: TabType = .home
    
    var body: some View {
        VStack(spacing:0) {
            if selectedTab == .home {
                FeedView()
            }
            
            VStack {
                Divider()
                    .overlay(.gray)
                TabView(selectedTab: $selectedTab)
            }
        }
        .background(Color.black)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
