//Created on 9.10.23

import Cocoa
import Carbon.HIToolbox
import PostHog
import AppKit

class NiSpaceViewController: NSViewController{
    
	private(set) var spaceLoaded: Bool = false
	var homeViewShown: Bool = false
    private var niSpaceName: String
	var spaceMenu: NiSpaceMenuController?
	
	//header elements here:
	@IBOutlet var header: NSBox!
	@IBOutlet var time: NSTextField!
	@IBOutlet var spaceName: NSTextField!

	@IBOutlet var niScrollView: NiScrollView!
	@IBOutlet var niDocument: NiSpaceDocumentController!

	init(){
		self.niSpaceName = ""
		super.init(nibName: nil, bundle: nil)
	}
	
	init(niSpaceID: UUID, niSpaceName: String) {
		self.niSpaceName = niSpaceName
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = NSView.loadFromNib(nibName: "NiSpaceView", owner: self)! as! NiSpaceView
		addChild(niDocument)
		
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
		
		time.stringValue = getLocalisedTime()
		spaceName.stringValue = niSpaceName
		
		setHeaderStyle()
		setAutoUpdatingTime()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		if(!spaceLoaded){
			let hostingController = HomeViewController(presentingController: self)
			hostingController.show()
		}
	}
 
	
	override func viewWillDisappear() {
		removeAutoUpdatingTime()
	}
	
	func setHeaderStyle(){
		header.contentView?.wantsLayer = true
		header.contentView?.layer?.cornerRadius = 30.0
		header.contentView?.layer?.cornerCurve = .continuous
		header.contentView?.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		header.contentView?.layer?.masksToBounds = true
		header.contentView?.layer?.backgroundColor = NSColor(.sandLight2).cgColor
		header.contentView?.layer?.borderColor = NSColor(.sandLight2).cgColor
		header.contentView?.layer?.borderWidth = 5
	}
        
