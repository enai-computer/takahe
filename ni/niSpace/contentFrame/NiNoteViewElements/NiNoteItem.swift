//
//  NiTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa
import Carbon.HIToolbox

class NiNoteItem: NSViewController, CFContentItem {
	
	private var overlay: NSView?
	var owner: ContentFrameController?
	var parentView: CFFramelessView? {return scrollView.superview as? CFFramelessView }
	var viewIsActive: Bool {return txtDocView.isEditable}
	
	var scrollView: NSScrollView
	private var txtDocView: NSTextView
	
	required init() {
		scrollView = NSTextView.scrollableTextView()
		self.txtDocView = scrollView.documentView as! NSTextView
//		let txtStorage = TextStorage(editorAttributes: Mar)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		txtDocView.backgroundColor = NSColor.sandLight3
		txtDocView.insertionPointColor = NSColor.birkin
		txtDocView.importsGraphics = false
		txtDocView.allowsImageEditing = false
		txtDocView.displaysLinkToolTips = false
		txtDocView.usesFindBar = false
		txtDocView.usesFindPanel = false
		txtDocView.usesFontPanel = false
		txtDocView.isRichText = false
		txtDocView.isVerticallyResizable = false
		txtDocView.isHorizontallyResizable = false
		txtDocView.isEditable = false
	
		txtDocView.font = NSFont(name: "Sohne-Buch", size: 16.0)
		txtDocView.textColor = NSColor.sandDark7
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		txtDocView.isSelectable = true
		
		setStyling()
		txtDocView.window?.makeFirstResponder(self)
	}
	
	func setInactive() -> FollowOnAction{
		setStyling()
		
		txtDocView.isEditable = false
		txtDocView.isSelectable = false
		let content = getText()
		if(content == nil || content!.isEmpty){
			return .removeSelf
		}
		
		overlay = cfOverlay(frame: scrollView.frame, nxtResponder: self.nextResponder)
		view.addSubview(overlay!)
		view.window?.makeFirstResponder(overlay)
		
		return .nothing
	}
	
	func startEditing(){
		txtDocView.isEditable = true
		parentView?.removeBorder()
	}
	
	func stopEditing(){
		txtDocView.isEditable = false
		parentView?.setBorder()
	}
	
	func setText(_ content: String){
		txtDocView.string = content
	}
	
	private func setStyling(){
		txtDocView.wantsLayer = true
		txtDocView.backgroundColor = NSColor.sandLight3
		txtDocView.layer?.cornerRadius = 5
		txtDocView.layer?.cornerCurve = .continuous
	}
	
	override func cancelOperation(_ sender: Any?) {
		_ = txtDocView.delegate?.textShouldEndEditing?(txtDocView)
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!txtDocView.isEditable && event.clickCount == 2){
			startEditing()
		}else if(!txtDocView.isEditable && event.clickCount == 1){
			nextResponder?.mouseDown(with: event)
			return
		}
		super.mouseDown(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		if(!txtDocView.isEditable){
			nextResponder?.mouseDragged(with: event)
			return
		}
		super.mouseDragged(with: event)
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(!txtDocView.isEditable){
				owner?.triggerCloseProcess(with: event)
				return
			}
		}
		if(event.keyCode == kVK_Escape && txtDocView.isEditable){
			stopEditing()
			return
		}
		
		if(!txtDocView.isEditable){
			startEditing()
			moveToEndOfDocument(nil)
		}
		super.keyDown(with: event)
	}
	
	func getText() -> String? {
		return txtDocView.textStorage?.string.trimmingCharacters(in: .whitespaces)
	}
	
	func getTitle() -> String? {
		let note = getText()
		if(note == nil || note!.isEmpty){
			return nil
		}
		let endOfFirstLine = note!.firstIndex(of: "\n")
		if(endOfFirstLine == nil){
			return nil
		}
		
		let firstLine = note![..<endOfFirstLine!]
		return String(firstLine)
	}
}
