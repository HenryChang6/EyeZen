//
//  AppDelegate.swift
//  EyeZen
//
//  Created by Bryan Chan on 2025/5/17.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var blurWindow: BlurWindowController?
    var cameraManager: CameraManager?
    
    private var didShowCalibrationTip = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        blurWindow = BlurWindowController()
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.cameraManager = CameraManager(blurWindow: self.blurWindow!)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }
}

