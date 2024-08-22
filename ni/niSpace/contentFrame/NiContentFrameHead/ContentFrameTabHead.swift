//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 5/4/24.
//

import Cocoa
import Carbon.HIToolbox

class ContentFrameTabHead: NSCollectionViewItem, NSTextFieldDelegate {

	@IBOutlet var image: NSImageView!
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var tabHeadTitle: ContentFrameTabHeadTextNode!
	
	private var inEditingMode = false
	weak var parentController: ContentFrameController?
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
		closeButton.setMouseDownFunction(pressedClosedButton)
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: view.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		view.addTrackingArea(hoverEffectTrackingArea)
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
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

	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == NSSelectorFromString("noop:") {
			if let event = view.window?.currentEvent{
				return handleNoopCommand(with: event)
			}
		}
		return false
	}
	
	private func handleNoopCommand(with event: NSEvent) -> Bool{
		if(event.modifierFlags.contains(.command) && event.keyCode == kVK_ANSI_W){
			nextResponder?.keyDown(with: event)
			return true
		}
		return false
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
		if ((exitKey as? Int) != 16){	//Enter
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
		view.layer?.backgroundColor = NSColor(.sand6).cgColor
	}
	
	private func setBackground(){
		if(self.isSelected){
			view.layer?.backgroundColor = NSColor(.sand1).cgColor
			activateCloseButton()
		}else{
			view.layer?.backgroundColor = NSColor(.transparent).cgColor
			hideCloseButton()
		}
	}
	
	private func activateCloseButton(){
		closeButton.isEnabled = true
		closeButton.isHidden = false
		closeButton.contentTintColor = NSColor(.sand9)
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
			if(viewModel.webView?.url?.absoluteString != nil){
				let img = await FaviconProvider.instance.fetchIcon( viewModel.webView!.url!.absoluteString)
				parentController?.setTabIcon(at: tabPosition, icon: img)
				self.setIcon(img: img)
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
				self.tabHeadTitle.enableEditing(urlStr: viewModel.webView?.url?.absoluteString ?? viewModel.content)
			}
		}else{
			removeEditingStyle()
			self.tabHeadTitle.disableEditing(title: viewModel.webView?.getTitle() ?? viewModel.title)
		}
		
		if(viewModel.isSelected){
			self.tabHeadTitle.textColor = NSColor.sand12
		}else{
			self.tabHeadTitle.textColor = NSColor.sand11
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
		let isFrameActive = parentController?.myView.frameIsActive
		if(isFrameActive != nil && !isFrameActive!){
			//sets current frame active
			parentController?.myView.mouseDown(with: event)
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
	
	override func rightMouseDown(with event: NSEvent) {
		let isFrameActive = parentController?.myView.frameIsActive
		if(isFrameActive != nil && !isFrameActive!){
			//sets current frame active
			parentController?.myView.mouseDown(with: event)
			return
		}
		if(!self.isSelected && !tabHeadTitle.isEditable && event.clickCount == 1){
			selectSelf(mouseDownEvent: event)
			return
		}
		showRightClickMenu()
	}
	
	private func showRightClickMenu(){
		var adjustedPos = view.convert(view.frame.origin, to: nil)
		adjustedPos.x -= 15.0
		let menuWindow = NiMenuWindow(
			origin: adjustedPos,
			dirtyMenuItems: [
				NiMenuItemViewModel(
					title: "Pin to menu bar",
					isEnabled: true,
					mouseDownFunction: self.pinToTopbar
				),
				NiMenuItemViewModel(
					title: "Move to another space (soon)",
					isEnabled: false,
					mouseDownFunction: nil
				)
			],
			currentScreen: view.window!.screen!,
			adjustOrigin: true)
		menuWindow.makeKeyAndOrderFront(nil)
	}
	
	func pinToTopbar(with event: NSEvent){
		parentController?.pinTabToTopbar(at: tabPosition)
	}
	
}
