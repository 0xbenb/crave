import SwiftUI

// Tab bar for switching between app sections
struct NavBar: View {
    @State private var selectedTab = 0
    @State private var savedRecipes: [Recipe] = []
        
    var body: some View {
        TabView(selection: $selectedTab) {
            discoverTab
            savedTab
            profileTab
        }
        .accentColor(.black)
    }
        
    // Discover Tab
    private var discoverTab: some View {
        HomeView(savedRecipes: $savedRecipes)
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text("Discover")
            }
            .tag(0)
    }
    
    // Saved Recipes Tab
    private var savedTab: some View {
        SavedRecipesView(savedRecipes: $savedRecipes)
            .tabItem {
                Image(systemName: selectedTab == 1 ? "bookmark.fill" : "bookmark")
                Text("Saved")
            }
            .tag(1)
    }
    
    // Profile Tab
    private var profileTab: some View {
        ProfileView()
            .tabItem {
                Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                Text("Profile")
            }
            .tag(2)
    }
}
