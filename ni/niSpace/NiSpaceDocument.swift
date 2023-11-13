//
//  NiScrollController.swift
//  ni
//
//  Created by Patrick Lukas on 10/28/23.
//

import Cocoa

class NiSpaceDocument: NSView{
    
    /*
     * Window like functions for niFrames below:
     */
    
    var topNiFrame: ContentFrameView? = nil
    var activeNiFrames: [ContentFrameView] = []
    
    func addNiFrame(_ subView: ContentFrameView){
        self.addSubview(subView)
        
        for niFrame in activeNiFrames{
            niFrame.droppedInViewStack()
        }
        activeNiFrames.insert(subView, at: 0)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if topNiFrame == nil{
            return
        }
        
        let newTopFrame = inFrame(event.locationInWindow)
        
        if (newTopFrame == nil || self.topNiFrame == newTopFrame){
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
        if zVal != nil {
            topNiFrame?.layer?.zPosition = zVal! + 1     //TODO: fix at some point. May cause stack-overflow
        }
        window?.makeFirstResponder(topNiFrame)          //TODO: check if needed. May be a source for future bugs
       
        topNiFrame?.toggleActive()
    }
}
