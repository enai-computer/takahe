//Created on 03.10.23

import Cocoa

class ContentFrameHeader: NSTextField{
    
    override func mouseDown(with event: NSEvent) {
        self.isEditable = true
    }
    
}
