import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
    case notifications
}

struct MainTabView: View {
    @State var showLeftMenu: Bool = false
    @State var showRightMenu: Bool = false
    @State var currentTab = "house"
    
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var feedViewModel = FeedViewModel()
    @StateObject var inboxViewModel = InboxViewModel()
    @StateObject var notificationsViewModel = NotificationsViewModel()
    
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
                        
                        NotificationsView(showLeftMenu: $showLeftMenu, showRightMenu: $showRightMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("bell")
                    }
                    
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 0) {
                            TabButton(image: "house")
                            
                            TabButton(image: "message", hasUnread: inboxViewModel.hasUnreadMessages)
                            
                            TabButton(image: "bell", hasUnread: notificationsViewModel.hasUnreadNotifications)
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
        .environmentObject(inboxViewModel)
        .environmentObject(notificationsViewModel)
    }
    
    @ViewBuilder
    func TabButton(image: String, hasUnread: Bool = false) -> some View {
        Button {
            withAnimation { currentTab = image }
        } label: {
            ZStack {
                Image(systemName: image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 23)
                    .foregroundColor(currentTab == image ? Color.theme.primaryText : Color.theme.secondaryText)
                    .frame(maxWidth: .infinity)
                
                if hasUnread {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 12, y: -12)
                }
            }
        }
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
