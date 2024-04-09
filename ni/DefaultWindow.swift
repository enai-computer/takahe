//Created on 17.09.23

import Cocoa
import Carbon.HIToolbox

class DefaultWindow: NSWindow{
 
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.center()
    }
	
	override func keyDown(with event: NSEvent) {
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
	
}
