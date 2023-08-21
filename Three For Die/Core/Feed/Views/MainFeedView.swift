//
//  MainFeedView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/21/23.
//

import SwiftUI

struct MainFeedView: View {
    @State private var showLeftMenu = false
    @State private var showRightMenu = false
    @Binding var sideMenuOpen: Bool
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var feedViewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                FeedView()
                    .navigationBarHidden(showLeftMenu || showRightMenu)
                
                if showLeftMenu {
                    ZStack {
                        Color(.black)
                            .opacity(showLeftMenu ? 0.25 : 0.0)
                    }.onTapGesture {
                        withAnimation(.easeInOut) {
                            showLeftMenu = false
                        }
                    }
                    .ignoresSafeArea()
                }
                
                if showRightMenu {
                    ZStack {
                        Color(.black)
                            .opacity(showRightMenu ? 0.25 : 0.0)
                    }.onTapGesture {
                        withAnimation(.easeInOut) {
                            showRightMenu = false
                        }
                    }
                    .ignoresSafeArea()
                }
                
                GroupsView()
                    .frame(width: 300)
                    .background(showLeftMenu ? Color.white : Color.clear)
                    .offset(x: showLeftMenu ? 0 : -300, y: 0)
                
                RightSideMenuView()
                    .frame(width: 300)
                    .background(showRightMenu ? Color.white : Color.clear)
                    .offset(x: showRightMenu ? 100 : 500, y: 0)
            }
            .navigationTitle("Stanford")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) {
                            showLeftMenu.toggle()
                            sideMenuOpen.toggle()
                        }
                    } label: {
                        Circle()
                            .frame(width: 32, height: 32)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            showRightMenu.toggle()
                            sideMenuOpen.toggle()
                        }
                    } label: {
                        Circle()
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .environmentObject(groupsViewModel)
        .environmentObject(feedViewModel)
    }
}

//struct MainFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainFeedView()
//    }
//}
