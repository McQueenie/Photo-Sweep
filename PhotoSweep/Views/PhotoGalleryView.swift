import SwiftUI

struct PhotoGalleryView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if !viewModel.isAuthorized {
                    PermissionView(
                        requestPermission: viewModel.requestPermissions,
                        errorMessage: viewModel.errorMessage
                    )
                } else if viewModel.photos.isEmpty {
                    EmptyStateView(refreshAction: viewModel.fetchPhotos)
                } else {
                    VStack {
                        // Main content
                        if viewModel.currentIndex < viewModel.photos.count {
                            ZStack {
                                // Card view - notice we use both currentIndex and refreshID for the unique identifier
                                PhotoCardView(
                                    photo: viewModel.photos[viewModel.currentIndex],
                                    onSwipeLeft: {
                                        viewModel.deleteCurrentPhoto()
                                    },
                                    onSwipeRight: {
                                        viewModel.keepCurrentPhoto()
                                    }
                                )
                                .id("\(viewModel.currentIndex)-\(viewModel.refreshID)")
                                .opacity(viewModel.isImageLoaded ? 1 : 0.5)
                                .allowsHitTesting(viewModel.isImageLoaded && !viewModel.isDeleting)
                                
                                // Loading or deletion indicator
                                if !viewModel.isImageLoaded || viewModel.isDeleting {
                                    VStack {
                                        ProgressView(viewModel.isDeleting ? "Deleting..." : "Loading...")
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(1.2)
                                        
                                        Text(viewModel.isDeleting ? "Please wait" : "Loading photo")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .padding(.top, 8)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground).opacity(0.9))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                }
                            }
                            .frame(maxHeight: .infinity)
                        } else if viewModel.photos.isEmpty {
                            EmptyStateView(refreshAction: viewModel.fetchPhotos)
                        } else {
                            // This is an edge case - we have photos but currentIndex is invalid
                            Text("Invalid photo index. Please try refreshing.")
                                .padding()
                                .onAppear {
                                    if !viewModel.photos.isEmpty {
                                        viewModel.currentIndex = 0
                                    }
                                }
                        }
                        
                        // Control buttons
                        HStack(spacing: 70) {
                            // Delete button
                            Button {
                                viewModel.deleteCurrentPhoto()
                            } label: {
                                VStack {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.red)
                                    
                                    Text("Delete")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .disabled(!viewModel.isImageLoaded || viewModel.isDeleting || 
                                     viewModel.photos.isEmpty || viewModel.currentIndex >= viewModel.photos.count)
                            
                            // Keep button
                            Button {
                                viewModel.keepCurrentPhoto()
                            } label: {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green)
                                        
                                    Text("Keep")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .disabled(!viewModel.isImageLoaded || viewModel.isDeleting || 
                                     viewModel.photos.isEmpty || viewModel.currentIndex >= viewModel.photos.count)
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 10)
                        .opacity(viewModel.isDeleting ? 0.5 : 1)
                    }
                }
                
                // Error overlay
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                            .onTapGesture {
                                viewModel.errorMessage = nil
                            }
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: viewModel.errorMessage != nil)
                    .zIndex(1) // Ensure it's above everything else
                }
            }
            .navigationTitle("PhotoSweep")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.fetchPhotos()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isDeleting)
                }
            }
        }
    }
}

struct AlertIdentifiable: Identifiable {
    var id: String
    var message: String
} 