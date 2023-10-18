//Created on 02.10.23

import Cocoa
import WebKit

struct CFConstants {
    static let nibName: String = "ContentFrameView"
    static let x: CGFloat = 30
    static let y: CGFloat = 30
    static let wvWidth: CGFloat = 900
    static let wvHeight: CGFloat = 400
    static let wvBoarderWidth: CGFloat = 10.0
    static let wvBoarderHeight: CGFloat = 10.0
    static let width: CGFloat = wvWidth + wvBoarderWidth * 2
    static let height: CGFloat = wvHeight + wvBoarderHeight * 2
    static let boarderColor = NSColor(.sandLight9)
    static let boarderColorSelected = NSColor(.sandLight12)

    // const needed for resizing:
    static let actionArea: CGFloat = 6
    static let cornerActionArea: CGFloat = 32
 }


class ContentFrameView: NSBox{
    
    private var cursorDownPoint: CGPoint  = .zero
    private var cursorOnBorder: OnBorder = .no
    private var frameIsActive: Bool = false
    private var positionInViewStack: Int = 0     // 0 = up top
    
    @IBOutlet var contentHeader: ContentFrameHeader!
    
    @IBOutlet var closeButton: NSImageView!
    @IBOutlet var boundContent: NSView!
    var wkContent: WKWebView? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @IBAction func updateContent(_ newURL: ContentFrameHeader) {

        let urlReq = URLRequest(url: URL(string: newURL.stringValue)!)
        wkContent!.load(urlReq)
        
        contentHeader.stringValue = newURL.stringValue
        contentHeader.isEditable = false
    }

    
    func setContent(_ newContentView: WKWebView!){
        newContentView.frame.size = boundContent.frame.size
        newContentView.frame.origin = boundContent.frame.origin
        self.replaceSubview(boundContent, with: newContentView)
        self.wkContent = newContentView
    }

    
    /*
     * window like functions (moving and resizing) here:
     */
    override func mouseDown(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseDown(with: event)
        }
        
        super.mouseDown(with: event)
        
        //enable drag and drop niFrame to new postion and resizing
        cursorOnBorder = isOnBoarder(event.locationInWindow)
        if cursorOnBorder != .no{
            cursorDownPoint = event.locationInWindow
        }
        
        //clicked on close button
        let posInFrame = self.contentView!.convert(event.locationInWindow, from: nil)
        if NSPointInRect(posInFrame, closeButton.frame){
            removeFromSuperview()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseUp(with: event)
        }
        
        super.mouseUp(with: event)
        cursorDownPoint = .zero
        cursorOnBorder = .no
    }
    
    override func mouseDragged(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseDragged(with: event)
        }
        
        super.mouseDragged(with: event)

        if cursorOnBorder == OnBorder.no{
            return
        }
        
        let currCursorPoint = event.locationInWindow
        let horizontalDistanceDragged = currCursorPoint.x - cursorDownPoint.x
        let verticalDistanceDragged = currCursorPoint.y - cursorDownPoint.y
        
        //Update here, so we don't have a frame running quicker then the cursor
        cursorDownPoint = currCursorPoint
        
        switch cursorOnBorder {
            case .top:
                repositionView(horizontalDistanceDragged, verticalDistanceDragged)
            case .bottomRight:
                enaiResize(horizontalDistanceDragged, verticalDistanceDragged)
        default: return
        }
    }
    
    enum OnBorder{
        case no, top, bottomRight
    }
    
    func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
        
        let aa = CFConstants.actionArea
        let cAA = CFConstants.cornerActionArea
        
        if (((frame.maxY - aa) < cursorLocation.y && cursorLocation.y < frame.maxY) && (frame.minX < cursorLocation.x && cursorLocation.x < frame.maxX)){
            return .top
        }
        
        if ((frame.minY < cursorLocation.y && cursorLocation.y < frame.minY + cAA) && 
            (frame.maxX - cAA < cursorLocation.x && cursorLocation.x < frame.maxX)){
            return .bottomRight
        }
        return .no
    }
    
    private func repositionView(_ xDiff: Double, _ yDiff: Double) {
        frame.origin.x += xDiff
        frame.origin.y += yDiff
    }
    
    func enaiResize(_ xDiff: Double, _ yDiff: Double){
        let frameSize = frame.size
        var nsize = frameSize
        nsize.height += (yDiff * -1)
        nsize.width += xDiff
        self.setFrameSize(nsize)
        frame.origin.y += yDiff
        
        let wkFrameSize = wkContent!.frame.size
        var newWKFS = wkFrameSize
        newWKFS.height += (yDiff * -1)
        newWKFS.width += xDiff
        wkContent!.setFrameSize(newWKFS)
    }
    
    func toggleActive(){

        frameIsActive = !frameIsActive
    
        if frameIsActive{
            borderColor = .sandLight12
            positionInViewStack = 0
        }else{
            borderColor = .sandLight9
            
        }
    }
    
    func droppedInViewStack(){
        positionInViewStack += 1
    }
    
    func getPositionInViewStack() -> Int{
        return positionInViewStack
    }
}
