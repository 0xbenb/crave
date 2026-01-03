import SwiftUI

// Saved recipes screen
struct SavedRecipesView: View {
    @Binding var savedRecipes: [Recipe]
    @State private var selectedCategory: MealCategory = .all
    
    var filteredRecipes: [Recipe] {
        savedRecipes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Text("Saved Recipes")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Category pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MealCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.pink : Color.white)
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Empty state
                    if savedRecipes.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "bookmark.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No saved recipes yet")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            Text("Start swiping to save your favorites!")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                            Spacer()
                        }
                    } else {
                        // Saved recipes grid
                        ScrollView {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 16
                            ) {
                                ForEach(filteredRecipes) { recipe in
                                    NavigationLink(
                                        destination: DetailedRecipeView(recipe: recipe)
                                    ) {
                                        SavedRecipeItem(recipe: recipe)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
