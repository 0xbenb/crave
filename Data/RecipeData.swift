import FirebaseFirestore

// Fetches recipes from Firestore
enum RecipeData {
    static func load() async throws -> [Recipe] {
        let snapshot = try await Firestore.firestore()
            .collection("recipes")
            .getDocuments()
        
        // Decode Firestore documents into Recipe models
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }
}
