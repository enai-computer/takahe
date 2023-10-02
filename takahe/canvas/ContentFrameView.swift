//Created on 02.10.23

import Cocoa


struct CFConstants {
    static let x: CGFloat = 30
    static let y: CGFloat = 30
    static let wvWidth: CGFloat = 900
    static let wvHeight: CGFloat = 400
    static let wvBoarderWidth: CGFloat = 10.0
    static let wvBoarderHeight: CGFloat = 10.0
    static let width: CGFloat = wvWidth + wvBoarderWidth * 2
    static let height: CGFloat = wvHeight + wvBoarderHeight * 2
    static let boarderColor = NSColor(.sandLight3)
    static let boarderColorSelected = NSColor(.sandLight12)
 }

class ContentFrameView: NSBox{
    
    
    @IBOutlet var contentHeader: NSTextField!
    @IBOutlet var content: NSView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(contentHeader: String, content: NSView!) {
        super.init(frame: CGRect(x: CFConstants.x, y: CFConstants.y, width: CFConstants.width, height: CFConstants.height))
        self.contentHeader = NSTextField(string: contentHeader)
        self.content = content
    }
    
    
}
