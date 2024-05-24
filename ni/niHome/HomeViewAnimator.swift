//
//  HomeViewAnimator.swift
//  ni
//
//  Created by Patrick Lukas on 22/4/24.
//

import Cocoa

class HomeViewAnimator: NSObject, NSViewControllerPresentationAnimator{
	
	private let animate: Bool
	
	init(animate: Bool = true) {
		self.animate = animate
	}
	
	/*
	 * MARK: animation up & down
	 */
	func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
		viewController.view.wantsLayer = true
		
		viewController.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
		
		viewController.view.alphaValue = 1.0
		viewController.view.frame.origin.y = fromViewController.view.frame.height
		
		fromViewController.view.addSubview(viewController.view)
		
		NSAnimationContext.runAnimationGroup({ context in
			if(animate){
				context.duration = 0.5
			}else{
				context.duration = 0.0
			}
			viewController.view.animator().frame.origin.y = fromViewController.view.frame.origin.y + 50
		})
	}

	
	func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.5
			viewController.view.animator().frame.origin.y = fromViewController.view.frame.height - 35
		}, completionHandler: {
			viewController.view.removeFromSuperview()
		})
	}
}
