//
//  CFDropdownController.swift
//  ni
//
//  Created by Patrick Lukas on 5/6/24.
//

import Cocoa

class CFDropdownController: NSViewController{
	
	var myView: CFDropdownView? {return view as? CFDropdownView}
	private var outOfBoundsMonitor: Any?
	
	override func loadView() {
		view = (NSView.loadFromNib(nibName: "CFDropdownView", owner: self) as! CFDropdownView)
		
		myView?.nameGroup.mouseDownFunction = nameThisGroup
		myView?.moveToSpace.isEnabled = false
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
		if let monitor = outOfBoundsMonitor{
			NSEvent.removeMonitor(monitor)
		}
	}
	
	func nameThisGroup(with event: NSEvent){
		
	}
}
