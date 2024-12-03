//
//  NiScrollController.swift
//  ni
//
//  Created by Patrick Lukas on 10/28/23.
//

import Cocoa
import Foundation

let EMPTYSPACEFACTOR: Double = 1

class NiSpaceDocumentView: NSView{

	private let DEFAULT_WINDOW_HEIGHT: CGFloat = 1400.0
	
	private(set) var topNiFrame: ContentFrameController? = nil
	private var nxtTopZPosition: CGFloat = 0.0
	private(set) var contentFrameControllers: Set<ContentFrameController> = []	//rn all niFrames are drawn. Needs to be reworked in future
	
	init(with size: CGSize){
		let frameSize = NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
		super.init(frame: frameSize)
	}
	
	convenience init(windowSize: CGSize){
		var docSize = CGSize()
		
		docSize.width = windowSize.width
		docSize.height = windowSize.height * (1+EMPTYSPACEFACTOR)

		self.init(with: docSize)
	}
	
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        let window = NSApplication.shared.mainWindow
		if(window != nil){
			self.frame.size.height = window!.frame.height * (1+EMPTYSPACEFACTOR)
		}
    }
    
    override var isFlipped: Bool{
        return true
    }
    
    func extendDocumentDownwards(){
		let windowHeight: CGFloat = NSApplication.shared.mainWindow?.frame.height ?? DEFAULT_WINDOW_HEIGHT
        self.frame.size.height += windowHeight * EMPTYSPACEFACTOR
    }
	
	override func resizeSubviews(withOldSize oldSize: NSSize) {
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		topNiFrame?.toggleActive()
		if let zPos = topNiFrame?.view.layer?.zPosition{
			nxtTopZPosition = zPos
		}
		topNiFrame = nil
		
		super.mouseDown(with: event)
	}
	
    /*
     * MARK: Window like functions for niFrames below:
     *
     * TODO: fix activation and deactivation 
     */
    
    
    func addNiFrame(_ subViewController: CFProtocol){
		self.addSubview(subViewController.view)
		setTopNiFrame(subViewController)
		contentFrameControllers.insert(subViewController)
    }
	
	func removeNiFrame(_ subViewController: ContentFrameController){
		contentFrameControllers.remove(subViewController)
		if(topNiFrame == subViewController){
			if let zPos = topNiFrame?.view.layer?.zPosition{
				nxtTopZPosition = zPos
			}
			topNiFrame = nil
		}
	}

	/**
		Makes sure your the CFControllers view is on top
	 
		Only call this function after you updated the controllers view!
	 */
    func setTopNiFrame( _ newTopFrame: CFProtocol){
		//wierd combinations make it possible that the new top frame is not marked as active, in this case we shall activate it, but not mess with the zPosition as otherwise we'll end up with deactivated CFs on top
		if(newTopFrame == topNiFrame && !newTopFrame.myView.frameIsActive){
			newTopFrame.toggleActive()
			return
		}
		let zPosOldTopNiFrame = topNiFrame?.view.layer?.zPosition ?? nxtTopZPosition
        topNiFrame?.toggleActive()
        
        //switch
		newTopFrame.view.removeFromSuperview()
		self.addSubview(newTopFrame.view)
		
		//TODO: fix at some point. May cause stack-overflow
		//on document reload zPostions are regiven, so we renumber them from 0 upwards
		newTopFrame.view.layer?.zPosition = zPosOldTopNiFrame + 1

        topNiFrame = newTopFrame
		
		//in case the frame was already active before this function call, we do not want to deactivate it
		guard let cfBaseView = topNiFrame?.myView as? CFBaseView else{return}
		if(!cfBaseView.frameIsActive){
			topNiFrame?.toggleActive()
		}
	}
    
    func persistContent(spaceId: UUID){
        for contentFrame in contentFrameControllers{
            contentFrame.persistContent(spaceId: spaceId)
        }
    }
	
	func switchToNextTab() {
		topNiFrame?.selectNextTab()
	}
	
	func switchToPrevTab() {
		topNiFrame?.selectNextTab(goFwd: false)
	}
	
	func createNewTab(){
		topNiFrame?.openAndEditEmptyWebTab()
	}
	
	func toggleEditMode(){
		topNiFrame?.toggleEditSelectedTab()
	}
	
	func toggleMinimizeOnTopCF(_ sender: NSMenuItem){
		if(topNiFrame?.viewState.isMinimized() == true){
			topNiFrame?.maximizeSelf()
		}else{
			topNiFrame?.minimizeSelf()
		}
	}
	
	func switchToNextCF(goFwd: Bool = true){
		let (currentPos, orderedCFs) = cfOrdered()
		
		if(orderedCFs.isEmpty){
			return
		}
		
		var nxtContentFrame: Int =  if(goFwd){
			currentPos + 1
		}else{
			currentPos - 1
		}
				
		// cycles to first and last Window...
		if(nxtContentFrame < 0){
			nxtContentFrame = orderedCFs.count - 1
		}
		
		if((orderedCFs.count - 1) < nxtContentFrame){
			nxtContentFrame = 0
		}
		
		if(nxtContentFrame < 0){
			return
		}
		
		highlightContentFrame(cframe: orderedCFs[nxtContentFrame])
	}
	
	func highlightContentFrame(with id: UUID){
		var contentFrameToHighlight: ContentFrameController?
		for cFrame in contentFrameControllers{
			if(cFrame.groupId == id){
				highlightContentFrame(cframe: cFrame)
				if(cFrame.viewState == .fullscreen){
					return
				}
				contentFrameToHighlight = cFrame
			}
			if(cFrame.viewState == .fullscreen){
				cFrame.fullscreenToExpanded()
				//Called to make sure it's on top
				if let cfToHighlight = contentFrameToHighlight{
					highlightContentFrame(cframe: cfToHighlight)
				}
			}
		}
	}
	
	func highlightContentObj(contentId: UUID){
		var contentFrameToHighlight: ContentFrameController?
		
		//in old instances we have ghost objects, that do not exist anymore. This way we catch them and remove from result set
		var foundContentId: Bool = false
		
		for cFrame in contentFrameControllers{
			for tab in cFrame.tabs {
				if(tab.contentId == contentId){
					foundContentId = true
					
					//first we need to expand and then we call highlight, as otherwise the canvas will jump to the minimized position and not expanded position
					if(cFrame.viewState.isMinimized()){
						cFrame.minimizedToExpanded()
					}
					
					highlightContentFrame(cframe: cFrame)
					DispatchQueue.main.async{
						cFrame.selectTab(at: tab.position)
					}
					
					contentFrameToHighlight = cFrame
					
					//exit here, as the wished item is in fullscreen on top
					if(cFrame.viewState == .fullscreen){
						return
					}
				}
			}
			
			//if there is another contentframe that is in full screen we downsize it to expand so it does not cover the search result
			if(cFrame.viewState == .fullscreen){
				cFrame.fullscreenToExpanded()
				//Called to make sure it's on top
				if let cfToHighlight = contentFrameToHighlight{
					highlightContentFrame(cframe: cfToHighlight)
				}
			}
		}
		
		if(!foundContentId){
			ContentTable.delete(id: contentId)
		}
	}
	
	func highlightContentFrame(cframe: ContentFrameController){
		setTopNiFrame(cframe)
		let maxXY = NSPoint(x: cframe.view.frame.maxX, y: cframe.view.frame.maxY)
		if(!NSPointInRect(cframe.view.frame.origin, visibleRect) || !NSPointInRect(maxXY, visibleRect)){
			scrollIntoView(for: cframe.view.frame.origin)
		}
	}
	
	private func scrollIntoView(for point: CGPoint){
		var scrollToPoint = point
		if(50.0 < point.y){
			scrollToPoint.y = scrollToPoint.y - 40.0
		}else{
			scrollToPoint.y = 0
		}
		scroll(scrollToPoint)
	}
	
	private func cfOrdered() -> (Int, [ContentFrameController]){
		let orderedCFs = orderedContentFrames()
		let currentPos: Int = if let topNiFrame {
			orderedCFs.firstIndex(of: topNiFrame) ?? -1
		} else{
			-1
		}
		return (currentPos, orderedCFs)
	}

	/// Returns ``ContentFrameController``s in `self`, ordered by the Y position from top to bottom.
	func orderedContentFrames() -> [ContentFrameController] {
		return contentFrameControllers
			.sorted { $0.view.frame.origin.y <= $1.view.frame.origin.y }
	}

	func deinitSelf(){
		for conFrame in contentFrameControllers{
			conFrame.deinitSelf()
		}
		contentFrameControllers = []
		topNiFrame = nil
	}
	
}
