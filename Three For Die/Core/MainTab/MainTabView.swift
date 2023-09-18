import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
}

struct MainTabView: View {
    @State private var selectedIndex = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            MainFeedView()
                .tabItem {
                    Image(systemName: "house")
                }.tag(0)
            
            InboxView()
                .tabItem {
                    Image(systemName: "message")
                }.tag(1)
        }
        .background(Color.theme.background)
        .accentColor(.white)
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
