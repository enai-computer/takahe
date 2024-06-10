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
	
	private var groupIcon: NiActionImage?
	private var groupTitle: NSTextField?
	
	private var preEditString: String?
	
	func initButton(mouseDownFunction: ((NSEvent) -> Void)?,
					mouseDownInActiveFunction: ((NSEvent) -> Void)?,
					isActiveFunction: (() -> Bool)?
	){
		self.mouseDownFunction = mouseDownFunction
		self.mouseDownInActiveFunction = mouseDownInActiveFunction
		self.isActiveFunction = isActiveFunction
		
	}
	
	func setView(title: String? = nil){
		if(title == nil || title!.isEmpty){
			displayIcon()
		}else if(groupTitle == nil){
			loadAndDisplayTxtField()
			groupTitle?.stringValue = title!
		}
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	func displayIcon() {
		guard groupIcon == nil else {
			addSubview(groupIcon!)
			return
		}
		let icon = NiActionImage(image: NSImage.groupIcon)
		icon.mouseDownFunction = mouseDownFunction
		icon.mouseDownInActiveFunction = mouseDownInActiveFunction
		icon.isActiveFunction = isActiveFunction
		addSubview(icon)
		self.frame.size = icon.frame.size
		
		groupIcon = icon
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
		groupTitle!.frame.origin = NSPoint(x: 7.0, y: 0.0)
		styleEditing()
	}
	
	func controlTextDidBeginEditing(_ obj: Notification){
		preEditString = groupTitle?.stringValue ?? ""
	}
	
	func controlTextDidEndEditing(_ obj: Notification){
		groupTitle?.isEditable = false
		groupTitle?.isSelectable = false
		styleEndEditing()
		updateTrackingAreas()
		
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			revertChanges()
			return
		}
		if(groupTitle!.stringValue.isEmpty){
			dropTitle()
		}
	}
	
	private func getUIMenuStr() -> String{
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
	}
	
	private func dropTitle(){
		groupTitle?.removeFromSuperview()
		groupTitle = nil
		setView()
	}

	private func styleEndEditing(){
		groupTitle?.textColor = NSColor.sandLight11
		layer?.backgroundColor = NSColor.transparent.cgColor
		layer?.borderWidth = 0.0
	}
	
	private func styleEditing(){
		wantsLayer = true
		layer?.backgroundColor = NSColor.sandLight2.cgColor
		layer?.cornerCurve = .continuous
		layer?.cornerRadius = 5.0
		layer?.borderColor = NSColor.birkin.cgColor
		layer?.borderWidth = 1.0
	}
	
	private func loadAndDisplayTxtField(){
		groupTitle = genTextField()
		self.frame.size.width = 202.0
		self.frame.origin.x = 0.0
		addSubview(groupTitle!)
	}
	
	private func genTextField() -> NiTextField{
		let field = NiTextField(frame: NSRect(x: 0.0, y: 2.0, width: 150.0, height: 20.0))
		field.refusesFirstResponder = true
		field.placeholderString = "Name this window"
		field.delegate = self
		field.isEditable = false
		field.isSelectable = false
		return field
	}
	
	override func mouseDown(with event: NSEvent) {
		if(isActiveFunction != nil && !isActiveFunction!()){
			mouseDownInActiveFunction?(event)
			return
		}
		mouseDownFunction?(event)
	}
	
	override func mouseEntered(with event: NSEvent) {
		//if is not active - don't change color
		if((isActiveFunction != nil && !isActiveFunction!()) || groupTitle == nil){
			return
		}
		groupTitle?.textColor = NSColor.birkin
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if((isActiveFunction != nil && !isActiveFunction!()) || groupTitle == nil){
			return
		}
		groupTitle?.textColor = NSColor.sandLight11
	}
	
	func getName() -> String?{
		return groupTitle?.stringValue
	}
}

