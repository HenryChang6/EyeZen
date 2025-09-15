import AVFoundation
import Vision
import Cocoa

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let blurWindow: BlurWindowController

    private var isCalibrating = true
    private var didShowCalibrationTip = false
    private var focalLength: CGFloat? = nil
    private let realEyeDistanceCm: CGFloat = 6.3   // W
    private let calibrationDistanceCm: CGFloat = 50.0 // d during calibration

    init(blurWindow: BlurWindowController) {
        self.blurWindow = blurWindow
        super.init()
        setupCamera()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 36 { // Enter
                self?.isCalibrating = false
                self?.blurWindow.hideInstruction()
                print("✅ Calibration finished! f = \(self?.focalLength ?? -1)")
            }
            return event
        }
    }

    private func setupCamera() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )

        for device in discoverySession.devices {
            print("🔍 Found camera: \(device.localizedName)")
        }

        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Unable to open camera")
            return
        }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
        }

        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let bufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let bufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

        print("📸 Image resolution: \(Int(bufferWidth)) x \(Int(bufferHeight))")
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }

            if let results = request.results as? [VNFaceObservation],
               let face = results.first,
               let landmarks = face.landmarks,
               let leftEye = landmarks.leftEye,
               let rightEye = landmarks.rightEye {

                let l = leftEye.normalizedPoints[4]
                let r = rightEye.normalizedPoints[0]
                let faceBox = face.boundingBox

                // 將 normalized 座標轉成 pixel 座標
                let lx = (faceBox.origin.x + l.x * faceBox.size.width) * bufferWidth
                let ly = (1.0 - (faceBox.origin.y + l.y * faceBox.size.height)) * bufferHeight
                let rx = (faceBox.origin.x + r.x * faceBox.size.width) * bufferWidth
                let ry = (1.0 - (faceBox.origin.y + r.y * faceBox.size.height)) * bufferHeight

                let dx = rx - lx
                let dy = ry - ly
                let w = sqrt(dx * dx + dy * dy) // 👈 pixel 單位的兩眼間距

                if self.isCalibrating {
                    // 顯示提示（僅一次）
                    if !self.didShowCalibrationTip {
                        DispatchQueue.main.async {
                            self.blurWindow.showInstruction("""
Calibrating... Please stay 50 cm away from the screen.
Press ⏎ Enter to finish calibration.
""")
                        }
                        self.didShowCalibrationTip = true
                    }

                    // 計算焦距（像素單位）
                    let f = (w * self.calibrationDistanceCm) / self.realEyeDistanceCm
                    self.focalLength = f

                    DispatchQueue.main.async {
                        self.blurWindow.setBlurAlpha(0.5)
                    }

                    print("📏 Calibrating... f = \(f)")

                } else if let f = self.focalLength {
                    // 使用 f 推估距離
                    let d = (self.realEyeDistanceCm * f) / w
                    print("📐 Estimated distance: \(d) cm")

                    let blurStrength = map(value: d, inMin: 30, inMax: 50, outMin: 1.0, outMax: 0.0)
                    DispatchQueue.main.async {
                        self.blurWindow.setBlurAlpha(blurStrength)
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.blurWindow.hideBlur()
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([request])
    }
}

func map(value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
    let clamped = min(max(value, inMin), inMax)
    return outMin + (clamped - inMin) * (outMax - outMin) / (inMax - inMin)
}
