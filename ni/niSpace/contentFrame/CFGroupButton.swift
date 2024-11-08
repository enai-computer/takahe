//
//  CFGroupButton.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class CFGroupButton: NSView, NSTextFieldDelegate{
	
	var mouseDownFunction: ((NSEvent) -> Void)?
	var mouseDownInActiveFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?
	var titleChangedCallback: ((String) -> Void)?
	
	private var groupIcon: NiActionImage?
	private var groupTitle: NSTextField?
	private var preEditString: String?
	
	private var iconWidthConstraint: NSLayoutConstraint?
	private var titleWidthConstraint: NSLayoutConstraint?
	
	private var hoverEffect: NSTrackingArea?
	
	private let groupTitleMargin = 7.0
	private let groupTitleOriginY = 2.0
	private var displayType: NiConentFrameState?
	var contentType: TabContentType?
	
	private var mouseDragged: Bool = false
	
	func initButton(mouseDownFunction: ((NSEvent) -> Void)?,
					mouseDownInActiveFunction: ((NSEvent) -> Void)?,
					isActiveFunction: (() -> Bool)?,
					titleChangedCallback: ((String) -> Void)? = nil,
					displayType: NiConentFrameState,
					displayedContent: TabContentType = .web
	){
		self.mouseDownFunction = mouseDownFunction
		self.mouseDownInActiveFunction = mouseDownInActiveFunction
		self.isActiveFunction = isActiveFunction
		self.titleChangedCallback = titleChangedCallback
		self.displayType = displayType
		self.contentType = displayedContent
 	}

	func setView(title: String? = nil){
		if(title == nil || title!.isEmpty){
			displayIcon()
		}else if(groupTitle == nil){
			loadAndDisplayTxtField()
			groupTitle?.stringValue = title!
			setWidthConstraintToTitle()
			groupTitle?.textColor = NSColor.sand11
			dropIcon()
		}else{
			groupTitle?.stringValue = title!
			setWidthConstraintToTitle()
			groupTitle?.textColor = NSColor.sand11
			dropIcon()
		}
	}
	
	override func updateTrackingAreas() {
		if(hoverEffect != nil){
			self.removeTrackingArea(hoverEffect!)
		}
		hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect!)
	}
	
	func displayIcon() {
		guard groupIcon == nil else {
			addSubview(groupIcon!)
			setWidthConstraintToIcon()
			triggerLayoutConstraintUpdate()
			return
		}
		let icon = NiActionImage(image: NSImage.groupIcon)
		icon.setMouseDownFunction(self.mouseDown)
		icon.mouseDownInActiveFunction = mouseDownInActiveFunction
		icon.isActiveFunction = isActiveFunction
		icon.mouseUpFunction = self.mouseUp
		addSubview(icon)
		groupIcon = icon
		setWidthConstraintToIcon()
	}
		
	func menuClickStartsEditing(with event: NSEvent){
		self.startEditing()
	}
	
	func startEditing(){
		groupIcon?.removeFromSuperview()
		
		if(groupTitle == nil){
			loadAndDisplayTxtField()
		}
		
		groupTitle!.isEditable = true
		groupTitle?.isSelectable = true
		groupTitle?.refusesFirstResponder = false
		groupTitle!.frame.origin = NSPoint(x: groupTitleMargin, y: groupTitleOriginY)
		styleEditing()
		
		preEditString = groupTitle?.stringValue ?? ""
		window?.makeFirstResponder(groupTitle)
	}
	
	func controlTextDidEndEditing(_ obj: Notification){
		groupTitle?.currentEditor()?.selectedRange = NSMakeRange(0, 0)
		groupTitle?.isEditable = false
		groupTitle?.isSelectable = false
		groupTitle?.refusesFirstResponder = true
		styleEndEditing()
		updateTrackingAreas()
		
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			revertChanges()
			updateTrackingAreas()
			//needs to be called here, otherwise we'll not react to mouse down events
			window?.makeFirstResponder(self)
			return
		}
		if(groupTitle!.stringValue.isEmpty){
			dropTitle()
			updateTrackingAreas()
			return
		}
		titleChangedCallback?(groupTitle!.stringValue)
		setWidthConstraintToTitle()
	}
	
	private func getUIMenuStr() -> String{
		
		if(contentType == .pdf){
			return "Rename pdf"
		}
		
		if(hasTitle()){
			return "Rename this window"
		}
		return "Name this window"
	}
	
	func getNameTileMenuItem() -> NiMenuItemViewModel{
		let titleStr = getUIMenuStr()
		
		return NiMenuItemViewModel(
			title: titleStr,
			isEnabled: true,
			mouseDownFunction: self.menuClickStartsEditing
		)
	}
	
	func getRemoveTitleMenuItem() -> NiMenuItemViewModel?{
		if(!hasTitle()){
			return nil
		}
		return NiMenuItemViewModel(
			title: "Remove name",
			isEnabled: true,
			mouseDownFunction: self.removeName
		)
	}
	
	func removeName(event: NSEvent){
		dropTitle()
	}
	
	func hasTitle() -> Bool{
		if(groupTitle != nil && !(groupTitle!.stringValue.isEmpty)){
			return true
		}
		return false
	}
	
	private func revertChanges(){
		if(preEditString == nil || preEditString!.isEmpty){
			dropTitle()
			return
		}
		groupTitle?.stringValue = preEditString!
		setWidthConstraintToTitle()
	}
	
	private func dropIcon(){
		groupIcon?.removeFromSuperview()
	}
	
	private func dropTitle(){
		groupTitle?.removeFromSuperview()
		groupTitle = nil
		setView()
	}

	private func styleEndEditing(){
		groupTitle?.textColor = NSColor.sand11
		layer?.backgroundColor = NSColor.transparent.cgColor
		layer?.borderWidth = 0.0
	}
	
	private func styleEditing(){
		wantsLayer = true
		layer?.backgroundColor = NSColor.sand2.cgColor
		layer?.cornerCurve = .continuous
		layer?.cornerRadius = 5.0
		layer?.borderColor = NSColor.birkin.cgColor
		layer?.borderWidth = 1.0
		groupTitle?.textColor = NSColor.sand12
		setWidthConstraintToTitle(editMode: true)
	}
	
	private func loadAndDisplayTxtField(){
		groupTitle = genTextField()
		self.frame.size.width = 202.0
		addSubview(groupTitle!)
		triggerLayoutConstraintUpdate()
	}
	
	private func triggerLayoutConstraintUpdate(){
		if let cfView = superview?.superview?.superview as? ContentFrameView{
			cfView.updateGroupButtonLeftConstraint()
			cfView.cfHeadView.layout()
		}
	}
	
	private func genTextField() -> NiTextField{
		let field = NiTextField(frame: NSRect(x: groupTitleMargin, y: groupTitleOriginY, width: 150.0, height: 20.0))
		field.font = NSFont(name: "Sohne-Kraftig", size: 14.0)
		field.textColor = NSColor.sand12
		field.refusesFirstResponder = true
		field.placeholderString = "Name this window"
		field.delegate = self
		field.isEditable = false
		field.isSelectable = false
		return field
	}

	override func mouseDown(with event: NSEvent) {
		mouseDragged = false
		super.mouseDown(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		if(mouseDragged){
			return
		}
		if(isActiveFunction != nil && !isActiveFunction!()){
			mouseDownInActiveFunction?(event)
			return
		}
		mouseDownFunction?(event)
	}
	
	//dragging contentframe on the groupButton
	override func mouseDragged(with event: NSEvent) {
		mouseDragged = true
		groupTitle?.textColor = NSColor.sand11
		groupIcon?.contentTintColor = groupIcon?.defaultTint
		super.mouseDragged(with: event)
	}
	
	override func mouseEntered(with event: NSEvent) {
		//if is not active - don't change color
		if((isActiveFunction != nil && !isActiveFunction!()) || groupTitle == nil || groupTitle!.isEditable){
			return
		}
		groupTitle?.textColor = NSColor.birkin
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if((isActiveFunction != nil && !isActiveFunction!()) || groupTitle == nil || groupTitle!.isEditable){
			return
		}
		groupTitle?.textColor = NSColor.sand11
	}
	
	func getName() -> String?{
		return groupTitle?.stringValue
	}
	
	/*
	 * MARK: width constraints
	 */
	private func getIconWidthConstraint() -> NSLayoutConstraint{
		return NSLayoutConstraint(
			item: self,
			attribute: .width, relatedBy: .equal,
			toItem: nil,
			attribute: .notAnAttribute,
			multiplier: 1.0,
			constant: groupIcon?.frame.width ?? 24.0
		)
	}
	
	private func getTitleWidthConstraint(_ editMode: Bool) -> NSLayoutConstraint{
		let maxWidth: CGFloat = if(displayType == .simpleFrame){
			220.0
		}else{
			155.0
		}
		
		var width: CGFloat = if(editMode){
			maxWidth
		}else{
			groupTitle?.fittingSize.width ?? 155.0
		}
		if(width.isZero || maxWidth < width){
			width = maxWidth
		}
		if (groupTitle != nil){
			groupTitle!.frame.size.width = width
		}
		width += groupTitleMargin
		return NSLayoutConstraint(
			item: self,
			attribute: .width, relatedBy: .equal,
			toItem: nil,
			attribute: .notAnAttribute,
			multiplier: 1.0,
			constant: width
		)
	}
	
	private func setWidthConstraintToIcon(){
		if(titleWidthConstraint != nil){
			removeConstraint(titleWidthConstraint!)
			titleWidthConstraint = nil
		}
		if(iconWidthConstraint == nil){
			iconWidthConstraint = getIconWidthConstraint()
		}
		removeConstraint(iconWidthConstraint!)
		addConstraint(iconWidthConstraint!)
	}
	
	private func setWidthConstraintToTitle(editMode: Bool = false){
		if(iconWidthConstraint != nil){
			removeConstraint(iconWidthConstraint!)
		}
		if(titleWidthConstraint != nil){
			removeConstraint(titleWidthConstraint!)
		}
		//Title Width needs to be recalced based on number of Chars
		titleWidthConstraint = getTitleWidthConstraint(editMode)
		addConstraint(titleWidthConstraint!)
	}
	
	func tintInactive(){
		groupIcon?.tintInactive()
		groupTitle?.textColor = NSColor(.sand10)
	}
	
	func tintActive(){
		groupIcon?.tintActive()
		groupTitle?.textColor = NSColor(.sand11)
	}
	
	func deinitSelf(){
		mouseDownFunction = nil
		mouseDownInActiveFunction = nil
		isActiveFunction = nil
		titleChangedCallback = nil
		groupIcon?.deinitSelf()
		
		if(hoverEffect != nil){
			self.removeTrackingArea(hoverEffect!)
		}
		hoverEffect = nil
	}
}

