import SwiftUI

// Compact card used in a grid to display a saved recipe.
// Displays recipe image, name, quick metadata, and a bookmark indicator.

struct SavedRecipeItem: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: recipe.imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(width: 160, height: 140)
                .clipped()
                .cornerRadius(12)
                
                Button(action: {}) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.pink)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Circle().fill(Color.white))
                        .padding(8)
                }
            }
            .frame(height: 140)
            
            Text(recipe.name)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
            
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text(recipe.prepTime)
                    .font(.system(size: 11))
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                Text(recipe.difficulty)
                    .font(.system(size: 11))
            }
            .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
    }
}
