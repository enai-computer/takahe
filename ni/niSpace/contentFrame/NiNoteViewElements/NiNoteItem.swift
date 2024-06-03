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
	
	required init(frame: NSRect) {
		scrollView = NSScrollView(frame: frame)
		let noteView = NiNoteView(frame: frame)
		self.txtDocView = noteView
		
		scrollView.documentView = noteView

		let txtStorage = NSTextStorage(string: "")
		txtStorage.addLayoutManager(txtDocView.layoutManager!)
		
		super.init(nibName: nil, bundle: nil)
		
		noteView.myController = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		configureTxtDocView()
		configureScrollView()
	}
	
	private func configureTxtDocView(){
		txtDocView.backgroundColor = NSColor.sandLight3
		txtDocView.insertionPointColor = NSColor.birkin
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
	
		txtDocView.font = NSFont(name: "Sohne-Buch", size: 16.0)
		txtDocView.textColor = NSColor.sandDark7
		txtDocView.frame.size.width = scrollView.frame.width
		txtDocView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			txtDocView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			txtDocView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			txtDocView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			txtDocView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
			txtDocView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),
			txtDocView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
		])
		txtDocView.isVerticalContentSizeConstraintActive = false
	}
	
	private func configureScrollView(){
		let scrollerPos: NSRect = NSRect(x: scrollView.frame.width - 2.0, y: 0, width: 2.0, height: scrollView.frame.height)
		scrollView.hasVerticalScroller = true
		scrollView.verticalScroller = NiScroller(frame: scrollerPos, isVertical: true)
		scrollView.verticalScrollElasticity = .allowed
		scrollView.horizontalScroller = nil
		scrollView.hasHorizontalScroller = false
		scrollView.horizontalScrollElasticity = .none
		scrollView.autohidesScrollers = true
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		txtDocView.isSelectable = true
		
		setStyling()
		scrollView.window?.makeFirstResponder(txtDocView)
	}
	
	func setInactive() -> FollowOnAction{
		setStyling()
		
		txtDocView.isEditable = false
		txtDocView.isSelectable = false
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
