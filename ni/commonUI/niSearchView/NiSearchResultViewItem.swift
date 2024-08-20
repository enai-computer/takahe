//
//  NiSearchResultViewItem.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiSearchResultViewItem: NSCollectionViewItem {

	@IBOutlet var leftSideResultTypeIcon: NSImageView!
	@IBOutlet var resultTitle: NSTextField!
	@IBOutlet var rightSideElement: NiSearchResultViewItemRightIcon!
	
	private var resultData: NiSearchResultItem?
	private var keySelected: Bool = false
	private var birkinHighlight: NSView? = nil
	private var style: NiSearchViewStyle? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 4.0
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		view.addTrackingArea(hoverEffectTrackingArea)
    }
    
	func configureView(_ data: NiSearchResultItem, position: Int, style: NiSearchViewStyle){
		resultTitle.stringValue = data.name
		self.resultData = data
		self.style = style

		self.rightSideElement.configureElement(position)
		
		if(style == .homeView){
			view.layer?.backgroundColor = NSColor.clear.cgColor
		}
		if(data.id == NiSpaceDocumentController.DEMO_GEN_SPACE_ID){
			leftSideResultTypeIcon.image = NSImage(named: "magicWand")
		}else{
			leftSideResultTypeIcon.image = NSImage(named: "SpaceIcon")
		}
	}
	
	override func prepareForReuse() {
		deselect()
		rightSideElement.prepareForReuse()
	}
	
	func select(){
		birkinHighlight = getBirkinView()
		view.addSubview(birkinHighlight!)
		view.layer?.backgroundColor = NSColor.sand1.cgColor
		resultTitle.textColor = NSColor.sand12
		keySelected = true
		rightSideElement.select()
	}
	
	func deselect(){
		birkinHighlight?.removeFromSuperview()
		birkinHighlight = nil
		keySelected = false
		
		if(style == .palette){
			view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		}else{
			view.layer?.backgroundColor = NSColor.clear.cgColor
		}
		
		resultTitle.textColor = NSColor.sand115
		rightSideElement.deselect()
	}
	
	override func mouseDown(with event: NSEvent) {
		tryOpenResult()
	}
	
	func tryOpenResult(){
		if(resultData?.type == .niSpace){
			openSpaceAndTryRemoveWindow()
		}else if(resultData?.type == .webApp){
			//TODO: open WebApp in SimpleFrame
		}
	}
	
	private func openSpaceAndTryRemoveWindow(){
		if(resultData?.id == nil){return}
		if let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController{
			spaceViewController.showHeader()
			if(resultData?.id == NiSpaceDocumentController.EMPTY_SPACE_ID){
				if let spaceName = getEnteredSearchText()?.trimmingCharacters(in: .whitespaces){
					spaceViewController.createSpace(name: spaceName)
				}
			}else{
				spaceViewController.loadSpace(spaceId: resultData!.id!, name: resultTitle.stringValue)
			}
		}
		if let paletteWindow = view.window as? NiSearchWindowProtocol{
			paletteWindow.removeSelf()
		}
	}
	
	private func getEnteredSearchText() -> String?{
		var nxtResp = nextResponder
		while nxtResp != nil{
			if let searchCont = nxtResp as? NiSearchController {
				return searchCont.searchField.stringValue
			}
			nxtResp = nxtResp?.nextResponder
		}
		return nil
	}
	
	override func mouseExited(with event: NSEvent) {
		if(keySelected){return}
		if(style == .palette){
			view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		}else{
			view.layer?.backgroundColor = NSColor.transparent.cgColor
		}
		resultTitle.textColor = NSColor.sand115
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(keySelected){return}
		view.layer?.backgroundColor = NSColor.sand1.cgColor
		resultTitle.textColor = NSColor.sand12
	}
	
	private func getBirkinView() -> NSView{
		let birkinFrame = NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: CGSize(width: 4, height: view.frame.height))
		let birkinRect = NSView(frame: birkinFrame)
		birkinRect.wantsLayer = true
		birkinRect.layer?.backgroundColor = NSColor.birkin.cgColor
		return birkinRect
	}
}
