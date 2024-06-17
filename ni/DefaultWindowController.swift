//Created on 07.10.23

import Cocoa

class DefaultWindowController: NSWindowController, NSWindowDelegate{
    
	private var prevScreenSize: CGSize? = nil
	
    override func windowDidLoad() {
        super.windowDidLoad()
		window?.toggleFullScreen(nil)
		window?.isReleasedWhenClosed = true
		window?.delegate = self
		contentViewController = NiSpaceViewController()

		//HELP: in case you need to know the fonts
//		for family: String in NSFontManager.shared.availableFonts{
//			print(family)
//		}
    }
	
	func windowDidEnterFullScreen(_ notification: Notification){
		let homeView = NiHomeWindow(windowToAppearOn: window!)
		homeView.makeKeyAndOrderFront(nil)
	}
	
	func windowDidChangeScreen(_ notification: Notification) {
		//TODO: build proper logic for resizing (& recognizing screen switiching properly :/, as the build in MAC logic get's triggered too often)
	}

	func windowWillClose(_ notification: Notification) {
		NSApplication.shared.terminate(nil)
	}
}