	func setAutoUpdatingTime(){
		Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(setDisplayedTime), userInfo: nil, repeats: true)
	}
	
	func removeAutoUpdatingTime(){
		Timer.cancelPreviousPerformRequests(withTarget: setDisplayedTime())
	}
	
	@objc func setDisplayedTime(){
		let currentTime = getLocalisedTime()
		DispatchQueue.main.async {
			self.time.stringValue = currentTime
		}
	}
    
	func returnToHome(saveCurrentSpace: Bool = true) {
		//already at home
		if(homeViewShown){
			return
		}
		if(saveCurrentSpace){
			storeCurrentSpace()
		}
		niDocument.myView.isHidden = true
		let hostingController = HomeViewController(presentingController: self)
		hostingController.show(animate: saveCurrentSpace)
	}
	
	func returnToHomeAndForceReload(){
		returnToHome()
		spaceLoaded = false
	}
	
	func openEmptyCF(){
		niDocument.openEmptyCF()
	}
	
	func closeTabOfTopCF(){
		niDocument.closeTabOfTopCF()
	}
	
	func storeCurrentSpace(){
		niDocument.storeSpace(scrollPosition: niScrollView.documentVisibleRect.origin.y)
	}
	
	func reloadTabOfTopCF(){
		niDocument.reloadTabOfTopCF()
	}
	
	private func showSpaceMenu(_ event: NSEvent){
		if(spaceMenu != nil){
			return
		}
		spaceMenu = NiSpaceMenuController(owner: self)
		spaceMenu!.loadAndPositionView(position: event.locationInWindow, screenWidth: view.frame.width, screenHeight: view.frame.height)
		view.addSubview(spaceMenu!.view)
	}
	
	/*
	 * MARK: - mouse and key events here
	 */
	override func mouseDown(with event: NSEvent) {
		let cursorPos = self.view.convert(event.locationInWindow, from: nil)
		if(!homeViewShown && NSPointInRect(cursorPos, header.frame)){
			returnToHome()
			return
		}
		if(!homeViewShown){
			showSpaceMenu(event)
		}
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.modifierFlags.contains(.command) && event.keyCode == kVK_ANSI_N){
			openEmptyCF()
			return
		}
		nextResponder?.keyDown(with: event)
	}
	
    
	/*
	 * MARK: - load and store Space here
	 */
	private func getEmptySpaceDocument(id: UUID, name: String, height: CGFloat? = nil) -> NiSpaceDocumentController{
		let controller = NiSpaceDocumentController(id: id, name: name, height: height)
		
		return controller
	}
	
	func createSpace(name: String){
		niSpaceName = name
		spaceName.stringValue = name
		
		let spaceId = UUID()
		let spaceDoc = getEmptySpaceDocument(id: spaceId, name: name)
				
		addChild(spaceDoc)
		transition(from: niDocument, to: spaceDoc, options: [.crossfade])

		niDocument = spaceDoc
		
		spaceLoaded = true
		
		//Needs to happen here, as we rely on the visible view for size
		niDocument.openEmptyCF()
		niScrollView.documentView = niDocument.view
		
		PostHogSDK.shared.capture("Space_created")
		_ = (NSApplication.shared.delegate as! AppDelegate).spaceLoadedSinceStart(spaceId)
	}
	
	func loadSpace(niSpaceID id: UUID, name: String){
		let spaceDoc: NiSpaceDocumentController
		var scrollTo: NSPoint? = nil
		niSpaceName = name
		spaceName.stringValue = name
		
		let spaceModel = loadStoredSpace(niSpaceID: id)
		
		if(spaceModel == nil && id != WelcomeSpaceGenerator.WELCOME_SPACE_ID){
			spaceDoc = getEmptySpaceDocument(id: id, name: name)
		}else if(spaceModel == nil && id == WelcomeSpaceGenerator.WELCOME_SPACE_ID){
			spaceDoc = WelcomeSpaceGenerator.generateSpace(self.view.frame.size)
			niDocument.view.frame = spaceDoc.view.frame
		}else{
			let docHeightPx = (spaceModel?.data as? NiDocumentModel)?.height.px
			spaceDoc = getEmptySpaceDocument(id: id, name: name, height: docHeightPx)
			scrollTo = spaceDoc.recreateSpace(docModel: spaceModel!)
			
			niDocument.view.frame = spaceDoc.view.frame
		}
		
		addChild(spaceDoc)
		transition(from: niDocument, to: spaceDoc, options: [.crossfade])

		niDocument = spaceDoc
		niScrollView.documentView = spaceDoc.view
		if(scrollTo != nil){
			niScrollView.scroll(niScrollView.contentView, to: scrollTo!)
		}

		spaceLoaded = true
		
		let nrOfTimesLoaded = (NSApplication.shared.delegate as! AppDelegate).spaceLoadedSinceStart(id)
		PostHogSDK.shared.capture("Space_loaded", properties: ["loaded_since_AppStart": nrOfTimesLoaded])
	}

	private func loadStoredSpace(niSpaceID: UUID) -> NiDocumentObjectModel?{
		do{
			let docJson = (DocumentTable.fetchDocumentModel(id: niSpaceID)?.data(using: .utf8))
			if(docJson == nil){
				return nil
			}
			let jsonDecoder = JSONDecoder()
			let docModel = try jsonDecoder.decode(NiDocumentObjectModel.self, from: docJson!)
			return docModel
		}catch{
			print(error)
			(NSApplication.shared.delegate as! AppDelegate).disableSaveForSpace(niSpaceID)
		}
		return nil
	}
    
	func switchToNextTab(_ sender: NSMenuItem) {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.switchToNextTab(sender)
	}
	
	func createNewTab(_ sender: NSMenuItem) {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.createNewTab()
	}
	
	func switchToPrevTab(_ sender: NSMenuItem) {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.switchToPrevTab(sender)
	}
	
	func toggleMinimizeOnTopCF(_ sender: NSMenuItem) {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.toggleMinimizeOnTopCF(sender)
	}
	
	func switchToNextWindow() {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.switchToNextCF()
	}
	
	func switchToPrevWindow() {
		if(homeViewShown){
			__NSBeep()
			return
		}
		niDocument.myView.switchToNextCF(goFwd: false)
	}
}
