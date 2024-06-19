//Created on 9.10.23

import Cocoa
import Carbon.HIToolbox
import PostHog
import AppKit

class NiSpaceViewController: NSViewController{
    
	private(set) var spaceLoaded: Bool = false
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
		view.registerForDraggedTypes([.png, .tiff])
	}
	
	init(niSpaceID: UUID, niSpaceName: String) {
		self.niSpaceName = niSpaceName
		super.init(nibName: nil, bundle: nil)
		view.registerForDraggedTypes([.png, .tiff])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = NSView.loadFromNib(nibName: "NiSpaceView", owner: self)! as! NiSpaceView
		addChild(niDocument)
		
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = NSColor(.sand1).cgColor
		
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
	}
 
	@IBAction func paste(_ sender: NSMenuItem){
		if let img = NSPasteboard.general.getImage(){
			let title = NSPasteboard.general.tryGetName()
			let source = NSPasteboard.general.tryGetFileURL()
			let pos = view.window!.mouseLocationOutsideOfEventStream
			pasteImage(image: img, positioned: pos, title: title, source: source)
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
		header.contentView?.layer?.backgroundColor = NSColor(.sand2).cgColor
		header.contentView?.layer?.borderColor = NSColor(.sand2).cgColor
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
		if(saveCurrentSpace){
			storeCurrentSpace()
		}
		let	palette = NiPalette()
		palette.makeKeyAndOrderFront(nil)
	}
	
	func openEmptyCF(){
		niDocument.openEmptyCF()
	}
	
	func pasteImage(image: NSImage, positioned at: CGPoint, title: String?, source: String?){
		let targetSize = imgSizing(image.size)
		image.size = targetSize
		var position = at
		position.y = niScrollView.documentView!.visibleRect.size.height - position.y + niScrollView.documentView!.visibleRect.origin.y
		let cfController = niDocument.openEmptyCF(viewState: .frameless, initialTabType: .img, positioned: position, size: targetSize)
		cfController.openImgInNewTab(tabTitle: title, content: image, source: source)
	}
	
	private func imgSizing(_ initSize: CGSize) -> CGSize{
		var size = initSize
		let ratio = initSize.width/initSize.height
		
		//FIXME: clean-up
		if(size.width < 50.0){
			size.width = 50.0
			if(ratio.isNormal){
				size.height = 50.0 / ratio
			}else{
				size.height = 50.0
			}
		}
		if(500.0 < size.width){
			size.width = 500.0
			if(ratio.isNormal){
				size.height = 500.0 / ratio
			}else{
				size.height = 500.0
			}
		}
		if(size.height < 50.0){
			size.height = 50.0
			if(ratio.isNormal){
				size.width = 50.0 * ratio
			}else{
				size.width = 50.0
			}
		}
		if(500.0 < size.height){
			size.height = 500.0
			if(ratio.isNormal){
				size.width = 500.0 * ratio
			}else{
				size.width = 50.0
			}
		}
		return size
	}
	
	func createANote(positioned relavtiveTo: CGPoint? = nil, with content: String? = nil){
		var noteOrigin: CGPoint?
		if(spaceMenu != nil){
			noteOrigin = niDocument.view.convert(spaceMenu!.view.frame.origin, from: view)
			noteOrigin!.y -= spaceMenu!.view.frame.height
		}else if(relavtiveTo != nil){
			noteOrigin = niDocument.view.convert(relavtiveTo!, from: nil)
		}
		niDocument.openEmptyCF(viewState: .frameless, initialTabType: .note, positioned: noteOrigin, content: content)
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
		//TODO: ignore key down when HomeView is shown
		let cursorPos = self.view.convert(event.locationInWindow, from: nil)
		
		if(NSPointInRect(cursorPos, header.frame)){
			returnToHome()
			return
		}
		if(event.clickCount == 1){
			showSpaceMenu(event)
		}
		
		if(event.clickCount == 2){
			if let menuView = spaceMenu?.view as? NSView {
				menuView.removeFromSuperview()
			}
			spaceMenu = nil
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
		addNoteToEmptySpace(niDocument: niDocument)
		niDocument.openEmptyCF()
		niScrollView.documentView = niDocument.view
		
		PostHogSDK.shared.capture("Space_created")
		_ = (NSApplication.shared.delegate as! AppDelegate).spaceLoadedSinceStart(spaceId)
	}
	
	private func addNoteToEmptySpace(niDocument: NiSpaceDocumentController){
		if let message = loadNoteMessage(){
			niDocument.openEmptyCF(
				viewState: .frameless,
				initialTabType: .note,
				positioned: NSPoint(x: 30.0, y: 90.0),
				size: CGSize(width: 540.0, height: 460.0),
				content: message
			)
		}
	}
	
	private func loadNoteMessage() -> String?{
		do{
			let path = Bundle.main.url(forResource: "NewSpaceNote", withExtension: "json")
			let jsonDoc = NSData(contentsOf: path!)
			let jsonDecoder = JSONDecoder()
			let docModel = try jsonDecoder.decode(WelcomeNoteDataModel.self, from: jsonDoc! as Data)
			return docModel.message
		}catch{
			print(error)
		}
		return nil
	}
	
	struct WelcomeNoteDataModel: Codable{
		var message: String
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
		let oldDocController: NiSpaceDocumentController = niDocument
		transition(from: niDocument, to: spaceDoc, options: [.crossfade])
		
		self.niDocument = spaceDoc
		self.niScrollView.documentView = spaceDoc.view
		if(scrollTo != nil){
			self.niScrollView.scroll(self.niScrollView.contentView, to: scrollTo!)
		}
		self.spaceLoaded = true
		
		deinitOldDocument(for: oldDocController)
		
		let nrOfTimesLoaded = (NSApplication.shared.delegate as! AppDelegate).spaceLoadedSinceStart(id)
		PostHogSDK.shared.capture("Space_loaded", properties: ["loaded_since_AppStart": nrOfTimesLoaded])
	}
	
	private func deinitOldDocument(for doc: NiSpaceDocumentController){
		for conFrame in doc.myView.contentFrameControllers{
			conFrame.deinitSelf()
		}
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
    
	func switchToNextTab() {
		niDocument.myView.switchToNextTab()
	}
	
	func createNewTab() {
		niDocument.myView.createNewTab()
	}
	
	func switchToPrevTab() {
		niDocument.myView.switchToPrevTab()
	}
	
	func toggleEditMode(){
		niDocument.myView.toggleEditMode()
	}
	
	func toggleMinimizeOnTopCF(_ sender: NSMenuItem) {
		niDocument.myView.toggleMinimizeOnTopCF(sender)
	}
	
	func switchToNextWindow() {
		niDocument.myView.switchToNextCF()
	}
	
	func switchToPrevWindow() {
		niDocument.myView.switchToNextCF(goFwd: false)
	}
}
