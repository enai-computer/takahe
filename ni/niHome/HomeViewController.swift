//Created on 12.10.23

import Cocoa

class HomeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{

    
    private var lstOfDocuments: [NiDocument] = [NiDocument]()
    @IBAction func mainSearch(_ searchField: NSSearchField) {

    }
  
    @IBAction func openNewSpace(_ sender: NSButton) {
        print("!WORKS!")
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.switchToNewSpace()
    }
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "HomeView", owner: self)!
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lstOfDocuments = DocumentTable.fetchListofDocs()
    }
    
    override func viewDidAppear() {
        if (NSApplication.shared.presentationOptions.contains(.fullScreen)){
            return
        }
        (NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject])?.first?.perform(#selector(NSWindow.toggleFullScreen(_:)))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return lstOfDocuments.count
    }
  
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let cv = NiTableCellView()
        cv.setData(data: lstOfDocuments[row])

        return cv
    }

    
}

class NiTableCellView: NSView{
    
    private var data: NiDocument? = nil
    
    func setData(data: NiDocument){
        self.data = data
        let label = NSTextField(labelWithString: (data.name ?? "nameless"))
        self.addSubview(label)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        if (event.clickCount == 2){
            print("Works!")
        }
    }
}
