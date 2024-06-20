//Created on 9.10.23

import Cocoa

class NiSpaceView: NSView{
 
	override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
		//tried .copy, .generic, .move, .every
		//TODO: find a way to stop recoil back to source
		return .generic
	}
	
	override func draggingEnded(_ sender: any NSDraggingInfo) {
		
		guard let controller = nextResponder as? NiSpaceViewController else {return}
		guard let img = sender.draggingPasteboard.getImage() else {return}

		let title = sender.draggingPasteboard.tryGetName()
		let source = (sender.draggingSource as! NiWebView).url?.absoluteString
		
		controller.pasteImage(image: img, screenPosition: sender.draggingLocation, title: title, source: source)
	}
}
