//
//  TextField.swift
//  ni
//
//  Created by Patrick Lukas on 7/6/24.
//

import Cocoa
import Foundation

class NiTextField: NSTextField{
	
	@IBInspectable public var hasHoverEffect: Bool = false
	@IBInspectable public var hoverTint: NSColor? = NSColor.birkin
	@IBInspectable public var hoverBackground: NSColor? = nil
	@IBInspectable public var hoverCursor: NSCursor? = nil
	
	private var nonHoverTint: NSColor? = nil
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
		font = NSFont(name: "Sohne-Kraftig", size: 14.0)
		textColor = NSColor.sand12
		backgroundColor = NSColor.transparent
		isBezeled = false
		drawsBackground = false
		focusRingType = .none
		importsGraphics = false
		lineBreakMode = .byTruncatingTail
		alignment = .left
		
		setupLayer()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		focusRingType = .none
		importsGraphics = false
		setupLayer()
	}
	
	private func setupLayer(){
		wantsLayer = true
		layer?.backgroundColor = .clear
		layer?.cornerRadius = 4.0
		layer?.cornerCurve = .continuous
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let hoverEffect = NSTrackingArea(rect: self.bounds,
										 options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited],
										 owner: self,
										 userInfo: nil)
		addTrackingArea(hoverEffect)		
	}
	
	override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
		super.sendAction(action, to: target)
	}
	
	override func cancelOperation(_ sender: Any?) {
		let notification = Notification(
			name: NSTextField.textDidEndEditingNotification,
			object: self,
			userInfo: ["NSTextMovement": NSTextMovement.cancel])
		delegate?.controlTextDidEndEditing?(notification)
		return
	}
	
	override func mouseEntered(with event: NSEvent) {
		guard isEditable == false && hasHoverEffect else {return}
		if(hoverTint != nil){
			nonHoverTint = self.textColor
			self.textColor = hoverTint
		}
		if(hoverBackground != nil){
			layer?.backgroundColor = hoverBackground?.cgColor
		}
		if(hoverCursor != nil){
			hoverCursor?.push()
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		guard isEditable == false && hasHoverEffect else {return}
		if(hoverTint != nil){
			self.textColor = nonHoverTint
		}
		if(hoverBackground != nil){
			layer?.backgroundColor = .clear
		}
		if(hoverCursor != nil){
			NSCursor.pop()
		}
	}
}

class NiTextFieldCell: NSTextFieldCell{
	
	static let customFieldEditor = NiFieldEditor()
	
	override func fieldEditor(for controlView: NSView) -> NSTextView? {
		return NiTextFieldCell.customFieldEditor
	}
}

class NiFieldEditor: NSTextView{
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		commonInit()
	}
	
	override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
		super.init(frame: frameRect, textContainer: container)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func commonInit() {
		isFieldEditor = true
		insertionPointColor = NSColor.birkin
	}
}
