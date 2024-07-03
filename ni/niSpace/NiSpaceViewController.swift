//Created on 9.10.23

import Cocoa
import Carbon.HIToolbox
import PostHog
import AppKit
import PDFKit

class NiSpaceViewController: NSViewController, NSTextFieldDelegate{
    
	private(set) var spaceLoaded: Bool = false
    private var niSpaceName: String
	private var niSpaceID: UUID
	
	//header elements here:
	@IBOutlet var header: NSBox!
	@IBOutlet var time: NSTextField!
	@IBOutlet var spaceName: NSTextField!
	private var currentSpaceName: String?

	@IBOutlet var niScrollView: NiScrollView!
	@IBOutlet var niDocument: NiSpaceDocumentController!
	private let documentCache = NiDocControllerCache()
	private let EMPTY_SPACE_ID = UUID(uuidString:"00000000-0000-0000-0000-000000000000")!
	
	init(){
		self.niSpaceName = ""
		self.niSpaceID = EMPTY_SPACE_ID
		super.init(nibName: nil, bundle: nil)
		view.registerForDraggedTypes([.png, .tiff])
	}
	
	init(niSpaceID: UUID, niSpaceName: String) {
		self.niSpaceName = niSpaceName
		self.niSpaceID = niSpaceID
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
		styleEndEditSpaceName()
		setAutoUpdatingTime()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
	}
 
	@IBAction func paste(_ sender: NSMenuItem){
		let pasteBoardType = NSPasteboard.general.containsImgPdfOrText()
		
		if(pasteBoardType == .image){
			tryPasteImg()
		}else if(pasteBoardType == .pdf){
			tryPastePdf()
		}
	}
	
	private func tryPasteImg(){
		if let img = NSPasteboard.general.getImage(){
			let title = NSPasteboard.general.tryGetName()
			let source = NSPasteboard.general.tryGetFileURL()
			let pos = view.window!.mouseLocationOutsideOfEventStream
			pasteImage(image: img, screenPosition: pos, title: title, source: source)
		}
	}
	
