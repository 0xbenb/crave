import FirebaseFirestore
import Foundation

// Recipe data model
struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let imageName: String
    let origin: String
    let prepTime: String
    let servings: Int
    let difficulty: String
    let tags: [String]
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let ingredients: [String]
    let instructions: [String]
}
