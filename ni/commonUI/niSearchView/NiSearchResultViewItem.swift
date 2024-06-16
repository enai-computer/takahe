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
	private var keySelected: Bool = false
	
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
	
	override func prepareForReuse() {
		deselect()
		rightSideElement.prepareForReuse()
	}
	
	func select(){
//		NSColor.birkin.setFill()
//		let r = NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: CGSize(width: 20, height: view.frame.height))
//		r.fill()
		keySelected = true
		view.layer?.backgroundColor = NSColor.birkinLight.cgColor
		resultTitle.textColor = NSColor.sand12
		rightSideElement.select()
	}
	
	func deselect(){
		keySelected = false
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		resultTitle.textColor = NSColor.sand115
		rightSideElement.deselect()
	}
	
	override func mouseDown(with event: NSEvent) {
		openSpaceAndTryRemoveWindow()
	}
	
	func openSpaceAndTryRemoveWindow(){
		if(spaceId == nil){return}
		if let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController{
			if(spaceId == NiSpaceDocumentController.EMPTY_SPACE_ID){
				//TODO: fetch name from textField
//				spaceViewController.createSpace(name: )
			}else{
				spaceViewController.loadSpace(niSpaceID: spaceId!, name: resultTitle.stringValue)
			}
		}
		if let paletteWindow = view.window as? NiPalette{
			paletteWindow.removeSelf()
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		if(keySelected){return}
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		resultTitle.textColor = NSColor.sand115
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(keySelected){return}
		view.layer?.backgroundColor = NSColor.sand1.cgColor
		resultTitle.textColor = NSColor.sand12
	}
}
