//
//  HomeViewController.swift
//  ni
//
//  Created by Patrick Lukas on 15/4/24.
//

import Cocoa
import SwiftUI

class HomeViewController: NSHostingController<HomeView>{
	
	private let presentingController: NSViewController
	
	init(presentingController: NSViewController) {
		self.presentingController = presentingController

		let wrapper = ControllerWrapper()
		
		super.init(rootView: HomeView(wrapper))
		
		wrapper.hostingController = self
		
		//TODO: fix sizing options
		let w = presentingController.view.frame.width
		let h = presentingController.view.frame.height
		
		preferredContentSize = NSSize(width: w, height: h)
		sizingOptions = .preferredContentSize
		view.frame.size.width = w
		view.frame.size.height = h
	}
	
	@MainActor required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func show() {
		presentingController.present(self, asPopoverRelativeTo: NSRect(x: 0, y: 0, width: 0, height: 0), of: presentingController.view, preferredEdge: .maxX, behavior: .applicationDefined)
	}
	
	func openNewSpace(){
		presentingController.dismiss(self)
		
		let appDelegate = NSApp.delegate as! AppDelegate
		appDelegate.switchToNewSpace()
	}
	
	func openExistingSpace(spaceId: UUID, name: String){
		presentingController.dismiss(self)
		
		let appDelegate = NSApp.delegate as! AppDelegate
		appDelegate.loadExistingSpace(niSpaceID: spaceId, name: name)
	}

	func tryHide(){
		//TODO: fail in case we are on HomeViewBackground
		presentingController.dismiss(self)
	}
}
