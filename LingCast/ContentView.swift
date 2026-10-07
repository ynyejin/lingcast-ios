//
//  ContentView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var auth = AuthSession()

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environment(auth)
    }
}

#Preview {
    ContentView()
}
