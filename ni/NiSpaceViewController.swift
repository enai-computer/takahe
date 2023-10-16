//Created on 9.10.23

import Cocoa

class NiSpaceViewController: NSViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(.sandLight3).cgColor
    }
    
    func getNewView(_ owner: Any?) -> NiSpaceView{
        let niSpaceView: NiSpaceView = NSView.loadFromNib(nibName: "NiSpaceView", owner: owner)! as! NiSpaceView
        return niSpaceView
    }
    
    @IBAction func runWebSearch(_ searchField: NSSearchField) {
        let searchView = runGoogleSearch(searchField.stringValue, owner: self)

        addNiFrame(searchView)
    }
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "NiSpaceView", owner: self)! as! NiSpaceView
    }
    
    /*
     * Window like functions for niFrames below:
     */
    
    var topNiFrame: ContentFrameView? = nil
    var activeNiFrames: [ContentFrameView] = []
    
    func addNiFrame(_ subView: ContentFrameView){
        let window = NSApplication.shared.keyWindow
        window?.contentView?.addSubview(subView)
        
        
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
