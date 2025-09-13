//
//  AppDelegate.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/1.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var faceDetector: FaceDistanceDetector?
    private var globalBlurController: BlurController?
    var statusBarController: StatusBarController?
    private let disInstance = Distance.getDisInstance()
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusBarController = StatusBarController()
        faceDetector = FaceDistanceDetector()
        faceDetector?.startDetection()
        globalBlurController = BlurController()
        
        globalBlurController?.setupBlurWindow()
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.checkDistanceAndUpdateBlur()
        }
        
    }

    private func checkDistanceAndUpdateBlur() {
        let dis = disInstance.getDistance()
        let state: Bool = self.statusBarController?.getState() ?? false
        let prefferedDis: CGFloat = self.statusBarController?.getPrefferedDistance() ?? 45.0
        globalBlurController?.updateBlur(distance: dis, enable_blur: state, preffered_distance: prefferedDis)
    }

    public func applicationWillTerminate(_ aNotification: Notification) {
        globalBlurController?.hideBlur()
        faceDetector?.stopDetection()
    }
}

//class AppDelegate: NSObject, NSApplicationDelegate {
//    
//    var globalBlurController: GlobalBlurController?
//    
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Set Timer to check distance and update blur effect
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            self.checkDistanceAndUpdateBlur()
//        }
//    }
//    
//    // Check Distance and adjust blur effect
//    func checkDistanceAndUpdateBlur() {
//        // TODO: 在這裡實現實際的距離檢測邏輯
//        // 暫時使用固定值進行測試
//        let distance = 30
//        
//        if distance < 50 {
//            globalBlurController?.showBlur()
//        } else {
//            globalBlurController?.hideBlur()
//        }
//    }
//    
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // 在應用終止時清理資源
//        globalBlurController?.hideBlur()
//    }
//}
