//
//  CFFramelessView.swift
//  ni
//
//  Created by Patrick Lukas on 26/5/24.
//

import Cocoa

class CFFramelessView: CFBaseView {
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	}
	
	func setContentView(view: NSView){
		self.contentView = view
	}
	
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		self.contentView = tabView
		return -1
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		let cAA = CFConstants.cornerActionAreaMargin
		
		return .no
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
}
