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
    
    func getNewView(_ owner: Any?) -> NiSpaceView{
        let niSpaceView: NiSpaceView = NSView.loadFromNib(nibName: "NiSpaceView", owner: owner)! as! NiSpaceView
        return niSpaceView
    }
    
    
    @IBAction func updateSpaceName(_ sender: NSTextField) {
        
        niSpaceName = sender.stringValue
        sender.isEditable = false
    }
    
    func setSpaceName(_ name: String){
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
    
    func storeSpace(){
        if(niSpaceID == nil){
            niSpaceID = UUID()
        }
        
        if(niSpaceName == nil){
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            niSpaceName = "Space from " + displayFormatter.string(from: Date())
        }

        DocumentTable.insertDoc(id: niSpaceID!, name: niSpaceName!, document: nil)
        
        niDocument.activeNiFrames.first?.storeContent(documentId: niSpaceID!)
    }
    
}
