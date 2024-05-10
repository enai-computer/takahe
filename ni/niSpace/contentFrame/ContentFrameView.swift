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


class ContentFrameView: CFBaseView{
    
//    private(set) var frameIsActive: Bool = false
    
	//Header
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfTabHeadCollection: NSCollectionView!
	@IBOutlet var contentBackButton: NiActionImage!
	@IBOutlet var contentForwardButton: NiActionImage!
	var prevButtonColor: NSColor? = nil
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var addTabButton: NiActionImage!
	@IBOutlet var cfHeadDragArea: NSView!
	@IBOutlet var minimizeButton: NiActionImage!
	@IBOutlet var maximizeButton: NiActionImage!
	
	//TabView
	@IBOutlet var niContentTabView: NSTabView!
	var observation: NSKeyValueObservation?
	
	private var previousCFSize: NSRect? = nil
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
	
	func initAfterViewLoad(){
		closeButton.mouseDownFunction = clickedCloseButton
		closeButton.isActiveFunction = self.isFrameActive
		
		maximizeButton.mouseDownFunction = fillView
		maximizeButton.isActiveFunction = self.isFrameActive
		
		minimizeButton.mouseDownFunction = clickedMinimizeButton
		minimizeButton.isActiveFunction = self.isFrameActive
		
		addTabButton.mouseDownFunction = addTabClicked
		addTabButton.isActiveFunction = self.isFrameActive
		
		contentBackButton.mouseDownFunction = backButtonClicked
		contentBackButton.isActiveFunction = backButtonIsActive
		
		contentForwardButton.mouseDownFunction = forwardButtonClicked
		contentForwardButton.isActiveFunction = fwdButtonIsActive
	}
    
    func createNewTab(tabView: NiWebView) -> Int{

        let tabViewPos = niContentTabView.numberOfTabViewItems
        let tabViewItem = NSTabViewItem()

        tabViewItem.view = tabView

		//FIXME: function below creates issues
		niContentTabView.addTabViewItem(tabViewItem)

		setWebViewObservers(tabView: tabView)
        
        return tabViewPos
    }
    
	private func setWebViewObservers(tabView: NiWebView){
		tabView.addObserver(self, forKeyPath: "canGoBack", options: [.initial, .new], context: nil)
		tabView.addObserver(self, forKeyPath: "canGoForward", options: [.initial, .new], context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return}
		if keyPath == "canGoBack" {
			self.setBackButtonTint(niWebView.canGoBack)
		}else if keyPath == "canGoForward"{
			self.setForwardButtonTint(niWebView.canGoForward)
		}
	}
	
	func deleteSelectedTab(at position: Int){
		niContentTabView.removeTabViewItem(niContentTabView.tabViewItem(at: position))
	}
	
