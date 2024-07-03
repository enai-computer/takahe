//
//  NiPdfView.swift
//  ni
//
//  Created by Patrick Lukas on 2/7/24.
//

import Cocoa
import PDFKit

class NiPdfView: PDFView, CFContentItem{
	var owner: ContentFrameController?
	
	// overlays own view to deactivate clicks and visualise deactivation state
	private var overlay: NSView?
	private var zoomLevel: Int = 7
	
	var viewIsActive: Bool = true
	
	init(owner: ContentFrameController, frame: NSRect, document doc: PDFDocument) {
		self.owner = owner
		super.init(frame: frame)
		
		self.document = doc
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		viewIsActive = true
	}
	
	@discardableResult
	func setInactive() -> FollowOnAction {
		overlay = cfOverlay(frame: self.frame, nxtResponder: owner!.view)
		addSubview(overlay!)
		window?.makeFirstResponder(overlay)
		viewIsActive = false
		return .nothing
	}
	
	func spaceClosed() {
		
	}
	
	func spaceRemovedFromMemory() {
		
	}
	
	
}
