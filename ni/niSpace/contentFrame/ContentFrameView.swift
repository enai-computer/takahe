//Created on 02.10.23

import Cocoa
import Carbon.HIToolbox
import WebKit
import QuartzCore

struct CFConstants {
    // const needed for resizing:
    static let actionAreaMargin: CGFloat = 6
    static let cornerActionAreaMargin: CGFloat = 32
 }


class ContentFrameView: NSBox{
    
    private var cursorDownPoint: CGPoint  = .zero
    private var cursorOnBorder: OnBorder = .no
    private var deactivateDocumentResize: Bool = false
    private(set) var frameIsActive: Bool = false

    private var niParentDoc: NiSpaceDocumentView? = nil
	private var myController: ContentFrameController? = nil
    
	//Header
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfTabHeadCollection: NSCollectionView!
	@IBOutlet var contentBackButton: NSImageView!
	@IBOutlet var contentForwardButton: NSImageView!
	@IBOutlet var closeButton: NSImageView!
	@IBOutlet var addTabButton: NSImageView!
	@IBOutlet var cfHeadDragArea: NSView!
	
	//TabView
	@IBOutlet var niContentTabView: NSTabView!
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
		self.layer?.cornerCurve = .continuous
    }
    
    func setFrameOwner(_ owner: NiSpaceDocumentView!){
        self.niParentDoc = owner
    }

	func setSelfController(_ con: ContentFrameController){
		self.myController = con
	}
    
    func createNewTab(tabView: NiWebView) -> Int{

        let tabViewPos = niContentTabView.numberOfTabViewItems
        let tabViewItem = NSTabViewItem()

        tabViewItem.view = tabView

		//FIXME: function below creates issues
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
			niParentDoc?.setTopNiFrame(NSApplication.shared.keyWindow, myController!)
            return
        }
        
        let cursorPos = self.convert(event.locationInWindow, from: nil)
        
        //enable drag and drop niFrame to new postion and resizing
        cursorOnBorder = isOnBoarder(cursorPos)
        if cursorOnBorder != .no{
            cursorDownPoint = event.locationInWindow
        }
        
		if cursorOnBorder == .top{
			NSCursor.closedHand.push()
		}
		
        let posInHeadView = self.cfHeadView!.convert(cursorPos, from: self)
        
        //clicked on close button
        if NSPointInRect(posInHeadView, closeButton.frame){
			niParentDoc?.removeNiFrame(myController!)
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
        
		if cursorOnBorder == .top{
			NSCursor.pop()
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
				addCursorRect(getDragArea(), cursor: NSCursor.openHand)
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
		
		if(NSPointInRect(cursorLocation, getDragArea())){
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
	
	private func getDragArea() -> NSRect{
		return self.convert(cfHeadDragArea.frame, from: cfHeadView)
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
            
            if(!deactivateDocumentResize && yDiff < 0){ //mouse moving downwards, not upwards
                self.niParentDoc!.extendDocumentDownwards()
                deactivateDocumentResize = true     //get's activated again when mouse lifted
			}else{
				frame.origin.y -= yDiff
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
        
		//enforcing min CF size
		if(nsize.height < 150){
			nsize.height = 150
		}
		if(nsize.width < 350){
			nsize.width = 350
		}
		
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
        let webView = niContentTabView.selectedTabViewItem?.view as? NiWebView	//a new content frame will not have a webView yet
        
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sandLight4).cgColor
			self.layer?.backgroundColor = NSColor(.sandLight4).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sandLight4).cgColor
			self.layer?.shadowOpacity = 1.0
            
			showHeader()
            webView?.setActive()
//			niContentTabView.selectedTabViewItem?.view?.wantsLayer = false
//			niContentTabView.addSubview(niContentTabView.selectedTabViewItem!.view!)
        }else{
            self.layer?.borderColor = NSColor(.sandLight3).cgColor
			self.layer?.backgroundColor = NSColor(.sandLight3).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sandLight3).cgColor
			self.layer?.shadowOpacity = 0.0
			
			hideHeader()
            webView?.setInactive()
//			niContentTabView.selectedTabViewItem?.view?.wantsLayer = true

//			niContentTabView.selectedTabViewItem?.view?.removeFromSuperviewWithoutNeedingDisplay()
        }
    }
	
	private func hideHeader(){
		
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

//		let currentSize = niContentTabView.frame.size
//		var nsize = currentSize
//		
//		nsize.height -= cfHeadView.frame.height
//		niContentTabView.setFrameSize(nsize)
		
//		addSubview(cfHeadView)
//		layoutSubtreeIfNeeded()
//		layout()
	}
    
}
