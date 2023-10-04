//Created on 11.09.23

import Cocoa
import WebKit


class ViewController: NSViewController {

    
    var topNiFrame: ContentFrameView? = nil

    var activeNiFrames: [ContentFrameView] = []
    
    @IBAction func mainSearch(_ searchField: NSSearchField) {
        let searchView = runGoogleSearch(searchField.stringValue, owner: self)
        let window = NSApplication.shared.keyWindow
        window?.contentView?.addSubview(searchView)
        
        for niFrame in activeNiFrames{
            niFrame.droppedInViewStack()
        }
        activeNiFrames.insert(searchView, at: 0)
        setTopNiFrame(window, searchView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = NSColor(.sandLight3).cgColor
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        (NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject])?.first?.perform(#selector(NSWindow.toggleFullScreen(_:)))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
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
        window?.makeFirstResponder(topNiFrame)
       
        topNiFrame?.toggleActive()
    }
}

