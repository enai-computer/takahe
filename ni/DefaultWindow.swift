//Created on 17.09.23

import Cocoa
import Carbon.HIToolbox

class DefaultWindow: NSWindow{
 
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.center()
		self.standardWindowButton(.miniaturizeButton)?.isHidden = true
		self.standardWindowButton(.zoomButton)?.isHidden = true
    }
	
	override func keyDown(with event: NSEvent) {
		
		if(event.modifierFlags.contains(.command)){
			
			if(event.keyCode == kVK_ANSI_N){
				handleCMD_N()
				return
			}
			
			if(event.keyCode == kVK_ANSI_W){
				handleCMD_W()
				return
			}
			
			if(event.keyCode == kVK_ANSI_R){
				handleCMD_R()
				return
			}
		}
		
		switch Int(event.keyCode) {
			case kVK_Escape:
				print("Esc pressed")
				return
			default:
				break
		}
		super.keyDown(with: event)
	}
	
	override func cancelOperation(_ sender: Any?) {
		return
	}
	
	override func toggleToolbarShown(_ sender: Any?) {
		//do nothing
		var i = 0
		i += 1
	}
	
	func handleCMD_N(){
		if let controller = contentViewController as? NiSpaceViewController{
			controller.openEmptyCF()
		}
	}
	
	func handleCMD_W(){
		if let controller = contentViewController as? NiSpaceViewController{
			controller.closeTabOfTopCF()
		}
	}
	
	func handleCMD_R(){
		if let controller = contentViewController as? NiSpaceViewController{
			controller.reloadTabOfTopCF()
		}
	}
}
