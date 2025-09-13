//
//  FaceDistanceDetector.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/4.
//

import Cocoa
import AVFoundation
import Vision

class FaceDistanceDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var currentFrame: CVPixelBuffer?
    private var captureSession: AVCaptureSession?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var faceDetectionRequest: VNDetectFaceLandmarksRequest?
    private var disInstance: Distance
    
    private let averageEyeWidth: CGFloat = 6.3 // 平均人眼寬度（厘米）
    private let focalLengthInPixels: CGFloat = 930.0/* 相機焦距，以像素為單位 */
    
    override init() {
        disInstance = Distance.getDisInstance()
        super.init()
        setupCaptureSession()
        setupVision()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("無法設置攝像頭輸入: \(error)")
            return
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoDataOutput!) {
            captureSession.addOutput(videoDataOutput!)
        }
    }
    
    private func setupVision() {
        faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: handleFaceDetectionResults)
    }
    
    func startDetection() {
        captureSession?.startRunning()
    }
    
    func stopDetection() {
        captureSession?.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        currentFrame = pixelBuffer
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try imageRequestHandler.perform([faceDetectionRequest!])
        } catch {
            print("執行人臉檢測失敗: \(error)")
        }
    }
    
    private func handleFaceDetectionResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        guard let face = observations.first else { return }
        
        guard let landmarks = face.landmarks else { return }
        guard let leftEyeLandmarks = landmarks.leftEye?.normalizedPoints,
              let rightEyeLandmarks = landmarks.rightEye?.normalizedPoints else { return }
        
        let leftEyeCenter = averagePoint(from: leftEyeLandmarks)
        let rightEyeCenter = averagePoint(from: rightEyeLandmarks)

        guard let currentFrame = currentFrame else { return }
        let frameWidth = CGFloat(CVPixelBufferGetWidth(currentFrame))
        let frameHeight = CGFloat(CVPixelBufferGetHeight(currentFrame))
        
        let borderBoxX = face.boundingBox.minX * frameWidth
        let borderBoxY = face.boundingBox.minY * frameHeight
        let borderBoxWidth = face.boundingBox.width * frameWidth
        let borderBoxHeight = face.boundingBox.height * frameHeight
        
        let leftEyePoint = CGPoint(x: leftEyeCenter.x * borderBoxWidth + borderBoxX,
                                   y: leftEyeCenter.y * borderBoxHeight + borderBoxY)
        let rightEyePoint = CGPoint(x: rightEyeCenter.x * borderBoxWidth + borderBoxX,
                                    y: rightEyeCenter.y * borderBoxHeight + borderBoxY)

        let eyeDistance = hypot(abs(leftEyePoint.x - rightEyePoint.x),
                                abs(rightEyePoint.y  - leftEyePoint.y))
        
        let distance = (self.averageEyeWidth * self.focalLengthInPixels) / CGFloat(eyeDistance)
        
        disInstance.setDistance(dis: distance)
        // print("dis estimation: \(distance)")
    }
    private func averagePoint(from points: [CGPoint]) -> CGPoint {
        let sum = points.reduce(CGPoint.zero) { (result, point) -> CGPoint in
            return CGPoint(x: result.x + point.x, y: result.y + point.y)
        }
        let count = CGFloat(points.count)
        return CGPoint(x: sum.x / count, y: sum.y / count)
    }
}
