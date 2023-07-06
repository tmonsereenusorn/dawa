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
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showMenu = false
    
    var body: some View {
        Group {
            if let userSession = authViewModel.userSession {
                if userSession.isEmailVerified {
                    mainInterfaceView
                } else {
                    VerifyEmailView()
                        .environmentObject(authViewModel)
                }
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    var mainInterfaceView: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                MainTabView()
                    .navigationBarHidden(showMenu)
                
                if showMenu {
                    ZStack {
                        Color(.black)
                            .opacity(showMenu ? 0.25 : 0.0)
                    }.onTapGesture {
                        withAnimation(.easeInOut) {
                            showMenu = false
                        }
                    }
                    .ignoresSafeArea()
                }
                
                SideMenuView()
                    .frame(width: 300)
                    .background(showMenu ? Color.white : Color.clear)
                    .offset(x: showMenu ? 0 : -300, y: 0)
            }
            .navigationTitle("Stanford")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) {
                            showMenu.toggle()
                        }
                    } label: {
                        Circle()
                            .frame(width: 32, height: 32)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Circle()
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
}
