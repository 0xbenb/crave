import SwiftUI

// Simple enum representing swipe outcome (left = skip, right = like).
enum SwipeDirection {
    case left, right
}

// Tinder-style card for browsing recipes with swipe gestures

struct SwipeableRecipeCard: View {
    let recipe: Recipe
    let isTopCard: Bool
    let onRemove: (SwipeDirection) -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    // Threshold for completing a swipe
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main image background
            GeometryReader { proxy in
                AsyncImage(url: URL(string: recipe.imageName)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            }
            .background(Color(white: 0.12))
            .cornerRadius(20)
            
            // Dark gradient for readable text
            LinearGradient(
                colors: [.clear, .black.opacity(0.9)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(20)
            .allowsHitTesting(false)
            
            // Recipe text (name, meta, tags)
            recipeInfo
            
            // Visual feedback while dragging (heart / X)
            swipeIndicator
        }
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(isTopCard ? dragGesture : nil) // Only the top card is draggable
    }
    
    // Recipe information overlay
    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Label(recipe.origin, systemImage: "globe")
                Label(recipe.prepTime, systemImage: "clock")
                Label(recipe.difficulty, systemImage: "chart.bar")
            }
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.9))
            
            if !recipe.tags.isEmpty {
                tagsList
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .allowsHitTesting(false)
    }
    
    // Tags displayed as small chips
    private var tagsList: some View {
        HStack(spacing: 8) {
            ForEach(recipe.tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
    
    // Large heart or X indicator that appears during drag for immediate feedback
    private var swipeIndicator: some View {
        VStack {
            Spacer()
            
            ZStack {
                if offset.width < -20 {
                    Image(systemName: "xmark")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.red)
                        .opacity(min(abs(offset.width) / 100.0, 1))
                        .scaleEffect(1 + min(abs(offset.width) / 400, 0.25))
                } else if offset.width > 20 {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .opacity(min(offset.width / 100.0, 1))
                        .scaleEffect(1 + min(offset.width / 400, 0.25))
                }
            }
            .frame(height: 100)
            .padding(.bottom, 20)
            .allowsHitTesting(false)
        }
    }
        
    // Drag gesture controlling offset and rotation while dragging, and resolving the swipe on end.
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
                rotation = Double(gesture.translation.width / 20)
            }
            .onEnded { gesture in
                handleDragEnd(gesture)
            }
    }
    
    
    // Determine if the card crossed the swipe threshold. If so, animate it off-screen and remove. Otherwise snap back to center.
    private func handleDragEnd(_ gesture: DragGesture.Value) {
        if abs(gesture.translation.width) > swipeThreshold {
            let direction: SwipeDirection = gesture.translation.width > 0 ? .right : .left
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                offset = CGSize(
                    width: gesture.translation.width > 0 ? 500 : -500,
                    height: gesture.translation.height
                )
                rotation = gesture.translation.width > 0 ? 20 : -20
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onRemove(direction)
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                offset = .zero
                rotation = 0
            }
        }
    }
}
