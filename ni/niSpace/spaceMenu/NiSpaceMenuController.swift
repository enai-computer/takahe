//
//  NiSpaceMenuController.swift
//  ni
//
//  Created by Patrick Lukas on 20/5/24.
//

import Cocoa

class NiSpaceMenuController: NSViewController{
	
	var myView: NiSpaceMenuView {return self.view as! NiSpaceMenuView}
	
	private var outOfBoundsMonitor: Any?
	private var parentController: NiSpaceViewController
	
	init(owner: NiSpaceViewController){
		self.parentController = owner
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("Not implemented")
	}
	
	func loadAndPositionView(position: CGPoint, screenWidth: CGFloat, screenHeight: CGFloat) {
		view = (NSView.loadFromNib(nibName: "NiSpaceMenuView", owner: self)!)
		var originX = position.x
		var originY = position.y - view.frame.height
		
		if(screenWidth < originX + view.frame.width){
			originX = originX - view.frame.width
		}
		if(originY < 0){
			originY = position.y
		}
		view.frame.origin = CGPoint(x: originX, y: originY)
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sandLight2.cgColor
		view.layer?.cornerRadius = 10.0
		view.layer?.cornerCurve = .continuous
		
		myView.uploadAnImage.isEnabled = false
		
		myView.openAWindow.mouseDownFunction = openAWindow
		myView.writeANote.mouseDownFunction = createANote
	}
	
	override func viewDidAppear() {
		outOfBoundsMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown, handler: {(event: NSEvent) in
			if(!NSPointInRect(event.locationInWindow, self.view.frame)){
				self.view.removeFromSuperview()
			}
			return event
		})!
	}
	
	override func viewDidDisappear() {
		if(outOfBoundsMonitor != nil){
			NSEvent.removeMonitor(outOfBoundsMonitor!)
		}
		//needs to happen after the event was processed by the whole responder chain
		DispatchQueue.main.async {
			self.parentController.spaceMenu = nil
		}
	}
	
	func openAWindow(with event: NSEvent){
		parentController.openEmptyCF()
	}
	
	func createANote(with event: NSEvent){
		parentController.createANote(positioned: event.locationInWindow)
	}
}
