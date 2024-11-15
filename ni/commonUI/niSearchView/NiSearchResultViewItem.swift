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
	@IBOutlet var resultSubTitle: NSTextField!
	@IBOutlet var rightSideElement: NiSearchResultViewItemRightIcon!
	
	private var resultData: NiSearchResultItem?
	private var keySelected: Bool = false
	private var birkinHighlight: NSView? = nil
	private var style: NiSearchViewStyle? = nil
	private weak var niSearchController: NiSearchController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 4.0
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		view.addTrackingArea(hoverEffectTrackingArea)
    }
    
	func configureView(_ data: NiSearchResultItem, position: Int, style: NiSearchViewStyle, controller: NiSearchController){
		resultTitle.stringValue = data.name
		self.resultData = data
		self.style = style
		self.niSearchController = controller
		self.rightSideElement.configureElement(position)
		
		if(style == .homeView){
			view.layer?.backgroundColor = NSColor.clear.cgColor
		}
		if(data.id == NiSpaceDocumentController.DEMO_GEN_SPACE_ID){
			leftSideResultTypeIcon.image = NSImage(named: "magicWand")
		}else if(data.type == .eve){
			leftSideResultTypeIcon.image = NSImage(named: "enai_i")
		}else if(data.type == .group){
			leftSideResultTypeIcon.image = NSImage(named: "groupIcon")
		}else if(data.type == .pdf){
			leftSideResultTypeIcon.image = NSImage(named: "pdfFileIcon")
		}else if(data.type == .web && data.id != nil){
			Task{
				let img = await FaviconProvider.instance.fetchIcon(for: data.id!)
				DispatchQueue.main.async{
					//need check, as otherwise we'll end up with the wrong icon on the item
					if(self.resultData?.id == data.id){
						self.leftSideResultTypeIcon.image = img
					}
				}
			}
		}else{
			leftSideResultTypeIcon.image = NSImage(named: "SpaceIcon")
		}
		
		if(data.type == .pdf || data.type == .web || data.type == .group){
			if let parentSpace: NiSRIOriginData = data.data as? NiSRIOriginData{
				resultSubTitle.stringValue = parentSpace.name
			}
		}
	}
	
	override func prepareForReuse() {
		deselect()
		rightSideElement.prepareForReuse()
		resultSubTitle.stringValue = ""
	}
	
	func select(){
		birkinHighlight = getBirkinView()
		view.addSubview(birkinHighlight!)
		view.layer?.backgroundColor = NSColor.sand1.cgColor
		resultTitle.textColor = NSColor.sand12
		keySelected = true
		rightSideElement.select()
		leftSideResultTypeIcon.contentTintColor = NSColor.sand115
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
		leftSideResultTypeIcon.contentTintColor = NSColor.sand11
	}
	
	func preActionStyle() {
		leftSideResultTypeIcon.contentTintColor = NSColor.sand1
		resultTitle.textColor = NSColor.sand1
		rightSideElement.preActionStyle()
		view.layer?.backgroundColor = NSColor.birkin.cgColor
	}
	
	override func mouseDown(with event: NSEvent) {
		preActionStyle()
	}
	
	override func mouseUp(with event: NSEvent){
		tryOpenResult()
	}
	
	func tryOpenResult(){
		if(resultData?.type == .niSpace){
			guard  let spaceId = resultData?.id else {return}
			openSpaceAndTryRemoveWindow(for: spaceId, with: resultTitle.stringValue)
		}else if(resultData?.type == .eve){
			niSearchController?.getAnswerFromEve()
		}else if(resultData?.type == .group){
			guard let spaceToOpen = self.resultData?.data as? NiSRIOriginData else {return}
			openSpaceAndTryRemoveWindow(groupItem: self.resultData!, in: spaceToOpen)
		}else if(resultData?.type == .pdf || resultData?.type == .web){
			guard let spaceToOpen = self.resultData?.data as? NiSRIOriginData else {return}
			openSpaceAndTryRemoveWindow(contentItem: self.resultData!, in: spaceToOpen)
		}
	}
	
	private func openSpaceAndTryRemoveWindow(for id: UUID, with name: String){
		guard let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController else {return}
		
		if(spaceViewController.niSpaceID == id && id != NiSpaceDocumentController.EMPTY_SPACE_ID){
			if let paletteWindow = view.window as? NiSearchWindowProtocol{
				paletteWindow.removeSelf()
			}
			return
		}
		
		spaceViewController.showHeader()
		if(id == NiSpaceDocumentController.EMPTY_SPACE_ID){
			if let spaceName = getEnteredSearchText()?.trimmingCharacters(in: .whitespaces){
				spaceViewController.createSpace(name: spaceName)
			}
		}else{
			spaceViewController.loadSpace(spaceId: id, name: name)
		}
		
		if let paletteWindow = view.window as? NiSearchWindowProtocol{
			paletteWindow.removeSelf()
		}
	}
	
	private func openSpaceAndTryRemoveWindow(
		groupItem: NiSearchResultItem,
		in spaceOrigin: NiSRIOriginData
	){
		openSpaceAndTryRemoveWindow(for: spaceOrigin.id, with: spaceOrigin.name)
		guard let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController else {return}
		guard let groupId = groupItem.id else {return}
		spaceViewController.niDocument.myView.highlightContentFrame(with: groupId)
	}
	
	private func openSpaceAndTryRemoveWindow(
		contentItem: NiSearchResultItem,
		in spaceOrigin: NiSRIOriginData
	){
		openSpaceAndTryRemoveWindow(for: spaceOrigin.id, with: spaceOrigin.name)
		guard let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController else {return}
		guard let contentId = contentItem.id else {return}
		spaceViewController.niDocument.myView.highlightContentObj(contentId: contentId)
	}
	
	private func openImmersiveView(){
		if(resultData?.data == nil){return}
		if let spaceViewController = NSApplication.shared.mainWindow?.contentViewController as? NiSpaceViewController{
			if let url = resultData?.data as? URL{
				spaceViewController.openImmersiveView(url: url)
			}
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
