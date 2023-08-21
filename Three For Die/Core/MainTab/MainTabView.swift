import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
}

struct MainTabView: View {
    @State private var selectedIndex = 0
    @State var sideMenuOpen = false
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            MainFeedView(sideMenuOpen: $sideMenuOpen)
                .tabItem {
                    Image(systemName: "house")
                }.tag(0)
            
            InboxView()
                .tabItem {
                    Image(systemName: "figure.walk")
                }.tag(1)
        }
        .background(Color.black)
        .accentColor(.white)
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
