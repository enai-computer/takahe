//
//  NiScrollController.swift
//  ni
//
//  Created by Patrick Lukas on 10/28/23.
//

import Cocoa
import Foundation

let EMPTYSPACEFACTOR: Double = 0.3

class NiSpaceDocument: NSView{
        
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        let window = NSApplication.shared.keyWindow!
        self.frame.size.height = window.frame.height * (1+EMPTYSPACEFACTOR)
    }
    
    override var isFlipped: Bool{
        return true
    }
    
    func extendDocumentDownwards(){
        let window = NSApplication.shared.keyWindow!
        self.frame.size.height += window.frame.height * EMPTYSPACEFACTOR
    }
    
    /*
     * MARK: Window like functions for niFrames below:
     *
     * TODO: fix activation and deactivation 
     */
    
    var topNiFrame: ContentFrameController? = nil
    var drawnNiFrames: [ContentFrameController] = []	//rn all niFrames are drawn. Needs to be reworked in future
    
    func addNiFrame(_ subViewController: ContentFrameController){
		self.addSubview(subViewController.view)
        
        for niFrame in drawnNiFrames{
			//TODO: fix this behaviour
//            niFrame.droppedInViewStack()
        }
        drawnNiFrames.insert(subViewController, at: 0)
        
        setTopNiFrame(NSApplication.shared.keyWindow, subViewController)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if topNiFrame == nil{
            return
        }
        
        let cursorPos = self.convert(event.locationInWindow, from: nil)
        let newTopFrame = inFrame(cursorPos)
        
        if (newTopFrame == nil || self.topNiFrame == newTopFrame){
            return
        }

//        let posInViewStack = newTopFrame?.getPositionInViewStack()
//        activeNiFrames.remove(at: posInViewStack!)
		
        for niFrame in drawnNiFrames{
            niFrame.droppedInViewStack()
        }
        drawnNiFrames.insert(newTopFrame!, at: 0)
        
        setTopNiFrame(NSApplication.shared.keyWindow, newTopFrame!)
    }
    
    private func inFrame(_ cursorPoint: CGPoint) -> ContentFrameController?{
        
        for niFrame in drawnNiFrames {
			if NSPointInRect(cursorPoint, niFrame.view.frame){
                return niFrame
            }
        }
        return nil
    }

    private func setTopNiFrame(_ window: NSWindow?, _ newTopFrame: ContentFrameController){

        topNiFrame?.toggleActive()
        
        //switch
		newTopFrame.view.removeFromSuperview()
		self.addSubview(newTopFrame.view)
        topNiFrame = newTopFrame

        topNiFrame?.toggleActive()
    }
    
    func persistContent(documentId: UUID){
        for contentFrame in drawnNiFrames{
            contentFrame.persistContent(documentId: documentId)
        }
    }
}
