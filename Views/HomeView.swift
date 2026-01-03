import SwiftUI

// Home screen with swipeable recipe cards
struct HomeView: View {
    @Binding var savedRecipes: [Recipe]
    @State private var recipes: [Recipe] = []
    @State private var currentIndex = 0
    
    private let maxVisibleCards = 3
    private let cardStackOffset: CGFloat = 10
    private let cardStackScale: CGFloat = 0.95
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    Spacer()
                    
                    cardStackView
                    
                    actionButtons
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            await loadRecipes()
        }
    }
    
    // App header with logo and filter button
    private var headerView: some View {
        HStack {
            Image("crave")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            
            Text("Crave")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // Stack of swipeable recipe cards
    private var cardStackView: some View {
        ZStack {
            ForEach(recipes.indices.reversed(), id: \.self) { index in
                if isCardVisible(at: index) {
                    SwipeableRecipeCard(
                        recipe: recipes[index],
                        isTopCard: index == currentIndex,
                        onRemove: { direction in
                            handleSwipe(direction: direction)
                        }
                    )
                    .offset(y: cardOffset(for: index))
                    .scaleEffect(cardScale(for: index))
                    .opacity(cardOpacity(for: index))
                    .zIndex(Double(recipes.count - index))
                }
            }
            
            // Show empty state when all cards are swiped
            if currentIndex >= recipes.count {
                EmptyFeed()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    // Like and dislike action buttons
    private var actionButtons: some View {
        HStack(spacing: 40) {
            // Dislike button
            Button(action: handleDislike) {
                Image(systemName: "xmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Like button
            Button(action: handleLike) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }
        
    // Determines if a card at the given index should be visible in the stack
    private func isCardVisible(at index: Int) -> Bool {
        index >= currentIndex && index < currentIndex + maxVisibleCards
    }
    
    // Calculates the vertical offset for a card based on its position in the stack
    private func cardOffset(for index: Int) -> CGFloat {
        CGFloat(index - currentIndex) * cardStackOffset
    }
    
    // Calculates the scale factor for a card based on its position in the stack
    private func cardScale(for index: Int) -> CGFloat {
        index == currentIndex ? 1.0 : cardStackScale
    }
    
    // Calculates the opacity for a card based on its position in the stack
    private func cardOpacity(for index: Int) -> Double {
        index == currentIndex ? 1.0 : 0.5
    }
    
    // Handles card swipe gestures
    private func handleSwipe(direction: SwipeDirection) {
        if direction == .right {
            savedRecipes.append(recipes[currentIndex])
        }
        advanceToNextCard()
    }
    
    // Handles like button tap
    private func handleLike() {
        guard currentIndex < recipes.count else { return }
        savedRecipes.append(recipes[currentIndex])
        advanceToNextCard()
    }
    
    // Handles dislike button tap
    private func handleDislike() {
        advanceToNextCard()
    }
    
    // Advances to the next card in the stack
    private func advanceToNextCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentIndex += 1
        }
    }
    
    // Loads recipe data asynchronously
    private func loadRecipes() async {
        do {
            recipes = try await RecipeData.load()
        } catch {
            print("Failed to load recipes: \(error.localizedDescription)")
        }
    }
}
