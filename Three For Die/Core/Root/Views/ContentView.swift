//
//  ContentView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/20/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @State private var showLeftMenu = false
    @State private var showRightMenu = false
    
    var body: some View {
        Group {
            if let userSession = contentViewModel.userSession {
                if userSession.isEmailVerified {
                    mainInterfaceView
                } else {
                    VerifyEmailView()
                        .environmentObject(contentViewModel)
                }
            } else {
                LoginView()
            }
        }
    }
}

extension ContentView {
    var mainInterfaceView: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                MainTabView()
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
                } else if showRightMenu {
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
                        }
                    } label: {
                        Circle()
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .environmentObject(contentViewModel)
        .environmentObject(groupsViewModel)
        .environmentObject(feedViewModel)
    }
}
//
//struct Previews_ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
