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
        .onReceive(
            NotificationCenter.default.publisher(
                for: APIClient.authenticationExpired
            )
        ) { _ in
            auth.handleAuthenticationExpired()
        }
    }
}

#Preview {
    ContentView()
}
