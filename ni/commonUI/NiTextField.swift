//
//  TextField.swift
//  ni
//
//  Created by Patrick Lukas on 7/6/24.
//

import Cocoa

class NiTextField: NSTextField{
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
		font = NSFont(name: "Sohne-Buch", size: 16.0)
		textColor = NSColor.sandLight12
		backgroundColor = NSColor.transparent
		isBezeled = false
		drawsBackground = false
		focusRingType = .none
		importsGraphics = false
		lineBreakMode = .byTruncatingTail
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let maxChars = 3
	var numberOfChars = 0

	override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
		super.sendAction(action, to: target)
	}
	
	override func cancelOperation(_ sender: Any?) {
		return
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
