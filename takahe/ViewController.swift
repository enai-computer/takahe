//Created on 11.09.23

import Cocoa
import WebKit


class ViewController: NSViewController {

    
    @IBAction func mainSearch(_ searchField: NSSearchField) {
        
        let searchView = runGoogleSearch(searchField.stringValue)
        let window = NSApplication.shared.keyWindow
        window?.contentView?.addSubview(searchView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = EnaiColors.DefaultBackground // colorNamed("DefaultBackgroundColor")
        // Do any additional setup after loading the view.
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

