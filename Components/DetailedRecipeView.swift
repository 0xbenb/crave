import SwiftUI

private let primaryColor = Color(
    red: 239/255,
    green: 68/255,
    blue: 68/255
)

// Recipe in-depth screen
struct DetailedRecipeView: View {
    let recipe: Recipe
    @State private var selectedTab: Tab = .overview
    @State private var imageOffset: CGFloat = 0
    @Namespace private var animation
    
    enum Tab {
        case overview, ingredients, instructions, nutrition
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroImageSection
                contentSection
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var heroImageSection: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: recipe.imageName)) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y: imageOffset)
                        .clipped()
                case .failure:
                    placeholderView
                @unknown default:
                    EmptyView()
                }
            }
            .overlay(gradientOverlay)
            .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                imageOffset = -newValue * 0.5
            }
        }
        .frame(height: 400)
    }
    
    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.4), Color.blue.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            ProgressView()
                .tint(.white)
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.6)],
            startPoint: .center,
            endPoint: .bottom
        )
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            descriptionSection
            tabSelector
            tabContent
        }
        .padding(.top, -40)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color(uiColor: .systemBackground))
                .ignoresSafeArea()
        )
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recipe.tags, id: \.self) { tag in
                        Text(tag.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(primaryColor)
                            )
                    }
                }
                .padding(.horizontal)
            }
            
            Text(recipe.name)
                .font(.system(size: 32, weight: .bold))
                .padding(.horizontal)
        }
    }
    
    private var descriptionSection: some View {
        Text(recipe.description)
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            .lineSpacing(6)
            .padding(.horizontal)
    }
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                TabButton(title: "Overview", icon: "square.grid.2x2", tab: .overview, selectedTab: $selectedTab, animation: animation)
                TabButton(title: "Ingredients", icon: "list.bullet", tab: .ingredients, selectedTab: $selectedTab, animation: animation)
                TabButton(title: "Instructions", icon: "list.number", tab: .instructions, selectedTab: $selectedTab, animation: animation)
                TabButton(title: "Nutrition", icon: "chart.pie.fill", tab: .nutrition, selectedTab: $selectedTab, animation: animation)
            }
            .padding(.horizontal)
        }
    }
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .overview:
                OverviewTab(recipe: recipe)
            case .ingredients:
                IngredientsTab(ingredients: recipe.ingredients)
            case .instructions:
                InstructionsTab(instructions: recipe.instructions)
            case .nutrition:
                NutritionTab(recipe: recipe)
            }
        }
        .padding(.horizontal)
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let tab: DetailedRecipeView.Tab
    @Binding var selectedTab: DetailedRecipeView.Tab
    var animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Group {
                    if selectedTab == tab {
                        Capsule()
                            .fill(primaryColor)
                            .matchedGeometryEffect(id: "tab", in: animation)
                    } else {
                        Capsule()
                            .fill(Color(uiColor: .secondarySystemBackground))
                    }
                }
            )
        }
    }
}

struct OverviewTab: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Facts")
                .font(.system(size: 24, weight: .bold))
                .padding(.top)
            
            VStack(spacing: 12) {
                FactRow(icon: "fork.knife", label: "Origin", value: recipe.origin, color: .orange)
                FactRow(icon: "chart.bar.fill", label: "Difficulty", value: recipe.difficulty, color: primaryColor)
                FactRow(icon: "person.2.fill", label: "Servings", value: "\(recipe.servings) people", color: .green)
                FactRow(icon: "clock.fill", label: "Prep Time", value: recipe.prepTime, color: .blue)
            }
            .padding(.bottom)
        }
    }
}

struct FactRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct IngredientsTab: View {
    let ingredients: [String]
    @State private var checkedItems: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredients")
                .font(.system(size: 24, weight: .bold))
                .padding(.top)
            
            VStack(spacing: 12) {
                ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                    ingredientRow(index: index, ingredient: ingredient)
                }
            }
            .padding(.bottom)
        }
    }
    
    private func ingredientRow(index: Int, ingredient: String) -> some View {
        let isChecked = checkedItems.contains(index)
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isChecked {
                    checkedItems.remove(index)
                } else {
                    checkedItems.insert(index)
                }
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(isChecked ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                }
                
                Text(ingredient)
                    .font(.system(size: 16))
                    .foregroundColor(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
        }
    }
}

struct InstructionsTab: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.system(size: 24, weight: .bold))
                .padding(.top)
            
            VStack(spacing: 16) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    instructionRow(index: index, instruction: instruction)
                }
            }
            .padding(.bottom)
        }
    }
    
    private func instructionRow(index: Int, instruction: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(index + 1)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(primaryColor)
                )
            
            Text(instruction)
                .font(.system(size: 16))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct NutritionTab: View {
    let recipe: Recipe
    
    private var totalMacros: Int {
        recipe.protein + recipe.carbs + recipe.fat
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Facts")
                .font(.system(size: 24, weight: .bold))
                .padding(.top)
            
            caloriesCard
            macronutrientsSection
        }
    }
    
    private var caloriesCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Calories")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(recipe.calories)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(primaryColor)
                Text("kcal per serving")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(primaryColor)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(primaryColor.opacity(0.1))
        )
    }
    
    private var macronutrientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macronutrients")
                .font(.system(size: 18, weight: .bold))
            
            MacroBar(name: "Protein", value: recipe.protein, total: totalMacros, color: .blue)
            MacroBar(name: "Carbs", value: recipe.carbs, total: totalMacros, color: .green)
            MacroBar(name: "Fat", value: recipe.fat, total: totalMacros, color: primaryColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.bottom)
    }
}

struct MacroBar: View {
    let name: String
    let value: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(value)g")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 12)
                }
            }
            .frame(height: 12)
        }
    }
}
