import Foundation
import SwiftUI

// This file contains info.plist keys definitions for photo permissions
// Add these keys to your Info.plist file in Xcode:
// 1. NSPhotoLibraryUsageDescription - "PhotoSweep needs access to your photo library to help you organize and manage your photos."
// 2. NSPhotoLibraryAddUsageDescription - "PhotoSweep needs permission to save photos to your library."

// An empty class to force inclusion of this file in build
class PhotoLibraryPermissions {
    static let shared = PhotoLibraryPermissions()
    private init() {}
} 