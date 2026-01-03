import SwiftUI

// Purpose: Shown when there are no new items in the feed
// Goal: Reassure that nothing is missing and encourage them to return later

struct EmptyFeed: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("You're all caught up!")
                .font(.system(size: 24, weight: .bold))
            
            Text("Check back later for more recipes")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}
