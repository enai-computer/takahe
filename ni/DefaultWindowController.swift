//Created on 07.10.23

import Cocoa

class DefaultWindowController: NSWindowController{
    
    override func windowDidLoad() {
        super.windowDidLoad()
		window?.toggleFullScreen(nil)

		contentViewController = NiSpaceViewController()

		//HELP: in case you need to know the fonts
//		for family: String in NSFontManager.shared.availableFonts{
//			print(family)
//		}
    }
	
}