	private func tryPastePdf(){
		if let pdf = NSPasteboard.general.getPdf(){
			let title = NSPasteboard.general.tryGetName()
			let source = NSPasteboard.general.tryGetFileURL()
			let pos = view.window!.mouseLocationOutsideOfEventStream
			pastePdf(pdf: pdf, screenPosition: pos, title: title, source: source)
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
    
	func openPalette(saveCurrentSpace: Bool = true) {
		if(saveCurrentSpace){
			storeCurrentSpace()
		}
		let	palette = NiPalette()
		palette.makeKeyAndOrderFront(nil)
	}
	
	func openHome(){
		openEmptyBackgroundSpace()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
			let homeView = NiHomeWindow(windowToAppearOn: self.view.window!)
			homeView.makeKeyAndOrderFront(nil)
		}
	}
	
	private func openEmptyBackgroundSpace(){
		let spaceDoc = getEmptySpaceDocument(id: EMPTY_SPACE_ID, name: "")
		loadSpace(spaceId: EMPTY_SPACE_ID, name: "", spaceDoc: spaceDoc, scrollTo: nil)
	}
	
	func openEmptyCF(){
		niDocument.openEmptyCF()
	}
	
	func pastePdf(pdf: PDFDocument, screenPosition at: CGPoint, title: String?, source: String?){
		var position = at
		position.y = niScrollView.documentView!.visibleRect.size.height - position.y + niScrollView.documentView!.visibleRect.origin.y
		
		let cfController = niDocument.openEmptyCF(viewState: .frameless, initialTabType: .pdf, positioned: position, size: CGSize(width: 300.0, height: 600.0))
		cfController.openPdfInNewTab(tabTitle: title, content: pdf, source: source)
	}
	
	func pasteImage(image: NSImage, screenPosition at: CGPoint, title: String?, source: String?){
		var position = at
		position.y = niScrollView.documentView!.visibleRect.size.height - position.y + niScrollView.documentView!.visibleRect.origin.y
		self.pasteImage(image: image, documentPosition: position, title: title, source: source)
	}
	
	func pasteImage(image: NSImage, documentPosition at: CGPoint, title: String?, source: String?){
		let targetSize = imgSizing(image.size)
		image.size = targetSize
		let cfController = niDocument.openEmptyCF(viewState: .frameless, initialTabType: .img, positioned: at, size: targetSize)
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
	
	func createANote(positioned at: CGPoint, with content: String? = nil){
		niDocument.openEmptyCF(viewState: .frameless, initialTabType: .note, positioned: at, content: content)
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
		let pointOnDocument = niDocument.view.convert(event.locationInWindow, from: nil)
		let popUpDelegate = NiSpaceMenuPopup(parentController: self, originInDocument: pointOnDocument)
		_ = popUpDelegate.displayPopupWindow(event: event, screen: view.window!.screen!)
	}
	
	/*
	 * MARK: - mouse and key events here
	 */
	override func mouseDown(with event: NSEvent) {
		//TODO: ignore key down when HomeView is shown
		var cursorPos = self.header.convert(event.locationInWindow, from: nil)

		if(NSPointInRect(cursorPos, spaceName.frame)){
			if(event.clickCount == 1){
				var adjustedPos = header.convert(spaceName.frame.origin, to: nil)
				adjustedPos.x -= 15.0
				let menuWindow = NiMenuWindow(
					origin: adjustedPos,
					dirtyMenuItems: self.getSpaceNameMenuItems(),
					currentScreen: view.window!.screen!,
					adjustOrigin: true)
				menuWindow.makeKeyAndOrderFront(nil)
			}
			return
		}
		
		cursorPos = self.view.convert(event.locationInWindow, from: nil)
		if(NSPointInRect(cursorPos, header.frame)){
			openPalette()
			return
		}
		
		if(event.clickCount == 2){
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
    
	func triggerSpaceDeletion(with event: NSEvent){
		let deletionMenuPanel = NiAlertPanelController()
		deletionMenuPanel.loadView()
		
		let alertPanel = NiFullscreenPanel(deletionMenuPanel)
		deletionMenuPanel.deleteFunction = self.deleteCurrentSpaceAndGoHome
		
		alertPanel.makeKeyAndOrderFront(nil)
	}
	
	func deleteCurrentSpaceAndGoHome(_ sender: Any? = nil){
		let spaceIDToDelete = niSpaceID
		openHome()
		DocumentTable.deleteDocument(id: spaceIDToDelete)
	}
	
	func editSpaceName(with event: NSEvent){
		guard !spaceName.isEditable else {return}
		
		currentSpaceName = spaceName.stringValue
		spaceName.refusesFirstResponder = false
		spaceName.isSelectable = true
		spaceName.isEditable = true
		
		spaceName.focusRingType = .none
		spaceName.delegate = self
		
		view.window?.makeFirstResponder(spaceName)
	}
	
	
	func controlTextDidEndEditing(_ obj: Notification){
		spaceName.currentEditor()?.selectedRange = NSMakeRange(0, 0)
		spaceName.isEditable = false
		spaceName.isSelectable = false
		spaceName.refusesFirstResponder = true
		styleEndEditSpaceName()
		
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			revertRenamingChanges()
			return
		}
		if(spaceName.stringValue.isEmpty){
			revertRenamingChanges()
			return
		}
		niSpaceName = spaceName.stringValue
		niDocument.niSpaceName = niSpaceName
		DocumentTable.updateName(id: self.niSpaceID, name: niSpaceName)
	}
	
	func styleEndEditSpaceName(){
		spaceName.refusesFirstResponder = true
		spaceName.isSelectable = false
		spaceName.isEditable = false
		spaceName.isEnabled = true
	}
	
	private func revertRenamingChanges(){
		spaceName.stringValue = currentSpaceName!
		currentSpaceName = nil
	}
	
	private func getSpaceNameMenuItems() -> [NiMenuItemViewModel]{
		return [
			NiMenuItemViewModel(
				title: "Rename this space",
				isEnabled: true,
				mouseDownFunction: self.editSpaceName
			),
			NiMenuItemViewModel(
				title: "Delete this space",
				isEnabled: true,
				mouseDownFunction: self.triggerSpaceDeletion
			)
		]
	}
	
	/*
	 * MARK: - load and store Space here
	 */
	private func getEmptySpaceDocument(id: UUID, name: String, height: CGFloat? = nil) -> NiSpaceDocumentController{
		let controller = NiSpaceDocumentController(id: id, name: name, height: height)
		
		return controller
	}
	
	func reloadSpace(){
		loadSpace(spaceId: niSpaceID, name: niSpaceName)
	}
	
	func createSpace(name: String){
		let spaceId = UUID()
		let spaceDoc = getEmptySpaceDocument(id: spaceId, name: name)
		
		niSpaceName = name
		spaceName.stringValue = name
		self.niSpaceID = spaceId
				
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
	
	func loadSpace(spaceId id: UUID, name: String){
		let (spaceDoc, scrollTo) = getSpaceDoc(id, name: name)
		self.loadSpace(spaceId: id, name: name, spaceDoc: spaceDoc, scrollTo: scrollTo)
	}
	
	private func loadSpace(spaceId id: UUID, name: String, spaceDoc: NiSpaceDocumentController, scrollTo: NSPoint?){
		niSpaceName = name
		spaceName.stringValue = name
		self.niSpaceID = id
		
		pauseMediaPlayback(niDocument)
		
		if(Storage.instance.userConfig.spaceCachingEnabled){
			documentCache.addToCache(id: id, controller: spaceDoc)
		}
		
		addChild(spaceDoc)
		
		let oldDoc = niDocument
		transition(from: niDocument, to: spaceDoc, options: [.crossfade])
		
		self.niDocument = spaceDoc
		self.niScrollView.documentView = spaceDoc.view
		if(scrollTo != nil){
			self.niScrollView.scroll(self.niScrollView.contentView, to: scrollTo!)
		}
		self.spaceLoaded = true
		
		if(!Storage.instance.userConfig.spaceCachingEnabled){
			NiDocControllerCache.deinitOldDocument(oldDoc)
		}
		
		let nrOfTimesLoaded = (NSApplication.shared.delegate as! AppDelegate).spaceLoadedSinceStart(id)
		PostHogSDK.shared.capture("Space_loaded", properties: ["loaded_since_AppStart": nrOfTimesLoaded])
	}
	
	private func pauseMediaPlayback(_ doc: NiSpaceDocumentController?){
		guard doc != nil else{return}
		for conFrame in doc!.myView.contentFrameControllers{
			conFrame.pauseMediaPlayback()
		}
	}
	
	private func getSpaceDoc(_ id: UUID, name: String) -> (NiSpaceDocumentController, NSPoint?) {
		let spaceModel = loadStoredSpace(niSpaceID: id)
		var scrollTo: NSPoint? = nil
		
		if(Storage.instance.userConfig.spaceCachingEnabled){
			if let cachedDoc = documentCache.getIfCached(id: id){
				scrollTo = tryGetScrolltoPos(spaceModel)
				return (cachedDoc, scrollTo)
			}
		}
		
		let spaceDoc: NiSpaceDocumentController
		
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
		
		return (spaceDoc, scrollTo)
	}

	func tryGetScrolltoPos(_ spaceModel: NiDocumentObjectModel?) -> NSPoint?{
		if (spaceModel?.type == NiDocumentObjectTypes.document){
			if let data = spaceModel?.data as? NiDocumentModel{
				if (data.viewPosition != nil && 10.0 < data.viewPosition!.px){
					return NSPoint(x: 0.0, y: data.viewPosition!.px)
				}
			}
		}
		return nil
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
