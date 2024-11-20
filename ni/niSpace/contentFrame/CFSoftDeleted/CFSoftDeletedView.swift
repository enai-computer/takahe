//
//  CFSoftDeletedView.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class CFSoftDeletedView: NSBox {

	var myController: ContentFrameController? = nil
	private var deletionCompletionHandler: (()->Void)?
	private var mouseDownFunc: (()->Void)?
	
	private var borderLayer: CAShapeLayer?
	private var animationTime_S: Double = 5.0
	
	@IBOutlet var messageBox: NSTextField!
	@IBOutlet var undoIcon: NSImageView!
	
	override func prepareForReuse() {
		myController = nil
	}
	
	func initAfterViewLoad(message: String, showUndoButton: Bool, animationTime_S: Double = 5.0,
						   borderWidth: CGFloat = 5.0, borderColor: NSColor = .sand4, borderDisappears: Bool = false){
		wantsLayer = true
		layer?.cornerRadius = 10
		layer?.cornerCurve = .continuous

		layer?.backgroundColor = NSColor(.sand4).cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		addTrackingArea(hoverEffectTrackingArea)
		
		if(showUndoButton){
			undoIcon.isHidden = false
		}else{
			undoIcon.isHidden = true
		}
		
		self.messageBox.stringValue = message
		self.animationTime_S = animationTime_S
		
		if(borderDisappears){
			setupBorder(color: borderColor, width: borderWidth)
		}else{
			layer?.borderWidth = borderWidth
			layer?.borderColor = borderColor.cgColor
		}
		
		
		triggerAnimation()
	}
	
	func initAfterViewLoad(_ itemName: String = "group", parentController: ContentFrameController) {
		self.initAfterViewLoad(message: "restore closed \(itemName)", showUndoButton: true)
		self.myController = parentController
		
		self.deletionCompletionHandler = {
			self.myController?.confirmClose()
			self.myController = nil
			self.removeFromSuperview()
		}
		
		self.mouseDownFunc = {
			self.myController?.cancelCloseProcess()
			self.removeFromSuperview()
		}
	}
	
	override func mouseEntered(with event: NSEvent) {
		undoIcon.contentTintColor = NSColor.birkin
		layer?.speed = 0.0
	}
	
	override func mouseExited(with event: NSEvent) {
		undoIcon.contentTintColor = NSColor.sand11
		layer?.speed = 1.0
	}
	
	override func mouseDown(with event: NSEvent) {
		mouseDownFunc?()
		self.deinitSelf()
	}
	
	private func triggerAnimation(){
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = animationTime_S
			self.animator().alphaValue = 0.0
		}, completionHandler: {
			self.deletionCompletionHandler?()
			self.deinitSelf()
		})
	}
	
	override func layout() {
		super.layout()
		borderLayer?.frame = bounds
		let path = NSBezierPath(roundedRect: bounds, xRadius: 10, yRadius: 10)
		borderLayer?.path = path.cgPath
	}
	
	private func startBorderAnimation() {
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.fromValue = 1.0
		opacityAnimation.toValue = 0.0
		opacityAnimation.duration = (animationTime_S / 2.0)
		opacityAnimation.isRemovedOnCompletion = false
		opacityAnimation.fillMode = .forwards
		borderLayer?.add(opacityAnimation, forKey: "strokeColorAnimation")
	}
	
	private func setupBorder(color: NSColor, width borderWidth: CGFloat) {
		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = color.cgColor
		shapeLayer.fillColor = NSColor.clear.cgColor
		shapeLayer.lineWidth = borderWidth
		
		layer?.addSublayer(shapeLayer)
		borderLayer = shapeLayer
		
		startBorderAnimation()
	}
	
	private func deinitSelf(){
		self.deletionCompletionHandler = nil
		self.mouseDownFunc = nil
	}
}
