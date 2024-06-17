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
		let homeView = NiHomeWindow(windowToAppearOn: window!)
		homeView.makeKeyAndOrderFront(nil)
    }
	
	func windowDidChangeScreen(_ notification: Notification) {
//		guard let windowObj = notification.object as? NSWindow else{return}
//		
//		if(prevScreenSize != windowObj.frame.size){
////			print("screen size changed, from: \(prevScreenSize) to \(windowObj.frame.size)")
//			if(prevScreenSize != nil && prevScreenSize!.width != windowObj.frame.size.width){
//				guard let spaceViewController = contentViewController as? NiSpaceViewController else {return}
//				spaceViewController.returnToHomeAndForceReload()
//			}
//			prevScreenSize = windowObj.frame.size
//		}
		

	}

	func windowWillClose(_ notification: Notification) {
		NSApplication.shared.terminate(nil)
	}
}
