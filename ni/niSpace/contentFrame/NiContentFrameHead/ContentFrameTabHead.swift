//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 5/4/24.
//

import Cocoa

class ContentFrameTabHead: NSCollectionViewItem, NSTextFieldDelegate {

	@IBOutlet var image: NSImageView!
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var tabHeadTitle: ContentFrameTabHeadTextNode!
	
	private var inEditingMode = false
//	private var hoverEffectTrackingArea: NSTrackingArea? = nil
	var parentController: ContentFrameController?
	var tabPosition: Int = -1
	
	override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		view.layer?.cornerRadius = 5
		view.layer?.cornerCurve = .continuous
		
		tabHeadTitle.parentController = self
		tabHeadTitle.layer?.cornerRadius = 5
		tabHeadTitle.layer?.cornerCurve = .continuous
		tabHeadTitle.focusRingType = .none
		
		hideCloseButton()
		closeButton.mouseDownFunction = pressedClosedButton
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		view.addTrackingArea(hoverEffectTrackingArea)
    }
	
	override func prepareForReuse() {
		tabPosition = -1
		image.image = Bundle.main.image(forResource: "AppIcon")
		parentController = nil
	}
	
	func controlTextDidBeginEditing(_ notification: Notification) {
		inEditingMode = true
	}
	
	func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
		// print("tab wants to be edited")
		return true
	}

	func controlTextDidEndEditing(_ notification: Notification) {
		//needed as this is called on CollectionItem reload. idk why :O
		if(!inEditingMode){
			return
		}
		
		guard let textField = notification.object as? ContentFrameTabHeadTextNode
		  else { preconditionFailure("ContentFrameTabHead expects to react to changes to ContentFrameTabHeadTextNode only") }
		
		// ⚠️ End editing mode to disable the text field and change the tab state *first* so that eventual update to web view arrive to a consistent state. As the WebView callbacks do update TabHeads
		inEditingMode = false
		endEditMode()
		
		//do not load new website if return was not pressed
		let exitKey = (notification.userInfo! as NSDictionary)["NSTextMovement"]
		if ((exitKey as? Int) != 16){
			return
		}
		do{
			let url = try urlOrSearchUrl(from: textField.stringValue)
			self.loadWebsite(url: url)
		}catch{
			print("Failed to load website, due to " + error.localizedDescription)
		}
	}
	
	func configureView(parentController: ContentFrameController, tabPosition: Int, viewModel: TabViewModel){
		self.tabPosition = tabPosition
		self.parentController = parentController
		self.isSelected = viewModel.isSelected
		
		self.setText(viewModel)
		self.setIcon(viewModel)
		self.setBackground()
	}
	
	private func pressedClosedButton(with event: NSEvent) {
		parentController?.closeTab(at: tabPosition)
	}
	
	override func mouseExited(with event: NSEvent) {
		if(self.isSelected){
			return
		}
		setBackground()
		hideCloseButton()
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(self.isSelected){
			return
		}
		view.layer?.backgroundColor = NSColor(.sandLight6).cgColor
	}
	
	private func setBackground(){
		if(self.isSelected){
			view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
			activateCloseButton()
		}else{
			view.layer?.backgroundColor = NSColor(.transparent).cgColor
			hideCloseButton()
		}
	}
	
	private func activateCloseButton(){
		closeButton.isEnabled = true
		closeButton.isHidden = false
		closeButton.contentTintColor = NSColor(.sandLight9)
	}
	
	private func hideCloseButton(){
		closeButton.isEnabled = false
		closeButton.isHidden = true
	}
	
	
	@MainActor
	func setIcon(img: NSImage?){
		self.image.image = img
		self.image.alphaValue = 1.0
	}
    
	private func setIcon(_ viewModel: TabViewModel){

		if(viewModel.icon != nil){
			setIcon(img: viewModel.icon!)
			return
		}
		
		Task {
			do{
				if(viewModel.webView?.url?.absoluteString != nil){
					let img = try await fetchFavIcon(url: URL(string: viewModel.webView!.url!.absoluteString)!)
					
					parentController?.setTabIcon(at: tabPosition, icon: img)
					self.setIcon(img: img)
				}
			}catch{
				debugPrint(error)
			}
		}
	}
	
	private func setText(_ viewModel: TabViewModel){
		if(viewModel.inEditingMode){
			self.inEditingMode = true
			addEditingStyle()
			if(viewModel.state == .empty || viewModel.state == .error){
				self.tabHeadTitle.enableEditing(urlStr: "")
			}else{
				self.tabHeadTitle.enableEditing(urlStr: viewModel.webView?.url?.absoluteString ?? "")
			}
		}else{
			removeEditingStyle()
			self.tabHeadTitle.disableEditing(title: viewModel.webView?.title ?? viewModel.title)
		}
	}
	
	func loadWebsite(url: URL) {
		parentController?.loadWebsite(url, forTab: tabPosition)
	}
	
	func selectSelf(mouseDownEvent: NSEvent? = nil){
		parentController?.selectTab(at: tabPosition, mouseDownEvent: mouseDownEvent)
	}
	
	func startEditMode(){
		parentController?.editTabUrl(at: tabPosition)
	}
	
	func endEditMode(){
		parentController?.endEditingTabUrl(at: tabPosition)
	}
	
	private func addEditingStyle(){
		self.view.layer?.borderWidth = 1.0
		self.view.layer?.borderColor = NSColor(.birkin).cgColor
	}
	
	private func removeEditingStyle(){
		self.view.layer?.borderWidth = 0.0
	}
	
	/*
	 * MARK: -mouse down event here
	 */
	
	override func mouseDown(with event: NSEvent) {
		let isFrameActive = parentController?.expandedCFView?.frameIsActive
		if(isFrameActive != nil && !isFrameActive!){
			//sets current frame active
			parentController?.expandedCFView?.mouseDown(with: event)
		}
		//need to test if we are already selected otherwise we call self select on a double click and screw up where the text editing happens as this Item will process the double click, but may have a different postion, due to view recycling
		if(!self.isSelected && !tabHeadTitle.isEditable && event.clickCount == 1){
			selectSelf(mouseDownEvent: event)
			return
		}

		if(self.isSelected && !tabHeadTitle.isEditable && event.clickCount == 1){
			startEditMode()
			return
		}
		nextResponder?.mouseDown(with: event)
	}
}
