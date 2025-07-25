//
//  NiTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

class NiNoteItem: NSViewController, CFContentItem {
	
	private var overlay: NSView?
	var owner: ContentFrameController?
	var parentView: CFFramelessView? {return scrollView.superview as? CFFramelessView }
	var viewIsActive: Bool {return txtDocView.isEditable}
	
	var scrollView: NSScrollView
	private var txtDocView: NiNoteView
	private var backgroundColor: NSColor? = nil
	private(set) var stickyColor: StickyColor?
	private var textColor: NSColor? = nil
	private var cursorColor: NSColor? = nil
	private var scrollerKnobColor: NSColor? = nil
	
	required init(frame: NSRect, initText: String?) {
		scrollView = NSScrollView(frame: frame)
		let noteView = NiNoteView(frame: frame)
		self.txtDocView = noteView
		
		scrollView.documentView = noteView

		let txtStorage = if(initText == nil){
			NSTextStorage(string: "")
		}else{
			NSTextStorage(string: initText!)
		}
		txtStorage.addLayoutManager(txtDocView.layoutManager!)
		
		super.init(nibName: nil, bundle: nil)
		
		noteView.myController = self
		view = scrollView
	}
	
	convenience init(frame: NSRect, initText: String?, backgroundColor: StickyColor) {
		self.init(frame: frame, initText: initText)
		self.stickyColor = backgroundColor
		self.backgroundColor = backgroundColor.toNSColor()
		self.textColor = NSColor.stickyText
		self.cursorColor = NSColor.stickyText
		self.scrollerKnobColor = NSColor.stickyText
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		configureTxtDocView()
		configureScrollView()
		scrollView.documentView?.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureTxtDocView(){
		txtDocView.backgroundColor = self.backgroundColor ?? NSColor.sand1
		txtDocView.insertionPointColor = self.cursorColor ?? NSColor.birkin
		txtDocView.importsGraphics = false
		txtDocView.allowsImageEditing = false
		txtDocView.displaysLinkToolTips = false
		txtDocView.usesFindBar = false
		txtDocView.usesFindPanel = false
		txtDocView.usesFontPanel = false
		txtDocView.isRichText = false
		txtDocView.isVerticallyResizable = true
		txtDocView.isHorizontallyResizable = false
		txtDocView.isEditable = false
		txtDocView.textContainerInset = NSSize(width: 8.0, height: 8.0)
		
		txtDocView.font = NSFont(name: "Sohne-Buch", size: 16.0)
		txtDocView.textColor = self.textColor ?? NSColor.sand115
		txtDocView.wantsLayer = true
		if let radius = parentView?.layer?.cornerRadius{
			txtDocView.layer?.cornerRadius = radius
		}
		txtDocView.layer?.cornerCurve = .continuous
		
		txtDocView.frame.size.width = scrollView.frame.width
		txtDocView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			txtDocView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			txtDocView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			txtDocView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			txtDocView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor)
		])
	}
	
	private func configureScrollView(){
		let scrollerPos: NSRect = NSRect(x: scrollView.frame.width - 2.0, y: 0, width: 2.0, height: scrollView.frame.height)
		scrollView.hasVerticalScroller = true
		scrollView.verticalScroller = NiNoteViewScroller(frame: scrollerPos, knobColor: scrollerKnobColor ?? .birkin, backgroundColor: backgroundColor ?? NSColor.sand1)
		scrollView.verticalScrollElasticity = .allowed
		scrollView.horizontalScroller = nil
		scrollView.hasHorizontalScroller = false
		scrollView.horizontalScrollElasticity = .none
		scrollView.autohidesScrollers = true
		scrollView.scrollerInsets = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		
		scrollView.wantsLayer = true
		scrollView.layer?.backgroundColor = backgroundColor?.cgColor ?? NSColor.sand1.cgColor
		scrollView.backgroundColor = backgroundColor ?? NSColor.sand1

		if let radius = parentView?.layer?.cornerRadius{
			scrollView.layer?.cornerRadius = radius
		}
		scrollView.layer?.cornerCurve = .continuous
	}
	
	func printView(_ sender: Any?) {
		txtDocView.printView(sender)
	}
	
	func resizeContent(){
		txtDocView.needsLayout = true
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		txtDocView.isSelectable = true
		
		setStyling()
		scrollView.window?.makeFirstResponder(txtDocView)
	}
	
	func spaceClosed(){}
	func spaceRemovedFromMemory() {
		self.owner = nil
		self.overlay = nil
	}
	
	func setInactive() -> FollowOnAction{
		setStyling()
		
		txtDocView.isEditable = false
		txtDocView.isSelectable = false
		txtDocView.setSelectedRange(NSRange(location: 0, length: 0))
		let content = getText()
		if(content == nil || content!.isEmpty){
			return .removeSelf
		}
		
		overlay = cfOverlay(frame: scrollView.frame, nxtResponder: self.parentView)
		txtDocView.addSubview(overlay!)
		txtDocView.window?.makeFirstResponder(overlay)
		
		return .nothing
	}
	
	func startEditing(){
		txtDocView.isEditable = true
		parentView?.setBorder()
	}
	
	func stopEditing(){
		txtDocView.isEditable = false
	}
	
	private func setStyling(){
		txtDocView.wantsLayer = true
		txtDocView.backgroundColor = backgroundColor ?? NSColor.sand1
		txtDocView.layer?.cornerRadius = 5
		txtDocView.layer?.cornerCurve = .continuous
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
			return note
		}
		
		let firstLine = note![..<endOfFirstLine!]
		return String(firstLine)
	}
}
