//
//  NiAlertPanelController.swift
//  ni
//
//  Created by Patrick Lukas on 1/7/24.
//

import Cocoa

class NiAlertPanelController: NSViewController{
	
	@IBOutlet var panelTitle: NSTextField!
	@IBOutlet var panelContet: NSTextField!
	@IBOutlet var deleteButton: NSButton!
	@IBOutlet var cancelButton: NSButton!
		
	var cancelFunction: ((Any) -> Void)?
	var deleteFunction: ((Any) -> Void)?
	
	init(){
		super.init(nibName: NSNib.Name("NiAlertPanel"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		styleDeletButton()
		styleCancelButton()
	}
	
	private func styleSelf(){
		view.wantsLayer = true
		view.layer?.borderColor = NSColor.clear.cgColor
		view.layer?.cornerRadius = 15.0
		view.layer?.cornerCurve = .continuous
		view.layer?.backgroundColor = NSColor.sand4T80.cgColor
	}
	
	private func styleDeletButton(){
		deleteButton.wantsLayer = true
		deleteButton.contentTintColor = NSColor.alertRed
		deleteButton.layer?.backgroundColor = NSColor.clear.cgColor
	}
	
	private func styleCancelButton(){
		cancelButton.wantsLayer = true
		cancelButton.contentTintColor = NSColor.sand12
		cancelButton.layer?.backgroundColor = NSColor.sand1.cgColor
	}
	
	@IBAction func deleteAction(_ sender: Any) {
		if let window = view.window as? NiFullscreenPanel {
			window.removeSelf()
		}
		deleteFunction?(sender)
	}
	
	@IBAction func cancelAction(_ sender: Any) {
		if let window = view.window as? NiFullscreenPanel {
			window.removeSelf()
		}
		cancelFunction?(sender)
	}
}
