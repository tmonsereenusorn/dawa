import Foundation
import SwiftUI

enum TabType {
    case home
    case activities
}

struct TabView: View {
    @State var selectedTab: TabType = .home
    @State var addingEvent: Bool = false

    var body: some View {
        ZStack {
            Button () {
                addingEvent.toggle ()
            } label: {
                Image (systemName: "plus.circle.fill")
                    .resizable ()
                    .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                    .foregroundColor (Color (red: 0.94, green: 0.73, blue: 0.75))
            }.popover(isPresented: $addingEvent) {
                AddEventView()
            }
            .position (x: UIScreen.main.bounds.width * 0.9, y: UIScreen.main.bounds.height * 0.78)
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
