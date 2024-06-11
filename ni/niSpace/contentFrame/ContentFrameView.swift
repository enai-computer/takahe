//Created on 02.10.23

import Cocoa
import Carbon.HIToolbox
import WebKit
import QuartzCore


class ContentFrameView: CFBaseView{
        
	//Header
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfTabHeadCollection: NSCollectionView!
	@IBOutlet var tabHeadsScrollContainer: NSScrollView!
	private var latestNrOfTabs: Int? = nil
	@IBOutlet var contentBackButton: NiActionImage!
	@IBOutlet var contentForwardButton: NiActionImage!
	var prevButtonColor: NSColor? = nil
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var addTabButton: NiActionImage!
	@IBOutlet var cfHeadDragArea: NSView!
	@IBOutlet var minimizeButton: NiActionImage!
	@IBOutlet var maximizeButton: NiActionImage!
	@IBOutlet var cfGroupButton: CFGroupButton!
	
	private var cfHeadDragAreaWidthConstraint: NSLayoutConstraint?
	private var niContentTabViewWidthConstraint: NSLayoutConstraint?
	
	//TabView
	@IBOutlet var niContentTabView: NSTabView!
	var observation: NSKeyValueObservation?
	
	static let SPACE_BETWEEN_TABS: CGFloat = 4.0
	static let DEFAULT_TAB_SIZE = NSSize(width: 195, height: 30)
	
	private var previousCFSize: NSRect? = nil
	
	override var minFrameWidth: CGFloat { return 575.0}
	
	private var dropShadow2 = CALayer()
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
	
	func initAfterViewLoad(_ groupName: String?){
		niContentTabView.wantsLayer = true
		niContentTabView.layer?.cornerRadius = 10.0
		niContentTabView.layer?.cornerCurve = .continuous
		
		closeButton.mouseDownFunction = clickedCloseButton
		closeButton.isActiveFunction = self.isFrameActive
		closeButton.mouseDownInActiveFunction = activateContentFrame
		
		maximizeButton.mouseDownFunction = fillOrRetractView
		maximizeButton.isActiveFunction = self.isFrameActive
		maximizeButton.mouseDownInActiveFunction = activateContentFrame
		
		minimizeButton.mouseDownFunction = clickedMinimizeButton
		minimizeButton.isActiveFunction = self.isFrameActive
		minimizeButton.mouseDownInActiveFunction = activateContentFrame
		
		addTabButton.mouseDownFunction = addTabClicked
		addTabButton.isActiveFunction = self.isFrameActive
		addTabButton.mouseDownInActiveFunction = activateContentFrame
		
		contentBackButton.mouseDownFunction = backButtonClicked
		contentBackButton.isActiveFunction = backButtonIsActive
		contentBackButton.mouseDownInActiveFunction = activateContentFrame
		
		contentForwardButton.mouseDownFunction = forwardButtonClicked
		contentForwardButton.isActiveFunction = fwdButtonIsActive
		contentBackButton.mouseDownInActiveFunction = activateContentFrame

		cfGroupButton.initButton(
			mouseDownFunction: clickedGroupButton,
			mouseDownInActiveFunction: activateContentFrame,
			isActiveFunction: self.isFrameActive
		)
		cfGroupButton.setView(title: groupName)
		cfHeadView.layout()
	}
    
	override func layout() {
		super.layout()
		
		if(frameIsActive){
			shadowActive()
		}else{
			shadowInActive()
		}
	}
	
	/** Appends a new tab at the end, or after the given openNextTo position.
	 
	 If the caller sets openNextTo it is their responsability to update the underlying viewModel
	 */
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		let tabViewPos: Int
		let tabViewItem = NSTabViewItem()
		tabViewItem.view = tabView
		
		//check that open nextTo is set and within bounds (e.g. not the last element)
		if(openNextTo < 0 || (myController!.tabs.count - 1) <= openNextTo){
			tabViewPos = niContentTabView.numberOfTabViewItems
			niContentTabView.addTabViewItem(tabViewItem)
		}else{
			tabViewPos = openNextTo + 1
			niContentTabView.insertTabViewItem(tabViewItem, at: tabViewPos)
		}
		
