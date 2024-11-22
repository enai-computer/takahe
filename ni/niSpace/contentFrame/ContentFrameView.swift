//Created on 02.10.23

import Cocoa
import Carbon.HIToolbox
import WebKit
import QuartzCore


class ContentFrameView: CFBaseView, CFTabHeadProtocol, CFFwdBackButtonProtocol, CFHasGroupButtonProtocol, CFHeadActionImageDelegate{
        
	//Header
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfTabHeadCollection: NSCollectionView?
	@IBOutlet var tabHeadsScrollContainer: NSScrollView!
	@IBOutlet var contentBackButton: CFHeadActionImage!
	@IBOutlet var contentForwardButton: CFHeadActionImage!

	@IBOutlet var closeButton: CFHeadActionImage!
	@IBOutlet var addTabButton: CFHeadActionImage!
	@IBOutlet var cfHeadDragArea: NSView!
	@IBOutlet var minimizeButton: CFHeadActionImage!
	@IBOutlet var maximizeButton: CFHeadActionImage!
	@IBOutlet var cfGroupButton: CFGroupButton!
	
	private var cfHeadDragAreaWidthConstraint: NSLayoutConstraint?
	private var niContentTabViewWidthConstraint: NSLayoutConstraint?
	private var groupButtonLeftConstraint: NSLayoutConstraint?
	private var mouseHoldcfHeadTimer: Timer?
	
	//Tabbed ContentView
	@IBOutlet var niContentTabView: NSTabView!
	
	static let SPACE_BETWEEN_TABS: CGFloat = 4.0
	static let TAB_HEAD_HEIGHT = 28.0
	static let DEFAULT_TAB_SIZE = NSSize(width: 195, height: TAB_HEAD_HEIGHT)
	static let MAX_TAB_WIDTH: CGFloat = 300.0
	
	override var minFrameWidth: CGFloat { return 575.0}
	override var frameType: NiContentFrameState {return .expanded}
	
	private var dropShadow2 = CALayer()
	private var dropShadow3 = CALayer()
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
	
	func initAfterViewLoad(_ groupName: String?){
		niContentTabView.wantsLayer = true
		niContentTabView.layer?.cornerRadius = 10.0
		niContentTabView.layer?.cornerCurve = .continuous
		
		cfGroupButton.initButton(
			mouseDownFunction: clickedGroupButton,
			mouseDownInActiveFunction: activateContentFrame,
			isActiveFunction: self.isFrameActive,
			titleChangedCallback: myController?.updateGroupName,
			displayType: .expanded
		)
		cfGroupButton.setView(title: groupName)
		
		updateGroupButtonLeftConstraint()
		
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
	    return tabViewPos
    }
    
