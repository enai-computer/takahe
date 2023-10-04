//Created on 17.09.23

import Cocoa

class DefaultWindow: NSWindow{
 
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.center()
        let mainScreen: NSScreen = NSScreen.screens[0]
//        self.contentView?.addSubview(HomeView())
//        self.contentView?.enterFullScreenMode(mainScreen)
    }
    
}
