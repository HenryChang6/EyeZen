//
//  BlurController.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/9.
//

import Foundation
import Cocoa

class BlurController {
    private var window: NSWindow?

    public func setupBlurWindow() {
        let screenSize = NSScreen.main!.frame
        window = NSWindow(contentRect: screenSize,
                          styleMask: [.borderless],
                          backing: .buffered,
                          defer: false)
        window?.isReleasedWhenClosed = false
        window?.level = .popUpMenu
        window?.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.ignoresMouseEvents = true

        let blurView = NSVisualEffectView(frame: window!.contentView!.bounds)
        blurView.autoresizingMask = [.width, .height]
        blurView.blendingMode = .behindWindow
        blurView.state = .active
        blurView.material = .fullScreenUI
        blurView.alphaValue = 1.0
        window?.contentView?.addSubview(blurView)

        window?.makeKeyAndOrderFront(nil)
    }

    public func updateBlur(distance: CGFloat, enable_blur: Bool, preffered_distance: CGFloat) {
        let alphaValue: CGFloat;
        if(distance >= preffered_distance || enable_blur == false) {
            alphaValue = 0.0
        } else {
            alphaValue = (100.0 - distance) * 0.0125
            // alphaValue = exp(-distance / 55.0)
        }
        if let contentView = window?.contentView {
            for view in contentView.subviews where view is NSVisualEffectView {
                (view as! NSVisualEffectView).alphaValue = alphaValue
            }
        }
    }

    public func hideBlur() {
        window?.orderOut(nil)
    }
}
