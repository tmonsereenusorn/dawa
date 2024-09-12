//
//  ContentView.swift
//  DAWA
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
    
    var body: some View {
        Group {
            if let userSession = contentViewModel.userSession {
                if userSession.isEmailVerified {
                    MainTabView()
                        .environmentObject(contentViewModel)
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

//
//struct Previews_ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
