//Created on 11.09.23

import Cocoa
import WebKit


class ViewController: NSViewController {

    
    @IBAction func mainSearch(_ searchField: NSSearchField) {

    }
    
    @IBAction func openNewSpace(_ sender: NSButton) {
        let window = NSApplication.shared.keyWindow!
//        let newSpaceController = NiSpaceViewController()
//        let newSpace = newSpaceController.getNewView(window)
//        
//        window.contentView = newSpace
//        window.contentViewController = newSpaceController
//        
        let niSpaceController = NiSpaceViewController()
        window.contentViewController = niSpaceController
        niSpaceController.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(.sandLight3).cgColor
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

