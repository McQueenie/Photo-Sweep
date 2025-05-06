import SwiftUI

struct EmptyStateView: View {
    let refreshAction: () -> Void
    
    init(refreshAction: @escaping () -> Void) {
        self.refreshAction = refreshAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Photos to Review")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You've gone through all your photos or there are no photos in your library.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                refreshAction()
            }) {
                Text("Refresh")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
} 