import Cocoa

class BlurWindowController: NSWindowController {
    private var blurView: NSVisualEffectView!
    private var instructionLabel: NSView?

    convenience init() {
        let screenFrame = NSScreen.main!.frame

        let blurView = NSVisualEffectView(frame: screenFrame)
        blurView.material = .hudWindow
        blurView.blendingMode = .behindWindow
        blurView.state = .active
        blurView.alphaValue = 0.0

        let contentView = NSView(frame: screenFrame)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        contentView.addSubview(blurView)

        let window = NSWindow(contentRect: screenFrame,
                              styleMask: [.borderless],
                              backing: .buffered,
                              defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .mainMenu + 1
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = contentView

        self.init(window: window)
        self.blurView = blurView
        self.window?.orderFrontRegardless()      // ✅ 改用這個，讓它顯示但不搶主視窗
    }

    func setBlurAlpha(_ alpha: CGFloat) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.blurView.animator().alphaValue = alpha
        }
    }

    func hideBlur() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.blurView.animator().alphaValue = 0.0
        }
    }

    func showInstruction(_ text: String) {
        // 如果已經加過，更新文字即可
        if let existing = instructionLabel {
            (existing as? NSTextView)?.string = text
            existing.superview?.isHidden = false
            return
        }

        let width: CGFloat = 500
        let height: CGFloat = 100
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        // 毛玻璃背景框
        let background = NSVisualEffectView(frame: frame)
        background.material = .hudWindow
        background.blendingMode = .withinWindow
        background.state = .active
        background.wantsLayer = true
        background.layer?.cornerRadius = 12
        background.layer?.masksToBounds = true
        background.alphaValue = 0.9
        background.identifier = NSUserInterfaceItemIdentifier("InstructionBackground")

        // 使用 NSTextView 來做多行 + 垂直水平置中
        let textView = NSTextView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        textView.string = text
        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = NSSize(width: 20, height: 25) // 內距達成垂直置中
        textView.alignment = .center
        textView.font = NSFont(name: "Helvetica Neue", size: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.textContainer?.lineFragmentPadding = 0

        background.addSubview(textView)
        self.instructionLabel = textView

        if let content = self.window?.contentView {
            background.setFrameOrigin(CGPoint(
                x: (content.frame.width - width) / 2,
                y: (content.frame.height - height) / 2
            ))
            content.addSubview(background)
        }
    }

    func hideInstruction() {
        instructionLabel?.superview?.isHidden = true
    }
}