		//TODO: set guard to call only on webViews
		setWebViewObservers(tabView: tabView)
        return tabViewPos
    }
    
	private func setWebViewObservers(tabView: NSView){
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
			self.contentBackButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentBackButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	@MainActor
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.contentForwardButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentForwardButton.contentTintColor = NSColor(.sand8)
		}
	}
	
    /**
     * window like functions (moving and resizing) here:
     */
    
	
    /*
     *  MARK: - mouse down events here:
     */
	func clickedMinimizeButton(with event: NSEvent){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.minimizeClicked(event)
	}
	
	func addTabClicked(with event: NSEvent){
		if let cfc = self.nextResponder as? ContentFrameController{
			cfc.openAndEditEmptyWebTab()
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
			
			if(myController!.aTabIsInEditingMode){
				myController?.endEditingTabUrl()
			}
        }
        
		if cursorOnBorder == .top{
			if(event.clickCount == 2){
				fillOrRetractView(with: event)
				return
			}
			NSCursor.closedHand.push()
		}
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
			case .topLeft:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorLeftSide: true, cursorTop: true)
            case .top:
                repositionView(horizontalDistanceDragged, verticalDistanceDragged)
			case .topRight:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorTop: true)
			case .bottomLeft:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorLeftSide: true)
            case .bottom:
                resizeOwnFrame(0, verticalDistanceDragged)
			case .bottomRight:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged)
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
            addCursorRect(getRightSideBorderActionArea(), cursor: niLeftRightCursor)
            addCursorRect(getLeftSideBorderActionArea(), cursor: niLeftRightCursor)
            addCursorRect(getBottomBorderActionArea(), cursor: niUpDownCursor)
			
			//Corners Top
			addCursorRect(getTopLeftCornerActionAreaVertical(), cursor: niDiagonalCursor)
			addCursorRect(getTopLeftCornerActionAreaHorizontal(), cursor: niDiagonalCursor)
			
			addCursorRect(getTopRightCornerActionAreaVertical(), cursor: niDiagonalFlippedCursor)
			addCursorRect(getTopRightCornerActionAreaHorizontal(), cursor: niDiagonalFlippedCursor)
			
			//Corners Bottom
			addCursorRect(getBottomRightCornerActionAreaVertical(), cursor: niDiagonalCursor)
			addCursorRect(getBottomRightCornerActionAreaHorizontal(), cursor: niDiagonalCursor)
			
			addCursorRect(getBottomLeftCornerActionAreaVertical(), cursor: niDiagonalFlippedCursor)
			addCursorRect(getBottomLeftCornerActionAreaHorizontal(), cursor: niDiagonalFlippedCursor)
        }
    }
    
    override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
        if (NSPointInRect(cursorLocation, getTopBorderActionArea()) || NSPointInRect(cursorLocation, getDragArea())){
            return .top
        }
		return super.isOnBoarder(cursorLocation)
    }
	
    //MARK: drag area calculation here
	private func getDragArea() -> NSRect{
		return self.convert(cfHeadDragArea.frame, from: cfHeadView)
	}
	
	func recalcDragArea(nrOfTabs: Int, specialTabWidth: CGFloat = 0.0){
		var tabHScrollWidth = ( ContentFrameView.SPACE_BETWEEN_TABS + ContentFrameView.DEFAULT_TAB_SIZE.width) * CGFloat(nrOfTabs) + specialTabWidth
		let tabHCollectionWidth = tabHScrollWidth
		let originX = tabHeadsScrollContainer.frame.origin.x + tabHScrollWidth
		
		var dragAreaWidth = maximizeButton.frame.minX - originX
		var diffToMin = 0.0
		if(dragAreaWidth < 30.0){
			diffToMin = 30.0 - dragAreaWidth
			dragAreaWidth = 30.0
		}
		cfHeadDragArea.frame.origin.x = originX - diffToMin
		cfHeadDragArea.frame.size.width = dragAreaWidth
		
		if(cfHeadDragArea.frame.origin.x < (tabHScrollWidth + tabHeadsScrollContainer.frame.origin.x)){
			tabHScrollWidth = cfHeadDragArea.frame.origin.x - tabHeadsScrollContainer.frame.origin.x
		}
		tabHeadsScrollContainer.frame.size.width = tabHScrollWidth
		tabHeadsScrollContainer.documentView?.frame.size.width = tabHCollectionWidth
		latestNrOfTabs = nrOfTabs
		
		if(cfHeadDragAreaWidthConstraint != nil){
			cfHeadDragArea.removeConstraint(cfHeadDragAreaWidthConstraint!)
		}
		if(niContentTabViewWidthConstraint != nil){
			niContentTabView.removeConstraint(niContentTabViewWidthConstraint!)
		}
		setCfHeadDragAreaWidthConstraint(width: dragAreaWidth)
		cfHeadDragArea.addConstraint(cfHeadDragAreaWidthConstraint!)
		
		setNiContentTabViewWidthConstraint(width: tabHScrollWidth)
		niContentTabView.addConstraint(niContentTabViewWidthConstraint!)
	}
	
	private func setNiContentTabViewWidthConstraint(width: CGFloat){
		niContentTabViewWidthConstraint = NSLayoutConstraint(
			item: self.niContentTabView!,
			attribute: .width, relatedBy: .equal,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0,
			constant: width)
	}
	
	private func setCfHeadDragAreaWidthConstraint(width: CGFloat){
		cfHeadDragAreaWidthConstraint = NSLayoutConstraint(
			item: self.cfHeadDragArea!,
			attribute: .width, relatedBy: .equal,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0,
			constant: width
		)
	}
	
	func recalcDragArea(){
		if(latestNrOfTabs != nil){
			recalcDragArea(nrOfTabs: latestNrOfTabs!)
		}
	}
	
	func recalcDragArea(specialTabWidth: CGFloat){
		if(latestNrOfTabs != nil){
			recalcDragArea(nrOfTabs: (latestNrOfTabs! - 1), specialTabWidth: specialTabWidth + 50.0 )
		}
	}
	
	/*
	 * MARK: resize here
	 */
	override func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false){
		super.resizeOwnFrame(xDiff, yDiff, cursorLeftSide: invertX, cursorTop: invertY)
		
		previousCFSize = nil
		recalcDragArea()
    }
	
	func fillOrRetractView(with event: NSEvent){
		if(previousCFSize == nil){
			fillView(with: event)
			return
		}
		self.frame = previousCFSize!
		previousCFSize = nil
		recalcDragArea()
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
		recalcDragArea()
	}
    
	/*
	 * MARK: - toggle Active
	 */
    override func toggleActive(){

        frameIsActive = !frameIsActive
        let webView = niContentTabView.selectedTabViewItem?.view as? CFContentItem	//a new content frame will not have a webView yet
        
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sand4).cgColor
			self.layer?.backgroundColor = NSColor(.sand4).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sand4).cgColor
			shadowActive()
            
			showHeader()
            webView?.setActive()
			self.resetCursorRects()

        }else{
            self.layer?.borderColor = NSColor(.sand3).cgColor
			self.layer?.backgroundColor = NSColor(.sand3).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sand3).cgColor
			shadowInActive()
			
			hideHeader()
            _ = webView?.setInactive()
			self.discardCursorRects()
        }
    }
	
	private func shadowActive(){
		self.dropShadow2 = CALayer(layer: self.layer)
		self.clipsToBounds = true
		
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 10.0, height: -10.0)
		self.layer?.shadowOpacity = 0.7
		self.layer?.shadowRadius = 40
		self.layer?.masksToBounds = false

		self.dropShadow2.shadowColor = NSColor.sand9.cgColor
		self.dropShadow2.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.dropShadow2.shadowOpacity = 0.8
		self.dropShadow2.shadowRadius = 2
		self.dropShadow2.masksToBounds = false

		self.layer?.insertSublayer(self.dropShadow2, at: 0)
	}
	
	private func shadowInActive(){
		self.dropShadow2.removeFromSuperlayer()
		
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 1.0
		self.layer?.shadowRadius = 1.0
		self.layer?.masksToBounds = false
	}
	
	private func hideHeader(){
		updateFwdBackTint()
		closeButton.tintInactive()
		addTabButton.tintInactive()
		minimizeButton.tintInactive()
		maximizeButton.tintInactive()
		cfGroupButton.tintInactive()
	}
	
	private func showHeader(){
		updateFwdBackTint()
		closeButton.tintActive()
		addTabButton.tintActive()
		minimizeButton.tintActive()
		maximizeButton.tintActive()
		cfGroupButton.tintActive()
	}
    
}
