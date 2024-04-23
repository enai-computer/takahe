//Created on 9.10.23

import Cocoa
import Carbon.HIToolbox

class NiSpaceViewController: NSViewController{
    
	private var spaceLoaded: Bool = false
    private let niSpaceName: String
    
	//header elements here:
	@IBOutlet var header: NSBox!
	@IBOutlet var time: NSTextField!
	@IBOutlet var spaceName: NSTextField!
	
	@IBOutlet var niDocument: NiSpaceDocumentController!
	//	private var niDocument: NiSpaceDocumentController

	
	init(){
		self.niSpaceName = ""
//		self.niDocument = NiSpaceDocumentController()
		super.init(nibName: nil, bundle: nil)
	}
	
	init(niSpaceID: UUID, niSpaceName: String) {
//		self.niDocument = NiSpaceDocumentController(niSpaceID: niSpaceID, niSpaceName: niSpaceName)
		self.niSpaceName = niSpaceName
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = NSView.loadFromNib(nibName: "NiSpaceView", owner: self)! as! NiSpaceView
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
    
	func returnToHome() {
		niDocument.storeSpace()
		let hostingController = HomeViewController(presentingController: self)
		hostingController.show()
	}
	
	func openEmptyCF(){
		niDocument.openEmptyCF()
	}
	
	func closeTabOfTopCF(){
		niDocument.closeTabOfTopCF()
	}
	
	/*
	 * MARK: - mouse and key events here
	 */
	override func mouseDown(with event: NSEvent) {
		let cursorPos = self.view.convert(event.locationInWindow, from: nil)
		if(NSPointInRect(cursorPos, header.frame)){
			returnToHome()
		}else{
			nextResponder?.mouseDown(with: event)
		}
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.modifierFlags.contains(.command)){
			print("caught in SpaceView Controller")
		}
		
		if(event.modifierFlags.contains(.command) && event.keyCode == kVK_ANSI_N){
			openEmptyCF()
			return
		}
		nextResponder?.keyDown(with: event)
	}
	
    

    
	/*
	 * MARK: - load and store Space here
	 */
	func loadSpace(){
		
	}
	
	func loadSpace(niSpaceID: UUID, name: String){
		
	}

    
}
