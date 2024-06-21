//
//  NiWebViewFindPanel.swift
//  ni
//
//  Created by Patrick Lukas on 20/6/24.
//

import Cocoa

class NiWebViewFindPanel: NSViewController, NSTextFieldDelegate {

	private var niWebView: NiWebView? = nil

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
	
	func setNiWebView(_ niWebView: NiWebView){
		self.niWebView = niWebView
		nxtFindButton.isActiveFunction = {return self.niWebView!.nextFindAvailable}
		prevFindButton.isActiveFunction = {return self.niWebView!.prevFindAvailable}
	}
	
	func controlTextDidChange(_ obj: Notification) {
		niWebView?.resetSearchAvailability()
		nxtFindButton.tintActive()
		prevFindButton.tintActive()
	}
	
	func controlTextDidEndEditing(_ obj: Notification){
		niWebView?.performFind(searchField.stringValue, backwards: false)
	}
	
	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == #selector(NSTextView.insertNewline) {
			if let currentEvent = NSApplication.shared.currentEvent{
				if(currentEvent.modifierFlags.contains(.shift)){
					niWebView?.performFind(searchField.stringValue, backwards: true)
					return true
				}
			}
			niWebView?.performFind(searchField.stringValue, backwards: false)
			return true
		}
		return false
	}
	
	override func cancelOperation(_ sender: Any?) {
		removeSelf()
	}
	
	func nxtButtonClicked(_ event: NSEvent){
		niWebView?.performFind(searchField.stringValue, backwards: false)
	}
	
	func prevButtonClicked(_ event: NSEvent){
		niWebView?.performFind(searchField.stringValue, backwards: true)
	}
	
	func doneButtonClicked(_ event: NSEvent){
		removeSelf()
	}
	
	@IBAction func performFindNext(_ sender: NSMenuItem){
		niWebView?.performFind(searchField.stringValue, backwards: false)
	}
	
	@IBAction func performFindPrevious(_ sender: NSMenuItem){
		niWebView?.performFind(searchField.stringValue, backwards: true)
	}
	
	override func mouseDown(with event: NSEvent) {
		return
	}
	
	private func removeSelf(){
		view.removeFromSuperview()
		niWebView?.searchPanel = nil
	}
}
