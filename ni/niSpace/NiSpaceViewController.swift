//Created on 9.10.23

import Cocoa

class NiSpaceViewController: NSViewController{
    
    private let niSpaceID: UUID
    private let niSpaceName: String
    
	//header elements here:
	@IBOutlet var header: NSBox!
	@IBOutlet var time: NSTextField!
	@IBOutlet var spaceName: NSTextField!
	
	@IBOutlet var niDocument: NiSpaceDocument!
	
	init(niSpaceID: UUID, niSpaceName: String) {
		self.niSpaceID = niSpaceID
		self.niSpaceName = niSpaceName
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
	override func mouseDown(with event: NSEvent) {
		let cursorPos = self.view.convert(event.locationInWindow, from: nil)
		if(NSPointInRect(cursorPos, header.frame)){
			returnToHome()
		}else{
			nextResponder?.mouseDown(with: event)
		}
	}
	
    func returnToHome() {
        storeSpace()
//        let appDelegate = NSApp.delegate as! AppDelegate
//        appDelegate.switchToHome()
		let hostingController = HomeViewController(presentingController: self)
		hostingController.show()
    }
    
    
    
    @IBAction func runWebSearch(_ searchField: NSSearchField) {
        //TODO: refactor
        let searchView = runGoogleSearch(searchField.stringValue, owner: self)

        self.niDocument.addNiFrame(searchView)
        searchView.setFrameOwner(self.niDocument)
    }
    
	/*
	 * MARK: - load and store Space here
	 */
    func loadStoredSpace(niSpaceID: UUID){
        do{
            let docJson = (DocumentTable.fetchDocumentModel(id: niSpaceID)?.data(using: .utf8))!
            let jsonDecoder = JSONDecoder()
            let docModel = try jsonDecoder.decode(NiDocumentObjectModel.self, from: docJson)
            if (docModel.type == NiDocumentObjectTypes.document){
                let data = docModel.data as! NiDocumentModel
				let children = data.children 
                for child in children{
                    let childData = child.data as! NiContentFrameModel
                    recreateContentFrame(data: childData)
                }
            }
        }catch{
            print(error)
        }
    }
    
    private func recreateContentFrame(data: NiContentFrameModel){
        let storedWebsiteContentFrame = reopenContentFrame(contentFrame: data, tabs: data.children)
        self.niDocument.addNiFrame(storedWebsiteContentFrame)
        storedWebsiteContentFrame.setFrameOwner(self.niDocument)
    }
    
    func storeSpace(){
        
        let documentJson = genJson()
        
        DocumentTable.upsertDoc(id: niSpaceID, name: niSpaceName, document: documentJson)
        
        niDocument.persistContent(documentId: niSpaceID)
    }
    
    func genJson() -> String{
        
        var children: [NiDocumentObjectModel] = []
        for frame in niDocument.drawnNiFrames {
            children.append(frame.toNiContentFrameModel())
        }
            
        let toEncode = NiDocumentObjectModel(
            type: NiDocumentObjectTypes.document,
            data: NiDocumentModel(
                id: niSpaceID,
                height: self.niDocument.frame.height,
                width: self.niDocument.frame.width,
                children: children
            )
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        do{
            let jsonData = try jsonEncoder.encode(toEncode)
            return String(data: jsonData, encoding: .utf8) ?? "FAILED GENERATING JSON"
        }catch{
            print(error)
        }
        return "FAILED GENERATING JSON"
    }
    
}
