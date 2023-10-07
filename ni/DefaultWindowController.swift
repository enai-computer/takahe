//Created on 07.10.23

import Cocoa

class DefaultWindowController: NSWindowController{

    override var acceptsFirstResponder: Bool
    
    var topNiFrame: ContentFrameView? = nil
    var activeNiFrames: [ContentFrameView] = []
    
    func addNiFrame(_ subView: ContentFrameView){
        self.window?.contentView?.addSubview(subView)
        
        for niFrame in activeNiFrames{
            niFrame.droppedInViewStack()
        }
        activeNiFrames.insert(subView, at: 0)
        setTopNiFrame(window, subView)
    }
    

    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if topNiFrame == nil{
            return
        }
        
        let newTopFrame = inFrame(event.locationInWindow)
        
        if newTopFrame == nil{
            return
        }

        let posInViewStack = newTopFrame?.getPositionInViewStack()
        
        activeNiFrames.remove(at: posInViewStack!)
        for niFrame in activeNiFrames{
            niFrame.droppedInViewStack()
        }
        activeNiFrames.insert(newTopFrame!, at: 0)
        
        setTopNiFrame(NSApplication.shared.keyWindow, newTopFrame!)
    }
    
    private func inFrame(_ cursorPoint: CGPoint) -> ContentFrameView?{
        
        if NSPointInRect(cursorPoint, topNiFrame!.frame){
            return nil
        }
        
        for niFrame in activeNiFrames {
            if NSPointInRect(cursorPoint, niFrame.frame){
                return niFrame
            }
        }
        return nil
    }

    private func setTopNiFrame(_ window: NSWindow?, _ newTopFrame: ContentFrameView){
        
        //getting old vals and updating old topFrame
        let zVal = topNiFrame?.layer?.zPosition ?? nil
        topNiFrame?.toggleActive()
        
        //switch
        topNiFrame = newTopFrame
        
        //updating new top Frame
//        if zVal != nil {
//            topNiFrame?.layer?.zPosition = zVal! + 1     //TODO: fix at some point. May cause stack-overflow
//        }
//        window?.makeFirstResponder(topNiFrame)
       
        topNiFrame?.toggleActive()
    }
}
