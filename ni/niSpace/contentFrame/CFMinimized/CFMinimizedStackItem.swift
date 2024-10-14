//
//  CFMinimizedStackItem.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

class CFMinimizedStackItem: NSView{
	
	@IBOutlet var tabIcon: NSImageView!
	@IBOutlet var tabTitle: NSTextField!
	private(set) var tabPosition: Int = -1
	
	private var txtActiveColor: NSColor = NSColor(.sand12)
	private var txtInactiveColor: NSColor = NSColor(.sand11)
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		self.wantsLayer = true
		layer?.backgroundColor = NSColor(.sand3).cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: self.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffectTrackingArea)
	}
	
	func setRoundedCorners(_ edge: NSDirectionalRectEdge){
		layer?.cornerRadius = 8
		layer?.cornerCurve = .continuous
		if(edge == .top){
			layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		}else if (edge == .bottom){
			layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}
	}
	
	func setItemData(position: Int, title: String, icon: NSImage?, urlStr: String? = nil){
		tabPosition = position
		tabTitle.stringValue = title
		if(icon != nil){
			tabIcon.image = icon
		}else if(urlStr != nil && !urlStr!.isEmpty){
			Task {
				if let img = (await FaviconProvider.instance.fetchIcon(urlStr!) ?? NSImage(named: NSImage.Name("enaiIcon"))){
					self.setIcon(img)
				}
			}
		}
	}
	
	@MainActor
	func setIcon(_ img: NSImage){
		tabIcon.image = img
	}
	
	override func mouseDown(with event: NSEvent) {
		guard let myController = nextResponder?.nextResponder?.nextResponder?.nextResponder as? ContentFrameController else{return}
		myController.minimizedToExpanded(tabPosition)
	}
	
	override func mouseEntered(with event: NSEvent) {
		layer?.backgroundColor = NSColor(.sand1).cgColor
		tabTitle.textColor = txtActiveColor
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.backgroundColor = NSColor(.sand3).cgColor
		tabTitle.textColor = txtInactiveColor
	}

	func updateTextTint(_ frameIsActive: Bool){
		if(frameIsActive){
			txtActiveColor = NSColor(.sand12)
			txtInactiveColor = NSColor(.sand11)
			tabTitle.textColor = NSColor(.sand11)
		}else{
			txtActiveColor = NSColor(.sand11)
			txtInactiveColor = NSColor(.sand10)
			tabTitle.textColor = NSColor(.sand10)
		}
	}
}
