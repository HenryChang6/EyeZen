//
//  StatusBarController.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/10.
//

import Foundation

import Cocoa

class StatusBarController {
    private var statusItem: NSStatusItem?
    private var faceRecognitionEnabled: Bool = true
    private var preferredDistance = 45.0
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "StatusBarIcon")
        }
        
        constructMenu()
    }

    private func constructMenu() {
        let menu = NSMenu()
        
        // Item that determine the blur effect
        let toggleItem = NSMenuItem(title: "Enable Blur Effect", action: #selector(toggleFaceDetection), keyEquivalent: "")
        toggleItem.state = faceRecognitionEnabled ? .on : .off
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        // Item that determine the distance
        let distanceItem = NSMenuItem()
        let sliderView = SliderMenuItemView(value: CGFloat(preferredDistance), minValue: 40.0, maxValue: 50.0, target: self, action: #selector(distanceSliderChanged(sender:)))
        distanceItem.view = sliderView
        distanceItem.view = sliderView
        menu.addItem(distanceItem)
   
        // Item that can help you quit the app
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func toggleFaceDetection(sender: NSMenuItem) {
        faceRecognitionEnabled = !faceRecognitionEnabled
        sender.state = faceRecognitionEnabled ? .on : .off
    }
    
    @objc func distanceSliderChanged(sender: NSSlider) {
            preferredDistance = CGFloat(sender.doubleValue)
            // Update the label when slider changes
            if let sliderView = sender.superview as? SliderMenuItemView {
                sliderView.updateLabel()
            }
        }
    
    public func getState() -> Bool{
        return faceRecognitionEnabled
    }
    public func getPrefferedDistance() -> CGFloat {
        return CGFloat(preferredDistance)
    }
}

class SliderMenuItemView: NSView {
    var slider: NSSlider
    var label: NSTextField

    init(value: Double, minValue: CGFloat, maxValue: CGFloat, target: AnyObject?, action: Selector?) {
        slider = NSSlider(value: value, minValue: minValue, maxValue: maxValue, target: target, action: action)
        label = NSTextField(string: String(format: "Distance: %.1f", value))
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.alignment = .left
        label.font = NSFont.systemFont(ofSize: 12)

        super.init(frame: NSRect(x: 0, y: 0, width: 250, height: 40))

        slider.frame = NSRect(x: 120, y: 10, width: 145, height: 20)
        label.frame = NSRect(x: 10, y: 10, width: 105, height: 20)

        addSubview(slider)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateLabel() {
        label.stringValue = String(format: "Distance: %.1f", slider.doubleValue)
    }

}
