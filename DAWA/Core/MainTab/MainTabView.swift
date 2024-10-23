import Foundation
import SwiftUI
import Combine

enum TabType: String, Hashable {
    case home = "house"
    case inbox = "message"
    case notifications = "bell"
}

struct MainTabView: View {
    @State var showLeftMenu: Bool = false
    @State var showRightMenu: Bool = false
    @State var currentTab: TabType = .home
    
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var feedViewModel = FeedViewModel()
    @StateObject var inboxViewModel = InboxViewModel()
    @StateObject var notificationsViewModel = NotificationsViewModel()
    @State private var cancellables = Set<AnyCancellable>()
    
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
                            .tag(TabType.home)
                        
                        InboxView(showLeftMenu: $showLeftMenu, showRightMenu: $showRightMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag(TabType.inbox)
                        
                        NotificationsView(showLeftMenu: $showLeftMenu, showRightMenu: $showRightMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag(TabType.notifications)
                    }
                    
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 0) {
                            TabButton(image: "house", tab: .home)
                            TabButton(image: "message", tab: .inbox, hasUnread: inboxViewModel.hasUnreadMessages)
                            TabButton(image: "bell", tab: .notifications, hasUnread: notificationsViewModel.hasUnreadNotifications)
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
            .onAppear {
                setupNotificationHandlers()
            }
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
    func TabButton(image: String, tab: TabType, hasUnread: Bool = false) -> some View {
        Button {
            withAnimation { currentTab = tab }
        } label: {
            ZStack {
                Image(systemName: image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 23)
                    .foregroundColor(currentTab == tab ? Color.theme.primaryText : Color.theme.secondaryText)
                    .frame(maxWidth: .infinity)
                
                if hasUnread {
                    Circle()
                        .fill(Color.theme.appTheme)
                        .frame(width: 8, height: 8)
                        .offset(x: 12, y: -12)
                }
            }
        }
    }
    
    // Function to handle notification-based tab switching
    func setupNotificationHandlers() {
        PushNotificationHandler.shared.$tappedActivityId.sink { activityId in
            if let activityId = activityId, let groupId = PushNotificationHandler.shared.tappedGroupId {
                currentTab = .home
                
                // Fetch the corresponding group based on groupId and update currSelectedGroup
                Task {
                    // Fetch the group asynchronously and update the current selected group
                    try await groupsViewModel.fetchGroup(groupId: groupId)
                    
                    // Reset the tapped activity and group IDs after fetching
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        PushNotificationHandler.shared.tappedActivityId = nil
                        PushNotificationHandler.shared.tappedGroupId = nil
                    }
                }
            }
        }.store(in: &cancellables)
        
        PushNotificationHandler.shared.$tappedChatActivityId.sink { activityId in
            if activityId != nil {
                currentTab = .inbox
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    PushNotificationHandler.shared.tappedChatActivityId = nil
                }
            }
        }.store(in: &cancellables)
        
        PushNotificationHandler.shared.$tappedGroupInviteId.sink { inviteId in
            if inviteId != nil {
                currentTab = .notifications
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    PushNotificationHandler.shared.tappedGroupInviteId = nil
                }
            }
        }.store(in: &cancellables)
    }
}
