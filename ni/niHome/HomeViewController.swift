//
//  HomeViewController.swift
//  ni
//
//  Created by Patrick Lukas on 15/4/24.
//

import Cocoa
import SwiftUI

class HomeViewController: NSHostingController<HomeView>{
	private let presentingController: NiSpaceViewController
	
	let w: CGFloat
	let h: CGFloat
	
	init(presentingController: NiSpaceViewController) {
		self.presentingController = presentingController

		let wrapper = ControllerWrapper()
		
		//TODO: fix sizing options
		w = presentingController.view.frame.width - 170
		h = presentingController.view.frame.height - 100
		

		super.init(rootView: HomeView(wrapper, width: w, height: h))
		
		wrapper.hostingController = self
		
		preferredContentSize = NSSize(width: w, height: h)
		sizingOptions = .preferredContentSize
		
		view.frame.size.width = w
		view.frame.size.height = h
		view.frame.origin.x = presentingController.view.frame.origin.x + 85
		
	}
	
	@MainActor required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func show() {
		presentingController.present(self, animator: HomeViewAnimator())
	}
	
	func openNewSpace(name: String){
		
		presentingController.loadSpace()
		presentingController.dismiss(self)
		
//		let appDelegate = NSApp.delegate as! AppDelegate
//		let spaceController = appDelegate.switchToEmptySpace(niSpaceID: UUID(), name: name)
//		spaceController.openEmptyCF()
	}
	
	func openExistingSpace(spaceId: UUID, name: String){
		presentingController.loadSpace(niSpaceID: spaceId, name: name)
		presentingController.dismiss(self)
		
//		let appDelegate = NSApp.delegate as! AppDelegate
//		appDelegate.loadExistingSpace(niSpaceID: spaceId, name: name)
	}

	func tryHide(){
		//TODO: fail in case we are on an empty Space
		presentingController.dismiss(self)
	}
	

}
