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
	
	let w: CGFloat
	let h: CGFloat
	
	init(presentingController: NSViewController) {
		self.presentingController = presentingController

		let wrapper = ControllerWrapper()
		
		//TODO: fix sizing options
		w = presentingController.view.frame.width - 100
		h = presentingController.view.frame.height - 100
		
		super.init(rootView: HomeView(wrapper, width: w, height: h))
		
		wrapper.hostingController = self
		
		preferredContentSize = NSSize(width: w, height: h)
		sizingOptions = .preferredContentSize
		
		view.frame.size.width = w
		view.frame.size.height = h
	}
	
	@MainActor required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func show() {
		presentingController.present(
			self,
			asPopoverRelativeTo: NSRect(x: 0, y: 0, width: w, height: h),
			of: presentingController.view,
			preferredEdge: .maxX,
			behavior: .applicationDefined
		)
	}
	
	func openNewSpace(name: String){
		presentingController.dismiss(self)
		
		let appDelegate = NSApp.delegate as! AppDelegate
		appDelegate.switchToNewSpace(niSpaceID: UUID(), name: name)
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