	func updateFwdBackTint(){
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return}
		self.setBackButtonTint(backButtonIsActive())
		self.setForwardButtonTint(fwdButtonIsActive())
	}
	
	func fwdButtonIsActive() -> Bool{
		if(!frameIsActive){
			return false
		}
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return false}
		return niWebView.canGoForward
	}
	
	func backButtonIsActive() -> Bool{
		if(!frameIsActive){
			return false
		}
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return false}
		return niWebView.canGoBack
	}
	
	@MainActor
	private func setBackButtonTint(_ canGoBack: Bool = false){
		if(canGoBack){
			self.contentBackButton.contentTintColor = NSColor(.sandLight11)
		}else{
			self.contentBackButton.contentTintColor = NSColor(.sandLight8)
		}
	}
	
	@MainActor
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.contentForwardButton.contentTintColor = NSColor(.sandLight11)
		}else{
			self.contentForwardButton.contentTintColor = NSColor(.sandLight8)
		}
	}
	
    /**
     * window like functions (moving and resizing) here:
     */
    
	
    /*
     *  MARK: - mouse down events here:
     */
	func clickedCloseButton(with event: NSEvent){
		niParentDoc?.removeNiFrame(myController!)
		removeFromSuperview()
	}
	
	func clickedMinimizeButton(with event: NSEvent){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.minimizeClicked(event)
	}
	
	func addTabClicked(with event: NSEvent){
		if let cfc = self.nextResponder?.nextResponder as? ContentFrameController{
			_ = cfc.openEmptyTab()
		}
	}
	
	func forwardButtonClicked(with event: NSEvent){
		let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
		activeTabView.goForward()
	}
	
	func backButtonClicked(with event: NSEvent){
		let activeTabView = niContentTabView.selectedTabViewItem?.view as! WKWebView
		activeTabView.goBack()
	}
	
    override func mouseDown(with event: NSEvent) {
        if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
            return
        }
        
        let cursorPos = self.convert(event.locationInWindow, from: nil)
        
        //enable drag and drop niFrame to new postion and resizing
        cursorOnBorder = isOnBoarder(cursorPos)
        if cursorOnBorder != .no{
            cursorDownPoint = event.locationInWindow
        }
        
		if cursorOnBorder == .top{
			if(event.clickCount == 2){
				fillOrRetractView(with: event)
				return
			}
			NSCursor.closedHand.push()
		}
		
        let posInHeadView = self.cfHeadView!.convert(cursorPos, from: self)
    }
    
    override func mouseUp(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseUp(with: event)
			return
        }
        
		if cursorOnBorder == .top{
			NSCursor.pop()
		}

        cursorDownPoint = .zero
        cursorOnBorder = .no
        deactivateDocumentResize = false
        //TODO: look for a cleaner solution,- this is called here so the hand icon switches from closed to open
        resetCursorRects()
    }
    
    override func mouseDragged(with event: NSEvent) {
        if !frameIsActive{
            nextResponder?.mouseDragged(with: event)
			return
        }
        
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
			//otherwise hand opens while dragging
            if(cursorDownPoint == .zero){
                addCursorRect(getTopBorderActionArea(), cursor: NSCursor.openHand)
				addCursorRect(getDragArea(), cursor: NSCursor.openHand)
            }
            addCursorRect(getRightSideBorderActionArea(), cursor: NSCursor.resizeLeftRight)
            addCursorRect(getLeftSideBorderActionArea(), cursor: NSCursor.resizeLeftRight)
            addCursorRect(getBottomBorderActionArea(), cursor: NSCursor.resizeUpDown)
        }
    }
    
    override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
        
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
    
	/*
	 * MARK: resize here
	 */
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
		
		previousCFSize = nil
    }
	
	func fillOrRetractView(with event: NSEvent){
		if(previousCFSize == nil){
			fillView(with: event)
			return
		}
		self.frame = previousCFSize!
		previousCFSize = nil
	}
	
	func fillView(with event: NSEvent){
		if(previousCFSize == nil){
			previousCFSize = self.frame
		}
		
		let visibleView = self.niParentDoc!.visibleRect
		let w = visibleView.size.width - 100.0
		let h = visibleView.size.height - 50.0
		
		let x = 50.0	//origin x will always be 0
		let y = visibleView.origin.y + 40		//view is flipped, distance from top
		
		self.setFrameSize(NSSize(width: w, height: h))
		self.setFrameOrigin(NSPoint(x: x, y: y))
	}
    
	/*
	 * MARK: - toggle Active
	 */
    override func toggleActive(){

        frameIsActive = !frameIsActive
        let webView = niContentTabView.selectedTabViewItem?.view as? NiWebView	//a new content frame will not have a webView yet
        
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sandLight4).cgColor
			self.layer?.backgroundColor = NSColor(.sandLight4).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sandLight4).cgColor
			self.layer?.shadowOpacity = 1.0
            
			showHeader()
            webView?.setActive()
			self.resetCursorRects()

        }else{
            self.layer?.borderColor = NSColor(.sandLight3).cgColor
			self.layer?.backgroundColor = NSColor(.sandLight3).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sandLight3).cgColor
			self.layer?.shadowOpacity = 0.0
			
			hideHeader()
            webView?.setInactive()
			self.discardCursorRects()
        }
    }
	
	private func hideHeader(){
		updateFwdBackTint()
		closeButton.tintInactive()
		addTabButton.tintInactive()
		minimizeButton.tintInactive()
		maximizeButton.tintInactive()
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
		updateFwdBackTint()
		closeButton.tintActive()
		addTabButton.tintActive()
		minimizeButton.tintActive()
		maximizeButton.tintActive()
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
