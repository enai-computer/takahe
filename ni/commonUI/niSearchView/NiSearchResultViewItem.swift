//
//  NiSearchResultViewItem.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiSearchResultViewItem: NSCollectionViewItem {

	@IBOutlet var resultTitle: NSTextField!
	@IBOutlet var rightSideElement: NiSearchResultViewItemRightIcon!
	
	private var spaceId: UUID?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		view.addTrackingArea(hoverEffectTrackingArea)
    }
    
	func configureView(_ title: String, spaceId: UUID?, position: Int){
		resultTitle.stringValue = title
		self.spaceId = spaceId

		self.rightSideElement.configureElement(position)
	}
	
	func select(){
//		NSColor.birkin.setFill()
//		let r = NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: CGSize(width: 20, height: view.frame.height))
//		r.fill()
		view.layer?.backgroundColor = NSColor.birkinLight.cgColor
		resultTitle.textColor = NSColor.sand12
		rightSideElement.select()
	}
	
	func deselect(){
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		resultTitle.textColor = NSColor.sand115
		rightSideElement.deselect()
	}
	
	override func mouseDown(with event: NSEvent) {
		//TODO:
	}
	
	override func mouseExited(with event: NSEvent) {
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		resultTitle.textColor = NSColor.sand115
	}
	
	override func mouseEntered(with event: NSEvent) {
		view.layer?.backgroundColor = NSColor.sand1.cgColor
		resultTitle.textColor = NSColor.sand12
	}
}
