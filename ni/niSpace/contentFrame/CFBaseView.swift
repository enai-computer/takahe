//
//  CFBaseView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//
import Cocoa

/** Base class shared by all ContentFrame Classes. 
	Implements common functionality.
 
	Only inherite this class if your View is controlled by ContentFrameController. Do not use this class directly.
 */
class CFBaseView: NSBox{
	
	var niParentDoc: NiSpaceDocumentView? = nil
	var myController: ContentFrameController? = nil
	
	var deactivateDocumentResize: Bool = false
	var cursorOnBorder: OnBorder = .no
	var cursorDownPoint: CGPoint  = .zero
	
	func setFrameOwner(_ owner: NiSpaceDocumentView!){
		self.niParentDoc = owner
	}
	
	func setSelfController(_ con: ContentFrameController){
		self.myController = con
	}
	
	func repositionView(_ xDiff: Double, _ yDiff: Double) {
		
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
	
	func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		preconditionFailure("This method must be overridden")
	}
	
	enum OnBorder{
		case no, top, bottomRight, bottom, leftSide, rightSide
	}
}
