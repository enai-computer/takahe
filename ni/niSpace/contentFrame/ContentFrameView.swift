//Created on 02.10.23

import Cocoa
import WebKit
import QuartzCore

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
    static let boarderColor = NSColor(.sandLight1)
    static let boarderColorSelected = NSColor(.sandLight3)

    // const needed for resizing:
    static let actionArea: CGFloat = 6
    static let cornerActionArea: CGFloat = 32
 }


class ContentFrameView: NSBox{
    
    private var cursorDownPoint: CGPoint  = .zero
    private var cursorOnBorder: OnBorder = .no
    private var deactivateDocumentResize: Bool = false
    private var frameIsActive: Bool = false
    private var positionInViewStack: Int = 0     // 0 = up top
    
    private var niParentDoc: NiSpaceDocument? = nil
    
    @IBOutlet var contentHeader: ContentFrameHeader!
    
    //Buttons
    @IBOutlet var closeButton: NSImageView!
    @IBOutlet var contentBackButton: NSImageView!
    @IBOutlet var contentForwardButton: NSImageView!
    @IBOutlet var addTabButton: NSImageView!
    
    @IBOutlet var niContentTabView: NSTabView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setFrameOwner(_ owner: NiSpaceDocument!){
        self.niParentDoc = owner
    }
    
    
    @IBAction func updateContent(_ newURL: ContentFrameHeader) {

        let urlReq = URLRequest(url: URL(string: newURL.stringValue)!)
        
        let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
        activeTabView.load(urlReq)
        
        contentHeader.stringValue = newURL.stringValue
        contentHeader.disableEdit()
    }

    
    func createNewTab(tabView: WKWebView, label: String, urlStr: String) -> Int{

        let tabViewPos = niContentTabView.numberOfTabViewItems
        let tabViewItem = NSTabViewItem()

        tabViewItem.view = tabView

        tabViewItem.label = "tab " + String(tabViewPos)
        
        niContentTabView.addTabViewItem(tabViewItem)
        
        niContentTabView.selectTabViewItem(at: tabViewPos)
        
        self.contentHeader.stringValue = urlStr
        
        return tabViewPos
    }
    
    /**
     * window like functions (moving and resizing) here:
     */
    
    /*
     * catching mouse down events here:
     */
    override func mouseDown(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseDown(with: event)
        }

        super.mouseDown(with: event)
        
        let cursorPos = self.convert(event.locationInWindow, from: nil)
        
        //enable drag and drop niFrame to new postion and resizing
        cursorOnBorder = isOnBoarder(cursorPos)
        if cursorOnBorder != .no{
            cursorDownPoint = event.locationInWindow
        }
        
        let posInFrame = self.contentView!.convert(cursorPos, from: self)
        
        //clicked on close button
        if NSPointInRect(posInFrame, closeButton.frame){
            removeFromSuperview()
        }
        
        //clicked on back button
        if NSPointInRect(posInFrame, contentBackButton.frame){
            let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
            activeTabView.goBack()
        }
        
        //clicked on forward button
        if NSPointInRect(posInFrame, contentForwardButton.frame){
            let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
            activeTabView.goForward()
        }
        
        if NSPointInRect(posInFrame, addTabButton.frame){
            if let cfc = self.nextResponder as? ContentFrameController{
                cfc.openWebsiteInNewTab("https://www.google.com")
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseUp(with: event)
        }
        
        super.mouseUp(with: event)
        cursorDownPoint = .zero
        cursorOnBorder = .no
        deactivateDocumentResize = false
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
        
        if (((frame.size.height - aa) < cursorLocation.y && cursorLocation.y < frame.size.height) && (0 < cursorLocation.x && cursorLocation.x < frame.size.width)){
            return .top
        }
        
        if ((0 < cursorLocation.y && cursorLocation.y < cAA) &&
            (frame.size.width - cAA < cursorLocation.x && cursorLocation.x < frame.size.width)){
            return .bottomRight
        }
        return .no
    }
    
    private func repositionView(_ xDiff: Double, _ yDiff: Double) {
        
        let docW = self.niParentDoc!.frame.size.width
        let docHeight = self.niParentDoc!.frame.size.height
        
        //checks for out of bounds
        if(frame.origin.x + xDiff < 0){
            frame.origin.x = 0
        }else if (frame.origin.x + xDiff + (frame.width/2.0) < docW){
            frame.origin.x += xDiff
        }
            // do nothing when trying to move to far to the right
        
        if (frame.origin.y - yDiff < 0){
            frame.origin.y = 0
        }else if(frame.origin.y - yDiff + frame.height > docHeight){
            frame.origin.y -= yDiff
            
            if(!deactivateDocumentResize && yDiff < 0){ //mouse moving downwards, not upwards
                self.niParentDoc!.extendDocumentDownwards()
                deactivateDocumentResize = true     //get's activated again when mouse lifted
            }

        }else{
            frame.origin.y -= yDiff
        }
    }
    
    func enaiResize(_ xDiff: Double, _ yDiff: Double){
        let frameSize = frame.size
        var nsize = frameSize
        nsize.height += (yDiff * -1)
        nsize.width += xDiff
        self.setFrameSize(nsize)
    }
    
    func toggleActive(){

        frameIsActive = !frameIsActive
    
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sandLight3).cgColor
            positionInViewStack = 0
            
            contentHeader.isHidden = false
            closeButton.isHidden = false
            contentBackButton.isHidden = false
            contentForwardButton.isHidden = false
            addTabButton.isHidden = false
        }else{
            self.layer?.borderColor = NSColor(.sandLight1).cgColor
            
            contentHeader.isHidden = true
            closeButton.isHidden = true
            contentBackButton.isHidden = true
            contentForwardButton.isHidden = true
            addTabButton.isHidden = true
        }
    }
    
    func droppedInViewStack(){
        positionInViewStack += 1
    }
    
    func getPositionInViewStack() -> Int{
        return positionInViewStack
    }
    
    
    /*
     * MARK: - store and load here
     */
    
    func persistContent(documentId: UUID){
        for tab in niContentTabView.tabViewItems{
            let tabView = tab.view as! NiWebView
            CachedWebTable.upsert(documentId: documentId, id: tabView.contentId, title: tabView.title, url: tabView.url!.absoluteString)
        }
    }
    
    
    func toNiContentFrameModel() -> NiDocumentObjectModel{
        
        var children: [NiCFTabModel] = []
        
        for (i, tab) in niContentTabView.tabViewItems.enumerated(){
            let tabView = tab.view as! NiWebView
            children.append(
                NiCFTabModel(
                    id: tabView.contentId,
                    contentType: NiCFTabContentType.web,
                    active: true,
                    position: i
                )
            )
        }
        
        return NiDocumentObjectModel(
            type: NiDocumentObjectTypes.contentFrame,
            data: NiContentFrameModel(
                state: NiConentFrameState.expanded,
                height: NiCoordinate(px: self.frame.height),
                width: NiCoordinate(px: self.frame.width),
                position: NiViewPosition(
                    posInViewStack: self.positionInViewStack,
                    x: NiCoordinate(px: self.frame.origin.x),
                    y: NiCoordinate(px: self.frame.origin.y)
                ),
                children: children
            )
        )
    }
}
