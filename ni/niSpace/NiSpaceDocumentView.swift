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
	
    /*
     * MARK: Window like functions for niFrames below:
     *
     * TODO: fix activation and deactivation 
     */
    
    
    func addNiFrame(_ subViewController: ContentFrameController){
		self.addSubview(subViewController.view)
		setTopNiFrame(subViewController)
		contentFrameControllers.insert(subViewController)
    }
	
	func removeNiFrame(_ subViewController: ContentFrameController){
		contentFrameControllers.remove(subViewController)
	}

	/**
		Makes sure your the CFControllers view is on top
	 
		Only call this function after you updated the controllers view!
	 */
    func setTopNiFrame( _ newTopFrame: ContentFrameController){
		//wierd combinations make it possible that the new top frame is not marked as active, in this case we shall activate it, but not mess with the zPosition as otherwise we'll end up with deactivated CFs on top
		if(newTopFrame == topNiFrame && !newTopFrame.myView.frameIsActive){
			newTopFrame.toggleActive()
			return
		}
		let zPosOldTopNiFrame = topNiFrame?.view.layer?.zPosition
        topNiFrame?.toggleActive()
        
        //switch
		newTopFrame.view.removeFromSuperview()
		self.addSubview(newTopFrame.view)
		if zPosOldTopNiFrame != nil {
			//TODO: fix at some point. May cause stack-overflow
			//on document reload zPostions are regiven, so we renumber them from 0 upwards
			newTopFrame.view.layer?.zPosition = zPosOldTopNiFrame! + 1
		}else{
			newTopFrame.view.layer?.zPosition = 0
		}
        topNiFrame = newTopFrame
		
		//in case the frame was already active before this function call, we do not want to deactivate it
		guard let cfBaseView = topNiFrame?.myView as? CFBaseView else{return}
		if(!cfBaseView.frameIsActive){
			topNiFrame?.toggleActive()
		}
	}
    
    func persistContent(documentId: UUID){
        for contentFrame in contentFrameControllers{
            contentFrame.persistContent(documentId: documentId)
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
		if(topNiFrame?.viewState == .minimised || topNiFrame?.viewState == .simpleMinimised){
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
		
		setTopNiFrame(orderedCFs[nxtContentFrame])
		
		if(!NSPointInRect(topNiFrame!.view.frame.origin, visibleRect)){
			var scrollToPoint = topNiFrame!.view.frame.origin
			if(50.0 < scrollToPoint.y){
				scrollToPoint.y = scrollToPoint.y - 40.0
			}else{
				scrollToPoint.y = 0
			}
			scroll(scrollToPoint)
		}
	}
	
	private func cfOrdered() -> (Int, [ContentFrameController]){
		let orderedCFs = contentFrameControllers.sorted {
			return $0.view.frame.origin.y <= $1.view.frame.origin.y
		}
		let currentPos: Int = if(topNiFrame != nil){
			orderedCFs.firstIndex(of: topNiFrame!) ?? -1
		} else{
			-1
		}
		return (currentPos, orderedCFs)
	}
	
	func deinitSelf(){
		for conFrame in contentFrameControllers{
			conFrame.deinitSelf()
		}
		contentFrameControllers = []
		topNiFrame = nil
	}
	
}
