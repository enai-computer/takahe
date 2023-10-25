//Created on 12.10.23

import Cocoa

class HomeViewController: NSViewController {

    
    @IBAction func mainSearch(_ searchField: NSSearchField) {

    }
  
    //        generateKoreaView()
    //
    
    @IBAction func openNewSpace(_ sender: NSButton) {
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.switchToNewSpace()
    }

    @IBAction func korea(_ sender: NSButton) {
        generateKoreaView()
    }
    
    @IBAction func enai(_ sender: NSButton) {
        generateFigmaView()
    }
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "HomeView", owner: self)!
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    
   
}
