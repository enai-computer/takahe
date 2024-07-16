//
//  NiFindPanel.swift
//  ni
//
//  Created by Patrick Lukas on 20/6/24.
//

import Cocoa

class NiWebViewFindPanel: NSViewController, NSTextFieldDelegate {

	private var niContentItem: CFContentSearch? = nil

	@IBOutlet var doneButton: NiActionLabel!
	@IBOutlet var searchField: NSTextField!
	@IBOutlet var nxtFindButton: NiActionImage!
	@IBOutlet var prevFindButton: NiActionImage!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		view.frame.origin = CGPoint(x: 4.0, y: 4.0)
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand4.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 8.0
		
		searchField.wantsLayer = true
		searchField.focusRingType = .none
		searchField.shadow = nil
		searchField.layer?.borderColor = NSColor.birkin.cgColor
		searchField.layer?.borderWidth = 1.0
		searchField.layer?.cornerRadius = 8.0
		searchField.layer?.cornerCurve = .continuous
		
		doneButton.mouseDownFunction = doneButtonClicked
		doneButton.isActiveFunction = {return true}
		
		nxtFindButton.mouseDownFunction = nxtButtonClicked
		nxtFindButton.isActiveFunction = {return false}

		prevFindButton.mouseDownFunction = prevButtonClicked
		prevFindButton.isActiveFunction = {return false}
    }
    
	override func viewDidAppear() {
		super.viewDidAppear()
		view.window?.makeFirstResponder(searchField)
	}
	
	func resetOrigin(_ parentFrame: CGSize, cooridatesFilpped: Bool = false){
		if(cooridatesFilpped){
			view.frame.origin = CGPoint(x: 4.0, y: 4.0)
			return
		}
		view.frame.origin.y = parentFrame.height - 4.0 - view.frame.height
	}
	
	func setParentViewItem(_ searchableContentView: CFContentSearch){
		self.niContentItem = searchableContentView
		nxtFindButton.isActiveFunction = {return self.niContentItem!.nextFindAvailable}
		prevFindButton.isActiveFunction = {return self.niContentItem!.prevFindAvailable}
	}
	
	func controlTextDidChange(_ obj: Notification) {
		niContentItem?.resetSearchAvailability()
		nxtFindButton.tintActive()
		prevFindButton.tintActive()
	}
	
	func controlTextDidEndEditing(_ obj: Notification){
		niContentItem?.performFindNext()
	}
	
	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == #selector(NSTextView.insertNewline) {
			if let currentEvent = NSApplication.shared.currentEvent{
				if(currentEvent.modifierFlags.contains(.shift)){
					niContentItem?.performFindPrevious()
					return true
				}
			}
			niContentItem?.performFindNext()
			return true
		}
		return false
	}
	
	override func cancelOperation(_ sender: Any?) {
		removeSelf()
	}
	
	func nxtButtonClicked(_ event: NSEvent){
		niContentItem?.performFindNext()
	}
	
	func prevButtonClicked(_ event: NSEvent){
		niContentItem?.performFindPrevious()
	}
	
	func doneButtonClicked(_ event: NSEvent){
		removeSelf()
	}
	
	@IBAction func performFindNext(_ sender: NSMenuItem){
		niContentItem?.performFindNext()
	}
	
	@IBAction func performFindPrevious(_ sender: NSMenuItem){
		niContentItem?.performFindPrevious()
	}
	
	override func mouseDown(with event: NSEvent) {
		return
	}
	
	private func removeSelf(){
		view.removeFromSuperview()
		niContentItem?.searchPanel = nil
		niContentItem?.resetSearchAvailability()
	}
}
