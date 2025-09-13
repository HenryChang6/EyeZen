# Icaps

Icaps is a macOS application that estimates the distance between the user and their screen using the device's camera and applies a blur effect when the user is too close. The app features a menu bar interface for toggling the blur effect and adjusting the preferred distance threshold.

## Features

- Real-time face detection and distance estimation using the camera
- Automatic blur overlay when the user is closer than the preferred distance
- Menu bar controls for enabling/disabling blur and setting the preferred distance
- Written in Swift with AVFoundation, Vision, and Cocoa frameworks

## Requirements

- macOS 14.3 or later
- Xcode 15.4 or later
- Camera access permission

## Installation

1. Clone this repository.
2. Open `Icaps.xcodeproj` in Xcode.
3. Ensure you have a camera connected and grant camera access when prompted.
4. Build and run the app.

## Usage

- The app runs in the menu bar.
- Use the menu to enable/disable the blur effect.

## Some Demo pictures
<p align="center">
	<img src="DemoPictures/Screenshot 2025-09-13 at 3.35.43 PM.png" alt="Demo Screenshot 1" width="400"/>
	<img src="DemoPictures/Screenshot 2025-09-13 at 5.56.50 PM.png" alt="Demo Screenshot 2" width="400"/>
</p>
