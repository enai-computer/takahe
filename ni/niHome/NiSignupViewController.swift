//
//  NiSignupViewController.swift
//  ni
//
//  Created by Patrick Lukas on 12/9/24.
//

import Cocoa

class NiSignupViewController: NSViewController, NSTextFieldDelegate{
	
	@IBOutlet var emailFieldBox: NSView!
	@IBOutlet var emailField: NSTextField!
	private weak var homeViewController: NiHomeController?
	
	init(_ parentController: NiHomeController){
		self.homeViewController = parentController
		super.init(nibName: NSNib.Name("NiSignupView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		emailField.focusRingType = .none
		stlyeSearchFieldBox()
	}
	
	private func stlyeSearchFieldBox(){
		emailFieldBox.wantsLayer = true
		emailFieldBox.layer?.backgroundColor = NSColor.sand1.cgColor
		emailFieldBox.layer?.cornerRadius = 8.0
		emailFieldBox.layer?.cornerCurve = .continuous
	}

	func controlTextDidEndEditing(_ notification: Notification) {
		UserSettings.updateValue(setting: .userEmail, value: emailField.stringValue)
		homeViewController?.transitionFromSignupToSearch()
		return
	}
	
	override func cancelOperation(_ sender: Any?) {
		emailField.stringValue = ""
	}
	
}
