import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
}

struct MainTabView: View {
    @State var showLeftMenu: Bool = false
    @State var showRightMenu: Bool = false
    @State var currentTab = "house"
    
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var feedViewModel = FeedViewModel()
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        let sideBarWidth = getRect().width - 90
        NavigationStack {
            HStack(spacing: 0) {
                GroupsView()
                
                VStack(spacing: 0) {
                    TabView(selection: $currentTab) {
                        FeedView(showLeftMenu: $showLeftMenu, showRightMenu: $showRightMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("house")
                        
                        InboxView(showLeftMenu: $showLeftMenu, showRightMenu: $showRightMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("message")
                    }
                    
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 0) {
                            TabButton(image: "house")
                            
                            TabButton(image: "message")
                        }
                        .padding(.top, 15)
                    }
                    
                }
                .frame(width: getRect().width)
                .overlay (
                    Rectangle()
                        .fill(
                            Color.theme.background.opacity(Double((offset / sideBarWidth) / 5))
                        )
                        .ignoresSafeArea(.container, edges: .vertical)
                        .onTapGesture {
                            withAnimation {
                                if showLeftMenu {
                                    showLeftMenu.toggle()
                                } else {
                                    showRightMenu.toggle()
                                }
                            }
                        }
                )
                
                RightSideMenuView()
            }
            .frame(width: getRect().width + 2 * sideBarWidth)
            .offset(x: offset)
        }
        .animation(.easeOut, value: offset == 0)
        .onChange(of: showLeftMenu) { newValue in
            if showLeftMenu && offset == 0 {
                offset = sideBarWidth
                lastStoredOffset = offset
            }
            
            if !showLeftMenu && offset == sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
        .onChange(of: showRightMenu) { newValue in
            if showRightMenu && offset == 0 {
                offset = -sideBarWidth
                lastStoredOffset = offset
            }
            
            if !showRightMenu && offset == -sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
        .environmentObject(groupsViewModel)
        .environmentObject(feedViewModel)
    }
    
    @ViewBuilder
    func TabButton(image: String) -> some View {
        Button {
            withAnimation { currentTab = image }
        } label: {
            Image(systemName: image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 23, height: 23)
                .foregroundColor(currentTab == image ? Color.theme.primaryText : Color.theme.secondaryText)
                .frame(maxWidth: .infinity)
        }
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
