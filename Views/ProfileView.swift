import SwiftUI

// User Profile Screen
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
        
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    profileHeader
                    
                    settingsList
                    
                    Spacer()
                    
                    signOutButton
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Profile header with avatar and user info
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            Text(displayName)
                .font(.system(size: 24, weight: .bold))
            
            Text("Exploring delicious recipes")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
    
    // Settings and profile actions list
    private var settingsList: some View {
        VStack(spacing: 0) {
            ProfileTabItem(icon: "person.circle", title: "Edit Profile", color: .blue)
            Divider().padding(.leading, 60)
            
            ProfileTabItem(icon: "bell.fill", title: "Notifications", color: .orange)
            Divider().padding(.leading, 60)
            
            ProfileTabItem(icon: "heart.fill", title: "Favorites", color: .pink)
            Divider().padding(.leading, 60)
            
            ProfileTabItem(icon: "gear", title: "Settings", color: .gray)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // Sign out action
    private var signOutButton: some View {
        Button(action: handleSignOut) {
            Text("Sign Out")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    // Get display name
    private var displayName: String {
        authManager.userName ?? authManager.userEmail ?? "User"
    }
    
    // Sign user out
    private func handleSignOut() {
        authManager.signOut()
    }
}