	func deleteSelectedTab(at position: Int){
		guard 0 <= position && position < niContentTabView.tabViewItems.count else {return}
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
	func setBackButtonTint(_ canGoBack: Bool = false, trigger: NSView){
		guard trigger == niContentTabView.selectedTabViewItem?.view else {return}
		setBackButtonTint(canGoBack)
	}
	
	@MainActor
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.contentForwardButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentForwardButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	@MainActor
	func setForwardButtonTint(_ canGoFwd: Bool = false, trigger: NSView){
		guard trigger == niContentTabView.selectedTabViewItem?.view else {return}
		setForwardButtonTint(canGoFwd)
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
			let interval = TimeInterval(floatLiteral: 0.7)
			mouseHoldcfHeadTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false){_ in
				NSCursor.closedHand.push()
			}
		}
    }
    
    override func mouseUp(with event: NSEvent) {
		mouseHoldcfHeadTimer?.invalidate()
		mouseHoldcfHeadTimer = nil
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
    
	func mouseUp(with event: NSEvent, for type: CFHeadButtonType) {
		switch(type){
			case .back:
				backButtonClicked(with: event)
				return
			case .fwd:
				forwardButtonClicked(with: event)
				return
			case .add:
				addTabClicked(with: event)
				return
			case .expand:
				clickedMakeFullscreen(with: event)
				return
			case .minimize:
				clickedMinimizeButton(with: event)
				return
			case .close:
				clickedCloseButton(with: event)
				return
			default:
				assertionFailure("button type not implemented")
				return
		}
	}
	
	func isButtonActive(_ type: CFHeadButtonType) -> Bool{
		if(type == .back){
			return backButtonIsActive()
		}
		if(type == .fwd){
			return fwdButtonIsActive()
		}
		return super.isFrameActive()
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
		if (NSPointInRect(cursorLocation, getTopBorderActionArea()) || NSPointInRect(cursorLocation, cfHeadView.frame)){
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
		
		if(cfHeadDragAreaWidthConstraint != nil){
			cfHeadDragArea.removeConstraint(cfHeadDragAreaWidthConstraint!)
		}

		setCfHeadDragAreaWidthConstraint(width: dragAreaWidth)
		cfHeadDragArea.addConstraint(cfHeadDragAreaWidthConstraint!)
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
	
	/** .
	 
	 layout() has to be called on cfHeadView after calling this function
	 */
	func updateGroupButtonLeftConstraint(){
		if(groupButtonLeftConstraint != nil){
			cfHeadView.removeConstraint(groupButtonLeftConstraint!)
		}
		groupButtonLeftConstraint = getLeftCfGroupButtonConstraint(showsTitle: cfGroupButton.hasTitle())
		cfHeadView.addConstraint(groupButtonLeftConstraint!)
	}
	
	private func getLeftCfGroupButtonConstraint(showsTitle: Bool = false) -> NSLayoutConstraint{
		let constant: CGFloat = if(showsTitle){
			0.0
		}else{
			7.0
		}
		return NSLayoutConstraint(
			item: self.cfGroupButton!,
			attribute: .left,
			relatedBy: .equal,
			toItem: self.cfHeadView!,
			attribute: .left,
			multiplier: 1.0,
			constant: constant
		)
	}
	
	func recalcDragArea(){
		//needs to be recalculated a frame later, otherwise we end up with wrong sizes on resize:
		DispatchQueue.main.async {
			if let nrOfTabs = self.myController?.tabs.count{
				self.recalcDragArea(nrOfTabs: nrOfTabs)
			}
		}
	}
	
	func recalcDragArea(specialTabWidth: CGFloat){
		if let nrOfTabs = self.myController?.tabs.count{
			recalcDragArea(nrOfTabs: (nrOfTabs - 1), specialTabWidth: specialTabWidth + 50.0 )
		}
	}
	
	/*
	 * MARK: resize here
	 */
	override func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false){
		super.resizeOwnFrame(xDiff, yDiff, cursorLeftSide: invertX, cursorTop: invertY)
		recalcDragArea()
    }
	
	override func fillOrRetractView(with event: NSEvent){
		super.fillOrRetractView(with: event)
		recalcDragArea()
	}
    
	func clickedMakeFullscreen(with event: NSEvent){
		myController?.makeFullscreenClicked(event)
	}
	
	/*
	 * MARK: - toggle Active
	 */
    override func toggleActive(){

        frameIsActive = !frameIsActive
        let webView = niContentTabView.selectedTabViewItem?.view as? CFContentItem	//a new content frame will not have a webView yet
        
        if frameIsActive{
            self.layer?.borderColor = NSColor(.sand5).cgColor
			self.layer?.backgroundColor = NSColor(.sand5).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sand5).cgColor
			fillColor = .sand5
			shadowActive()
            
			showHeader()
            webView?.setActive()
			self.resetCursorRects()

        }else{
            self.layer?.borderColor = NSColor(.sand3).cgColor
			self.layer?.backgroundColor = NSColor(.sand3).cgColor
			cfHeadView.layer?.backgroundColor = NSColor(.sand3).cgColor
			fillColor = .sand3
			shadowInActive()
			
			hideHeader()
            _ = webView?.setInactive()
			self.discardCursorRects()
        }
    }
	
	private func shadowActive(){
		
		self.clipsToBounds = false
		
		self.layer?.shadowColor = NSColor.sand115.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: -1.0)
		self.layer?.shadowOpacity = 0.33
		self.layer?.shadowRadius = 3.0
		self.layer?.masksToBounds = false

		self.dropShadow2.removeFromSuperlayer()
		
		self.dropShadow2 = CALayer(layer: self.layer!)
		self.dropShadow2.shadowPath = NSBezierPath(rect: bounds).cgPath
		self.dropShadow2.shadowColor = NSColor.sand115.cgColor
		self.dropShadow2.shadowOffset = CGSize(width: 2.0, height: -4.0)
		self.dropShadow2.shadowOpacity = 0.2
		self.dropShadow2.shadowRadius = 6.0
		self.dropShadow2.masksToBounds = false

		self.layer?.insertSublayer(self.dropShadow2, at: 0)
		
		self.dropShadow3.removeFromSuperlayer()
		
		self.dropShadow3 = CALayer(layer: self.layer!)
		self.dropShadow3.shadowPath = NSBezierPath(rect: bounds).cgPath
		self.dropShadow3.shadowColor = NSColor.sand115.cgColor
		self.dropShadow3.shadowOffset = CGSize(width: 4.0, height: -8.0)
		self.dropShadow3.shadowOpacity = 0.2
		self.dropShadow3.shadowRadius = 20.0
		self.dropShadow3.masksToBounds = false

		dropShadow2.insertSublayer(self.dropShadow3, at: 0)
	}
	
	private func shadowInActive(){
		self.dropShadow2.removeFromSuperlayer()
		self.dropShadow3.removeFromSuperlayer()
		
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 0.5
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
    
	override func deinitSelf(keepContentView: Bool = false){
		if(keepContentView){
			assertionFailure("option not implemented")
			return
		}
		cfGroupButton.deinitSelf()
		
		for t in niContentTabView.tabViewItems{
			if let niContentView = t.view as? CFContentItem{
				niContentView.spaceRemovedFromMemory()
			}
			niContentTabView.removeTabViewItem(t)
		}
		niContentTabView.tabViewItems = []
		niContentTabView.removeFromSuperviewWithoutNeedingDisplay()
		tabHeadsScrollContainer.removeFromSuperviewWithoutNeedingDisplay()
		
		cfTabHeadCollection?.dataSource = nil
		cfTabHeadCollection?.delegate = nil
		cfTabHeadCollection?.removeFromSuperviewWithoutNeedingDisplay()
		
		super.deinitSelf()
	}
	
	deinit{
		self.dropShadow3.removeFromSuperlayer()
		self.dropShadow2.removeFromSuperlayer()
	}
	
}
