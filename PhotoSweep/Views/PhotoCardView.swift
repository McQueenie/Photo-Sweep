import SwiftUI
import UIKit

struct PhotoCardView: View {
    let photo: PhotoModel
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var hasImage: Bool = false
    
    private var swipeThreshold: CGFloat = 100
    
    // Explicit initializer
    init(photo: PhotoModel, onSwipeLeft: @escaping () -> Void, onSwipeRight: @escaping () -> Void) {
        self.photo = photo
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }
    
    var body: some View {
        ZStack {
            // Photo or placeholder
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onAppear {
                        hasImage = true
                    }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .onAppear {
                        hasImage = false
                    }
            }
            
            // Swipe left indicator (red X)
            VStack {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 100))
                        .opacity(Double(-offset.width) / 100.0 - 0.2)
                        .padding(.top, 30)
                        .padding(.leading, 30)
                    Spacer()
                }
                Spacer()
            }
            .opacity(offset.width < 0 ? 1 : 0)
            
            // Swipe right indicator (green checkmark)
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 100))
                        .opacity(Double(offset.width) / 100.0 - 0.2)
                        .padding(.top, 30)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
            .opacity(offset.width > 0 ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .offset(offset)
        .rotationEffect(Angle(degrees: rotation))
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    // Only respond if we have an image
                    guard hasImage else { return }
                    
                    offset = gesture.translation
                    rotation = Double(gesture.translation.width / 20)
                }
                .onEnded { gesture in
                    // Only respond if we have an image
                    guard hasImage else { return }
                    
                    if gesture.translation.width < -swipeThreshold {
                        // Swipe left - delete
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset.width = -500
                        }
                        
                        // Call the deletion action after a very brief animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            offset = .zero // Reset for next appearance
                            rotation = 0
                            onSwipeLeft()
                        }
                    } else if gesture.translation.width > swipeThreshold {
                        // Swipe right - keep
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset.width = 500
                        }
                        
                        // Call the keep action after a very brief animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            offset = .zero // Reset for next appearance
                            rotation = 0
                            onSwipeRight()
                        }
                    } else {
                        // Reset position if not a full swipe
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
        .onAppear {
            // Reset state every time the view appears
            offset = .zero
            rotation = 0
            hasImage = photo.image != nil
        }
    }
} 