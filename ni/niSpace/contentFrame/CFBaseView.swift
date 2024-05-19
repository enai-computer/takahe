//
//  CFBaseView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//
import Cocoa

let minContentFrameExposure: CGFloat = 150

/** Base class shared by all ContentFrame Classes.
	Implements common functionality.
 
	Only inherite this class if your View is controlled by ContentFrameController. Do not use this class directly.
 */
class CFBaseView: NSBox{
	
	var niParentDoc: NiSpaceDocumentView? = nil
	var myController: ContentFrameController? = nil
	
	var frameIsActive: Bool = false
	var deactivateDocumentResize: Bool = false
	var cursorOnBorder: OnBorder = .no
	var cursorDownPoint: CGPoint  = .zero
	
	func setFrameOwner(_ owner: NiSpaceDocumentView!){
		self.niParentDoc = owner
	}
	
	func setSelfController(_ con: ContentFrameController){
		self.myController = con
	}
	
	func isFrameActive() -> Bool{
		return frameIsActive
	}
	
	func activateContentFrame(with event: NSEvent){
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
	}
	
	func repositionView(_ xDiff: Double, _ yDiff: Double) {
		
		let docW = self.niParentDoc!.frame.size.width
		let docHeight = self.niParentDoc!.frame.size.height
		
		//checks for out of bounds
		if(frame.origin.x + xDiff < 0){
			frame.origin.x = 0
		}else if (frame.origin.x + xDiff + minContentFrameExposure < docW){
			frame.origin.x += xDiff
		}else if (xDiff < 0){ //moving to the left getting the Frame out of bounds
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
	
	func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		preconditionFailure("This method must be overridden")
	}
	
	func toggleActive(){
		preconditionFailure("This method must be overridden")
	}
	
	enum OnBorder{
		case no, topLeft, top, topRight, bottomLeft, bottom, bottomRight, leftSide, rightSide
	}
}
