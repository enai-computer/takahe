//
//  NiMenuItemView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuItemView: NSView{
	/// Amount of favicons that can fit the ``NiMenuItemView``.
	static var menuItemIconLimit = 5

	@IBOutlet var title: NSTextField!
	@IBOutlet var keyboardShortcut: NSTextField!

	private lazy var menuItemStack: NSStackView = {
		let menuItemStack = NSStackView(frame: self.bounds)
		menuItemStack.orientation = .horizontal
		menuItemStack.alignment = .centerY
		menuItemStack.distribution = .gravityAreas

		// Vertical center the 24pt stack in e.g. a 46pt menu item view
		let height: CGFloat = 24  // Value from CFCollapsedMinimizedView
		let horizontalInset: CGFloat = 7 // Value from CFCollapsedMinimizedView
		let verticalInset = (self.bounds.height - height) / 2
		menuItemStack.edgeInsets = .init(
			top: verticalInset,
			left: horizontalInset,
			bottom: verticalInset,
			right: horizontalInset
		)
		menuItemStack.spacing = 14 // Value from CFCollapsedMinimizedView

		return menuItemStack
	}()

	private var birkinHighlight: NSView? = nil
	private var isEnabledStorage = true
	
	var isEnabled: Bool{
		set {
			guard isEnabledStorage != newValue else {return}
			isEnabledStorage = newValue
			if(newValue){
				title.textColor = NSColor.sand12
			}else{
				title.textColor = NSColor.sand8
				keyboardShortcut.isHidden = true
			}
		}
		get{
			isEnabledStorage
		}
	}
	var mouseDownFunction: ((NSEvent) -> Void)?
	
	func setKeyboardshortcut(_ shortcut: String){
		guard isEnabled else {return}
		
		keyboardShortcut.stringValue = shortcut
		keyboardShortcut.isHidden = false
	}
	
	override func updateTrackingAreas() {
		let hoverEffect = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		addTrackingArea(hoverEffect)
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		wantsLayer = true
		layer?.backgroundColor = NSColor.sand1.cgColor
		layer?.cornerRadius = 2.0
		layer?.cornerCurve = .continuous
		birkinHighlight = getBirkinView()
		addSubview(birkinHighlight!)
		title.textColor = NSColor.sand12
	}
	
	override func mouseExited(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		layer?.backgroundColor = NSColor.sand3.cgColor
		birkinHighlight?.removeFromSuperview()
		birkinHighlight = nil
		title.textColor = NSColor.sand115
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		mouseDownFunction?(event)
		window?.orderOut(nil)
		window?.close()
	}
	
	private func getBirkinView() -> NSView{
		let birkinFrame = NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: CGSize(width: 2, height: frame.height))
		let birkinRect = NSView(frame: birkinFrame)
		birkinRect.wantsLayer = true
		birkinRect.layer?.backgroundColor = NSColor.birkin.cgColor
		return birkinRect
	}
}

extension NiMenuItemView {
	func display(viewModel: NiMenuItemViewModel) {
		self.isEnabled = viewModel.isEnabled
		self.mouseDownFunction = viewModel.mouseDownFunction

		if let keyboardShortcut = viewModel.keyboardShortcut{
			self.setKeyboardshortcut(keyboardShortcut)
		}

		switch viewModel.label {
		case .title(let title):
			self.title.stringValue = title
			menuItemStack.removeFromSuperview()
		case .views(let stackedViews):
			self.title.stringValue = ""
			menuItemStack.setViews(stackedViews, in: .leading)
			self.addSubview(menuItemStack)
		}
	}
}
