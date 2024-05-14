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
		w = presentingController.view.frame.width - 100
		h = presentingController.view.frame.height - 50
		

		super.init(rootView: HomeView(wrapper, width: w, height: h))
		
		wrapper.hostingController = self
		
		preferredContentSize = NSSize(width: w, height: h)
		sizingOptions = .preferredContentSize
		
		view.frame.size.width = w
		view.frame.size.height = h
		view.frame.origin.x = presentingController.view.frame.origin.x + 50
		
	}
	
	@MainActor required dynamic init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func show(animate: Bool = true) {
		presentingController.present(self, animator: HomeViewAnimator(animate: animate))
		presentingController.homeViewShown = true
	}
	
	func openNewSpace(name: String){
		presentingController.niDocument.myView.isHidden = false
		presentingController.createSpace(name: name)
		presentingController.homeViewShown = false
		presentingController.dismiss(self)
	}
	
	func openExistingSpace(spaceId: UUID, name: String){
		presentingController.niDocument.myView.isHidden = false
		presentingController.loadSpace(niSpaceID: spaceId, name: name)
		presentingController.homeViewShown = false
		presentingController.dismiss(self)
	}

	func tryHide(){
		if(presentingController.spaceLoaded){
			presentingController.niDocument.myView.isHidden = false
			presentingController.homeViewShown = false
			presentingController.dismiss(self)
		}
	}
	

}
