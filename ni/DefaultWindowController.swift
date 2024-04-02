//Created on 07.10.23

import Cocoa

class DefaultWindowController: NSWindowController{
    
    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = HomeViewController()
    }
}
