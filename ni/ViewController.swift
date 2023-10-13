//Created on 11.09.23

import Cocoa
import WebKit


class ViewController: NSViewController {

    
    @IBAction func mainSearch(_ searchField: NSSearchField) {

    }
    
    @IBAction func openNewSpace(_ sender: NSButton) {
        let window = NSApplication.shared.keyWindow!
        let newSpace = NiSpaceViewController.getNewView(window)
        
        window.contentView = newSpace
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(red: 243.0, green: 243.0, blue: 242.0, alpha: 0.99).cgColor //NSColor(.sandLight3).cgColor
    }
    
    override func viewDidAppear() {
        (NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject])?.first?.perform(#selector(NSWindow.toggleFullScreen(_:)))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
   
}

