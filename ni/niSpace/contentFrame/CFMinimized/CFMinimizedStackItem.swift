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
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		self.wantsLayer = true
		layer?.backgroundColor = NSColor(.sandLight3).cgColor
		layer?.borderWidth = 4
		layer?.borderColor = NSColor(.sandLight4).cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: self.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffectTrackingArea)
	}
	
	func setRoundedCorners(_ edge: NSDirectionalRectEdge){
		layer?.cornerRadius = 10
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
				do{
					let img = try await fetchFavIcon(url: URL(string: urlStr!)!)!
					self.setIcon(img)
				}catch{
					debugPrint(error)
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
		layer?.backgroundColor = NSColor(.sandLight1).cgColor
		tabTitle.textColor = NSColor(.sandLight12)
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.backgroundColor = NSColor(.sandLight3).cgColor
		tabTitle.textColor = NSColor(.sandLight11)
	}
	
}
