//
//  NiWebViewFindPanel.swift
//  ni
//
//  Created by Patrick Lukas on 20/6/24.
//

import Cocoa

class NiWebViewFindPanel: NSViewController, NSTextFieldDelegate {

	var niWebView: NiWebView? = nil
	@IBOutlet var doneButton: NSButton!
	@IBOutlet var searchField: NSTextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		view.frame.origin = CGPoint(x: 4.0, y: 4.0)
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand4.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 8.0
    }
    
	@IBAction func clickedDoneButton(_ sender: Any) {
		view.removeFromSuperview()
	}
	
	func controlTextDidEndEditing(_ notification: Notification) {
		niWebView?.performFind(searchField.stringValue)
	}
}
