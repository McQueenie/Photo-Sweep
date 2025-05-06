import SwiftUI

struct PermissionView: View {
    let requestPermission: () -> Void
    let errorMessage: String?
    
    init(requestPermission: @escaping () -> Void, errorMessage: String?) {
        self.requestPermission = requestPermission
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Photo Access Required")
                .font(.title)
                .fontWeight(.bold)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("PhotoSweep needs access to your photo library to help you organize your photos.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                requestPermission()
            }) {
                Text("Grant Permission")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top)
            }
        }
        .padding()
    }
} 