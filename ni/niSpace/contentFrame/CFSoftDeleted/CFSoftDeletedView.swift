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
	
	private var animationTriggered: Bool = false
	private var animationTime_S: Double = 5.0
	
	@IBOutlet var messageBox: NSTextField!
	@IBOutlet var undoIcon: NSImageView!
	
	override func prepareForReuse() {
		myController = nil
	}
	
	func initAfterViewLoad(message: String, showUndoButton: Bool, animationTime_S: Double = 5.0){
		wantsLayer = true
		layer?.cornerRadius = 10
		layer?.cornerCurve = .continuous
		layer?.borderWidth = 5
		layer?.borderColor = NSColor(.sand4).cgColor
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
		if(animationTriggered){
			return
		}
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = animationTime_S
			self.animator().alphaValue = 0.0
		}, completionHandler: {
			self.deletionCompletionHandler?()
			self.deinitSelf()
		})
	}
	
	private func deinitSelf(){
		self.deletionCompletionHandler = nil
		self.mouseDownFunc = nil
	}
}
