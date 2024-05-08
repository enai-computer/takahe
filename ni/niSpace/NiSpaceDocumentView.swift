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
        
	private var allowSubViewResize: Bool = true
	private(set) var topNiFrame: ContentFrameController? = nil
	private(set) var contentFrameControllers: Set<ContentFrameController> = []	//rn all niFrames are drawn. Needs to be reworked in future
	
	
	init(height: CGFloat? = nil){
		var frameSize = NSRect()
		
		let window = NSApplication.shared.keyWindow!
		frameSize.size.width = window.frame.width
		
		if(height == nil){
			frameSize.size.height = window.frame.height * (1+EMPTYSPACEFACTOR)
		}else{
			frameSize.size.height = height!
		}
		
		super.init(frame: frameSize)
	}
	
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        let window = NSApplication.shared.keyWindow
		if(window != nil){
			self.frame.size.height = window!.frame.height * (1+EMPTYSPACEFACTOR)
		}
    }
    
    override var isFlipped: Bool{
        return true
    }
    
    func extendDocumentDownwards(){
		//otherwise we reposition the ContentFrames within the document
		self.allowSubViewResize = false
		
        let window = NSApplication.shared.keyWindow!
        self.frame.size.height += window.frame.height * EMPTYSPACEFACTOR
    }
	
	override func resizeSubviews(withOldSize oldSize: NSSize) {
		if(self.allowSubViewResize){
			super.resizeSubviews(withOldSize: oldSize)
		}
		self.allowSubViewResize = true
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

    func setTopNiFrame( _ newTopFrame: ContentFrameController){
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
		guard let cfView = topNiFrame?.expandedCFView as? ContentFrameView else{return}
		if(!cfView.frameIsActive){
			topNiFrame?.toggleActive()
		}
	}
    
    func persistContent(documentId: UUID){
        for contentFrame in contentFrameControllers{
            contentFrame.persistContent(documentId: documentId)
        }
    }
}
