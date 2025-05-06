import Foundation
import Photos
import UIKit

struct PhotoModel: Identifiable, Equatable {
    let id: String
    let asset: PHAsset
    
    var image: UIImage?
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.image = nil
    }
    
    // Implement Equatable
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        return lhs.id == rhs.id
    }
} 