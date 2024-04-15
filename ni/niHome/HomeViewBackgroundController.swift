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
		
		//TODO: move this to it's own function, so it can always overlay the screen
		let w = self.view.frame.width
		let h = self.view.frame.height
		
		let hostingController = NSHostingController(rootView: HomeView())
		hostingController.preferredContentSize = NSSize(width: w, height: h)
		hostingController.sizingOptions = .preferredContentSize
		hostingController.view.frame.size.width = w
		hostingController.view.frame.size.height = h
		
		self.present(hostingController, asPopoverRelativeTo: NSRect(x: 0, y: 0, width: 0, height: 0), of: self.view, preferredEdge: .maxX, behavior: .applicationDefined)
//		self.dismiss(hostingController)
    }

	override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

