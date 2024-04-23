//Created on 02.10.23

import Cocoa
import Carbon.HIToolbox
import WebKit
import QuartzCore

struct CFConstants {
    static let nibName: String = "ContentFrameView"
    static let x: CGFloat = 30
    static let y: CGFloat = 30
    static let wvWidth: CGFloat = 800
    static let wvHeight: CGFloat = 450
    static let wvBoarderWidth: CGFloat = 10.0
    static let wvBoarderHeight: CGFloat = 10.0
    static let width: CGFloat = wvWidth + wvBoarderWidth * 2
    static let height: CGFloat = wvHeight + wvBoarderHeight * 2
    static let boarderColor = NSColor(.sandLight1)
    static let boarderColorSelected = NSColor(.sandLight3)

    // const needed for resizing:
    static let actionAreaMargin: CGFloat = 6
    static let cornerActionAreaMargin: CGFloat = 32
 }


class ContentFrameView: NSBox{
    
    private var cursorDownPoint: CGPoint  = .zero
    private var cursorOnBorder: OnBorder = .no
    private var deactivateDocumentResize: Bool = false
    private(set) var frameIsActive: Bool = false
    private var positionInViewStack: Int = 0     // 0 = up top
    
    private var niParentDoc: NiSpaceDocumentView? = nil
    
	//Header
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfTabHeadCollection: NSCollectionView!
	@IBOutlet var contentBackButton: NSImageView!
	@IBOutlet var contentForwardButton: NSImageView!
	@IBOutlet var closeButton: NSImageView!
	@IBOutlet var addTabButton: NSImageView!
	
