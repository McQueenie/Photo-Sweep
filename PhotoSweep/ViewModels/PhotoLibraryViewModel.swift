import Foundation
import Photos
import SwiftUI
import Combine
import UIKit

class PhotoLibraryViewModel: ObservableObject {
    @Published var photos: [PhotoModel] = []
    @Published var currentIndex: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var errorMessage: String?
    @Published var isImageLoaded: Bool = false
    @Published var isDeleting: Bool = false
    
    // Using this to force a refresh of the PhotoCardView when needed
    @Published var refreshID = UUID()
    
    private var allAssets: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private var imageRequestID: PHImageRequestID?
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        let status = PHPhotoLibrary.authorizationStatus()
        handleAuthorizationStatus(status)
    }
    
    func requestPermissions() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.handleAuthorizationStatus(status)
            }
        }
    }
    
    private func handleAuthorizationStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited:
            isAuthorized = true
            fetchPhotos()
        case .denied, .restricted:
            isAuthorized = false
            errorMessage = "Access to photos was denied. Please enable access in Settings."
        case .notDetermined:
            requestPermissions()
        @unknown default:
            isAuthorized = false
            errorMessage = "Unknown authorization status."
        }
    }
    
    func fetchPhotos() {
        isImageLoaded = false
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allAssets = PHAsset.fetchAssets(with: .image, options: options)
        
        photos.removeAll()
        
        if let assets = allAssets, assets.count > 0 {
            for i in 0..<assets.count {
                let asset = assets[i]
                let photo = PhotoModel(asset: asset)
                photos.append(photo)
            }
            
            currentIndex = 0
            refreshID = UUID() // Force a refresh of the view
            loadImageForCurrentIndex()
        } else {
            isImageLoaded = true
        }
    }
    
    func moveToNextPhoto() {
        guard currentIndex < photos.count - 1 else { return }
        
        isImageLoaded = false
        currentIndex += 1
        refreshID = UUID() // Force a refresh of the view
        loadImageForCurrentIndex()
    }
    
    func deleteCurrentPhoto() {
        guard !isDeleting && !photos.isEmpty && currentIndex < photos.count else { return }
        
        // Set state to deleting
        isDeleting = true
        isImageLoaded = false
        
        // Keep track of the photo to delete and its index
        let photoToDelete = photos[currentIndex]
        let indexToDelete = currentIndex
        
        // First step: Delete from Photos library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([photoToDelete.asset] as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to delete: \(error.localizedDescription)"
                    self?.isDeleting = false
                    self?.isImageLoaded = true
                    return
                }
                
                guard success else {
                    self?.errorMessage = "Failed to delete photo"
                    self?.isDeleting = false
                    self?.isImageLoaded = true
                    return
                }
                
                // Delete was successful, now update the UI
                guard let self = self else { return }
                
                // Second step: Update our internal data structure
                if indexToDelete < self.photos.count {
                    self.photos.remove(at: indexToDelete)
                }
                
                // Third step: Handle the empty case
                if self.photos.isEmpty {
                    self.isDeleting = false
                    self.isImageLoaded = true
                    return
                }
                
                // Fourth step: Update current index if needed
                if indexToDelete >= self.photos.count {
                    self.currentIndex = self.photos.count - 1
                } else {
                    self.currentIndex = indexToDelete
                }
                
                // Fifth step: Force a complete refresh
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshID = UUID()
                    self.isDeleting = false
                    self.loadImageForCurrentIndex()
                }
            }
        }
    }
    
    func keepCurrentPhoto() {
        moveToNextPhoto()
    }
    
    private func loadImageForCurrentIndex() {
        // Safety check
        guard !photos.isEmpty && currentIndex < photos.count else {
            isImageLoaded = true
            return
        }
        
        // Cancel any pending request
        if let requestID = imageRequestID {
            imageManager.cancelImageRequest(requestID)
        }
        
        // Already cached?
        if photos[currentIndex].image != nil {
            isImageLoaded = true
            return
        }
        
        // Set up the request
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        // Make the request
        imageRequestID = imageManager.requestImage(
            for: photos[currentIndex].asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, info in
            DispatchQueue.main.async {
                guard let self = self, 
                      !self.photos.isEmpty, 
                      self.currentIndex < self.photos.count else { return }
                
                if let image = image {
                    self.photos[self.currentIndex].image = image
                    self.isImageLoaded = true
                } else if let error = info?[PHImageErrorKey] as? Error {
                    // Try again with a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.loadImageForCurrentIndex()
                    }
                }
            }
        }
    }
} 