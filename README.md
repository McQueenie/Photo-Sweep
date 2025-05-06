# Photo Sweep
PhotoSweep is an iOS app that helps you clean up your photo library using a Tinder-like swiping interface. Quickly browse through your photos, swiping right to keep or left to delete, making photo management fast and intuitive. Saw a similar idea on a ad, yet I don't trust random apps with my private photos.

## Features

- **Intuitive Swipe Interface**: Swipe left to delete photos, right to keep them
- **Visual Feedback**: Clear visual indicators show your swipe actions
- **Button Controls**: Alternative buttons for deleting or keeping photos

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/PhotoSweep.git
```

2. Open the project in Xcode:
```bash
cd PhotoSweep
open PhotoSweep.xcodeproj
```

3. Build and run the application on your iOS device or simulator.

## Usage

1. Grant the app permission to access your photo library when prompted
2. Browse through your photos with swipe gestures:
   - Swipe left to delete a photo
   - Swipe right to keep a photo
3. Alternatively, use the buttons at the bottom of the screen
4. Use the refresh button to reload your photo library

## How It Works

PhotoSweep uses Apple's Photos framework to access your photo library. When you delete a photo, iOS will ask for confirmation before permanently removing it from your library. Deleted photos are moved to the "Recently Deleted" album in the Photos app, where they remain for 30 days before being permanently removed.

## Technical Details

- Built with SwiftUI and the Photos framework
- MVVM architecture for clean separation of concerns
- Uses PHPhotoLibrary for photo management
- Implements custom gestures for the swiping interface

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the Tinder swipe card interface
- Thanks to Apple for the Photos framework