	//TabView
	@IBOutlet var niContentTabView: NSTabView!
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
		self.layer?.cornerCurve = .continuous
    }
    
    func setFrameOwner(_ owner: NiSpaceDocumentView!){
        self.niParentDoc = owner
    }
    
    
    @IBAction func updateContent(_ newURL: ContentFrameHeader) {

        let urlReq = URLRequest(url: URL(string: newURL.stringValue)!)
        
        let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
        activeTabView.load(urlReq)
        
//        contentHeader.stringValue = newURL.stringValue
//        contentHeader.disableEdit()
    }

    
    func createNewTab(tabView: NiWebView) -> Int{

        let tabViewPos = niContentTabView.numberOfTabViewItems
        let tabViewItem = NSTabViewItem()

        tabViewItem.view = tabView

        niContentTabView.addTabViewItem(tabViewItem)
        
        return tabViewPos
    }
    
	func deleteSelectedTab(at position: Int){
		
		niContentTabView.removeTabViewItem(niContentTabView.tabViewItem(at: position))
	}
	
    /**
     * window like functions (moving and resizing) here:
     */
    
	
    /*
     *  MARK: - mouse down events here:
     */
    override func mouseDown(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseDown(with: event)
            return
        }

        super.mouseDown(with: event)
        
        let cursorPos = self.convert(event.locationInWindow, from: nil)
        
        //enable drag and drop niFrame to new postion and resizing
        cursorOnBorder = isOnBoarder(cursorPos)
        if cursorOnBorder != .no{
            cursorDownPoint = event.locationInWindow
        }
        
        let posInHeadView = self.cfHeadView!.convert(cursorPos, from: self)
        
        //clicked on close button
        if NSPointInRect(posInHeadView, closeButton.frame){
			
            removeFromSuperview()
        }
        
        //clicked on back button
        if NSPointInRect(posInHeadView, contentBackButton.frame){
            let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
            activeTabView.goBack()
        }
        
        //clicked on forward button
        if NSPointInRect(posInHeadView, contentForwardButton.frame){
            let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
            activeTabView.goForward()
        }
        
        if NSPointInRect(posInHeadView, addTabButton.frame){
            if let cfc = self.nextResponder as? ContentFrameController{
				_ = cfc.openEmptyTab()
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
        //TODO: look for a cleaner solution,- this is called here so the hand icon switches from closed to open
        resetCursorRects()
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
                resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged)
            case .bottom:
                resizeOwnFrame(0, verticalDistanceDragged)
            case .leftSide:
                resizeOwnFrame(horizontalDistanceDragged, 0, cursorLeftSide: true)
            case .rightSide:
                resizeOwnFrame(horizontalDistanceDragged, 0)
        default: return
        }
    }
    
    override func resetCursorRects() {
        if(frameIsActive){
            if(cursorDownPoint == .zero){
                addCursorRect(getTopBorderActionArea(), cursor: NSCursor.openHand)
            }else{
                addCursorRect(getTopBorderActionArea(), cursor: NSCursor.closedHand)
            }
            addCursorRect(getRightSideBorderActionArea(), cursor: NSCursor.resizeLeftRight)
            addCursorRect(getLeftSideBorderActionArea(), cursor: NSCursor.resizeLeftRight)
            addCursorRect(getBottomBorderActionArea(), cursor: NSCursor.resizeUpDown)
        }
    }
        
    enum OnBorder{
        case no, top, bottomRight, bottom, leftSide, rightSide
    }
    
    func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
        
        let cAA = CFConstants.cornerActionAreaMargin
        
        if (NSPointInRect(cursorLocation, getTopBorderActionArea())){
            return .top
        }
        
        if ((0 < cursorLocation.y && cursorLocation.y < cAA) &&
            (frame.size.width - cAA < cursorLocation.x && cursorLocation.x < frame.size.width)){
            return .bottomRight
        }
        
        if(NSPointInRect(cursorLocation, getBottomBorderActionArea())){
            return .bottom
        }
        if(NSPointInRect(cursorLocation, getLeftSideBorderActionArea())){
            return .leftSide
        }
        if(NSPointInRect(cursorLocation, getRightSideBorderActionArea())){
            return .rightSide
        }
        return .no
    }
    
    private func getTopBorderActionArea() -> NSRect{
        return NSRect(x: 0, y: frame.size.height-CFConstants.actionAreaMargin, width: frame.size.width, height: CFConstants.actionAreaMargin)
    }
    
    private func getBottomBorderActionArea() -> NSRect{
        return NSRect(x:0, y: 0, width: (frame.size.width - CFConstants.cornerActionAreaMargin), height: CFConstants.actionAreaMargin)
    }
    
    private func getLeftSideBorderActionArea() -> NSRect{
        return NSRect(x:0, y:0, width: CFConstants.actionAreaMargin, height: frame.size.height)
    }
    
    private func getRightSideBorderActionArea() -> NSRect{
        return NSRect(x: (frame.size.width - CFConstants.actionAreaMargin), y: CFConstants.cornerActionAreaMargin, width: CFConstants.actionAreaMargin, height: (frame.size.height - CFConstants.cornerActionAreaMargin))
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
        
        if (frame.origin.y - yDiff < 45){	//45px is the hight of the top bar + shadow - FIXME: write cleaner implemetation
            frame.origin.y = 45
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
    
    func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false){
        let frameSize = frame.size
        var nsize = frameSize
        
        if(invertX){
            nsize.width -= xDiff
        }else{
            nsize.width += xDiff
        }
        nsize.height -= yDiff
        
        self.setFrameSize(nsize)
        
        if(invertX){
            self.frame.origin.x += xDiff
        }
    }
    
	/*
	 * MARK: - toggle Active
	 */
    func toggleActive(){

        frameIsActive = !frameIsActive
        let webView = niContentTabView.selectedTabViewItem?.view as! NiWebView
        
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sandLight3).cgColor
            positionInViewStack = 0
            
			showHeader()
            webView.setActive()
//			niContentTabView.selectedTabViewItem?.view?.wantsLayer = false
//			niContentTabView.addSubview(niContentTabView.selectedTabViewItem!.view!)
        }else{
            self.layer?.borderColor = NSColor(.sandLight1).cgColor
  
			hideHeader()
            webView.setInactive()
//			niContentTabView.selectedTabViewItem?.view?.wantsLayer = true

//			niContentTabView.selectedTabViewItem?.view?.removeFromSuperviewWithoutNeedingDisplay()
        }
    }
	
	private func hideHeader(){
		if(1 == niContentTabView.numberOfTabViewItems){
			cfHeadView.isHidden = true
		}
		
//		let currentSize = niContentTabView.frame.size
//		var nsize = currentSize
//		nsize.height += cfHeadView.frame.height
//		niContentTabView.setFrameSize(nsize)
		
//		cfHeadView.removeFromSuperview()
//		NSLayoutConstraint.activate([
//			niContentTabView.topAnchor.constraint(equalTo: self.topAnchor)
//			
//		])
//		niContentTabView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//		layout()
	}
	
	private func showHeader(){
		cfHeadView.isHidden = false

//		let currentSize = niContentTabView.frame.size
//		var nsize = currentSize
//		
//		nsize.height -= cfHeadView.frame.height
//		niContentTabView.setFrameSize(nsize)
		
//		addSubview(cfHeadView)
//		layoutSubtreeIfNeeded()
//		layout()
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
			//FIXME: 
//            CachedWebTable.upsert(documentId: documentId, id: tabView.contentId, title: tabView.title, url: tabView.url!.absoluteString)
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
