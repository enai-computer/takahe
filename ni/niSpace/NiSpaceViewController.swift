//Created on 9.10.23

import Cocoa

class NiSpaceViewController: NSViewController{
    
    private var niSpaceID: UUID? = nil
    private var niSpaceName: String? = nil
    
    @IBOutlet var niDocument: NiSpaceDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "NiSpaceView", owner: self)! as! NiSpaceView
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
        
    @IBAction func updateSpaceName(_ sender: NSTextField) {
        niSpaceName = sender.stringValue
        sender.isEditable = false
    }
    
    func setSpaceName(_ name: String){
        self.niSpaceName = name
        let niView = view as! NiSpaceView
        niView.setSpaceName(name)
    }
    
    
    @IBAction func returnToHome(_ sender: NSButton) {
        storeSpace()
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.switchToHome()
    }
    
    
    @IBAction func avatarClick(_ sender: NSImageView) {
        
    }
    
    @IBAction func runWebSearch(_ searchField: NSSearchField) {
        //TODO: refactor
        let searchView = runGoogleSearch(searchField.stringValue, owner: self)

        self.niDocument.addNiFrame(searchView)
        searchView.setFrameOwner(self.niDocument)
    }
    
    func loadStoredSpace(niSpaceID: UUID, name: String){
        self.setSpaceName(name)
        self.niSpaceID = niSpaceID
        do{
            let docJson = (DocumentTable.fetchDocumentModel(id: niSpaceID)?.data(using: .utf8))!
            let jsonDecoder = JSONDecoder()
            let docModel = try jsonDecoder.decode(NiDocumentObjectModel.self, from: docJson)
            if (docModel.type == NiDocumentObjectTypes.document){
                let data = docModel.data as! NiDocumentModel
                let children = data.children as! [NiDocumentObjectModel]
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
        
        let url = CachedWebTable.fetchURL(contentId: data.children[0].id)
        let storedWebsite = openWebsiteInNewContentFrame(
            urlStr: url,
            initPosition: NSRect(
                origin: CGPoint(x: data.position.x.px, y: data.position.y.px),
                size: CGSize(width: data.width.px, height: data.height.px)))
        self.niDocument.addNiFrame(storedWebsite)
        storedWebsite.setFrameOwner(self.niDocument)

    }
    
    func storeSpace(){
        if(niSpaceID == nil){
            niSpaceID = UUID()
        }
        
        if(niSpaceName == nil){
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            niSpaceName = "Space from " + displayFormatter.string(from: Date())
        }

        let documentJson = genJson()
        
        DocumentTable.upsertDoc(id: niSpaceID!, name: niSpaceName!, document: documentJson)
        
        niDocument.activeNiFrames.first?.storeContent(documentId: niSpaceID!)
    }
    
    func genJson() -> String{
        
        var children: [NiDocumentObjectModel] = []
        for frame in niDocument.activeNiFrames {
            children.append(frame.toNiContentFrameModel())
        }
            
        let toEncode = NiDocumentObjectModel(
            type: NiDocumentObjectTypes.document,
            data: NiDocumentModel(
                id: niSpaceID!,
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
