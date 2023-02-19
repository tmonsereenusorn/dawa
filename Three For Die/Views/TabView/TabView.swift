import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
}

struct TabView: View {
    @State var selectedTab: TabType = .home

    var body: some View {
        ZStack {
            VStack {
                Spacer ()
                HStack {
                    Spacer ()
                    VStack {
                        Image (systemName: "house")
                            .resizable ()
                            .frame (width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.height / 30)
                            .foregroundColor(self.selectedTab == .home ? Color.primary : Color.gray.opacity(0.8))
                        Text ("Home")
                            .foregroundColor(self.selectedTab == .home ? Color.primary : Color.gray.opacity(0.8))
                    }
                    .onTapGesture {
                        withAnimation {
                            self.selectedTab = .home
                        }
                    }
                    Spacer ()
                    VStack {
                        Image (systemName: "figure.walk")
                            .resizable ()
                            .frame (width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.height / 35)
                            .foregroundColor(self.selectedTab == .activities ? Color.primary : Color.gray.opacity(0.8))
                        Text ("Activities")
                            .foregroundColor(self.selectedTab == .activities ? Color.primary : Color.gray.opacity(0.8))
                    }
                    .onTapGesture {
                        withAnimation {
                            self.selectedTab = .activities
                        }
                    }
                    Spacer ()
                }
            }
        }
    }
}
