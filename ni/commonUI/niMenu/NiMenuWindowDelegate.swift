//
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuWindowDelegate: NSObject, NSWindowDelegate{

	func windowDidResignKey(_ notification: Notification) {
		if let window = notification.object as? NSPanel{
			window.orderOut(nil)
			window.close()
		}
	}
}
