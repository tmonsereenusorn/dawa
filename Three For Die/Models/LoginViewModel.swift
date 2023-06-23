//
//  LoginViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/21/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
}
