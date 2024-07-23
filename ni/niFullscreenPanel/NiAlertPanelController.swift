//
//  NiAlertPanelController.swift
//  ni
//
//  Created by Patrick Lukas on 1/7/24.
//

import Cocoa

class NiAlertPanelController: NSViewController{
	
	@IBOutlet var contentBox: NSBox!
	@IBOutlet var panelTitle: NSTextField!
	@IBOutlet var panelContet: NSTextField!
	@IBOutlet var deleteButton: NSButton!
	@IBOutlet var cancelButton: NSButton!
		
	var cancelFunction: ((Any) -> Void)?
	var deleteFunction: ((Any) -> Void)?
	
	init(){
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let myView = (NSView.loadFromNib(nibName: "NiAlertPanel", owner: self))!
		let wSize = CGSize(width: myView.frame.width + 120.0, height: myView.frame.height + 120.0)
		myView.frame.origin = CGPoint(x: 60.0, y: 60.0)
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: wSize))
		view.addSubview(myView)
	}
	
	override func viewWillAppear() {
		super.viewDidLoad()
		styleSelf()
		styleDeletButton()
		styleCancelButton()
	}
	
	private func styleSelf(){
		contentBox.clipsToBounds = false
		
		contentBox.wantsLayer = true
		contentBox.layer?.borderColor = NSColor.clear.cgColor
		contentBox.layer?.cornerRadius = 15.0
		contentBox.layer?.cornerCurve = .continuous
		contentBox.layer?.backgroundColor = NSColor.sand4T70.cgColor
		
		contentBox.layer?.shadowColor = NSColor.sand11.cgColor
		contentBox.layer?.shadowOffset = CGSize(width: 0.0, height: -4.0)
		contentBox.layer?.shadowOpacity = 0.3
		contentBox.layer?.shadowRadius = 15.0
		
		contentBox.layer?.masksToBounds = false
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
