//Created on 12.10.23

import Cocoa
import SwiftUI


class HomeViewBackgroundController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "HomeViewBackground", owner: self)!
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
		

		let hostingController = HomeViewController(presentingController: self)
		hostingController.show()
    }

	override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

