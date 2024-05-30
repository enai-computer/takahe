//Created on 9.10.23

import Cocoa

class NiSpaceView: NSView{
 
	override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
//		return .copy
		return .generic
	}
	
	override func draggingEnded(_ sender: any NSDraggingInfo) {
		
		//TODO: continue here
		print("oh no")
		guard let controller = nextResponder as? NiSpaceViewController else {return}
		//get IMG from here:
		sender.draggingPasteboard
		
		//get location where to position here
		sender.draggingLocation
		
//		controller.pasteImage(image: <#T##NSImage#>, positioned: <#T##CGPoint#>)
	}
}
