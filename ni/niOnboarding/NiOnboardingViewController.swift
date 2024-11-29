//
//  NiOnboardingViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import Cocoa
import SwiftUI

protocol OnboardingStep{
	func leftSideInfoView() -> NSView
	func rightSideView() -> NSView
}

class OnboardingStepViews<LeftView: View, RightView: View>: NSObject, OnboardingStep{
	
	private var hostingViewLeft: NSHostingView<LeftView>
	
	init(swiftViewLeft: LeftView) {
		self.hostingViewLeft = NSHostingView(rootView: swiftViewLeft)
	}
	
	func leftSideInfoView() -> NSView {
		return hostingViewLeft
	}
	
	func rightSideView() -> NSView {
		return hostingViewLeft
	}
	
	
}

class NiOnboardingViewController: NSViewController{

	@IBOutlet var leftSideBackgroundFrame: NSView!
	@IBOutlet var leftSideInfoView: NSView!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var fwdButton: NiActionImage!
	
	@IBOutlet var rightSideBackgroundFrame: NSView!
	
	private let viewFrame: NSRect
	
	private let onboardingSteps: [OnboardingStep] = [
		OnboardingStepViews<Step1ViewLeft, Step1ViewLeft>(swiftViewLeft: Step1ViewLeft())
	]
	private var currentStep: Int = 0
	
	init(frame: NSRect) {
		self.viewFrame = frame
		super.init(nibName: NSNib.Name("NiOnboardingView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.frame = viewFrame
		
		styleLeftSide()
		styleRightSide()
		
		setupButtons()
		
		loadOnboardingView(step: 0)
	}
	
	private func styleLeftSide(){
		leftSideBackgroundFrame.wantsLayer = true
		leftSideBackgroundFrame.layer?.backgroundColor = NSColor.sand3.cgColor
	}
	
	private func styleRightSide(){
		rightSideBackgroundFrame.wantsLayer = true
		rightSideBackgroundFrame.layer?.backgroundColor = NSColor.sand1.cgColor
	}
	
	private func setupButtons(){
		fwdButton.isActiveFunction = {return true}
		fwdButton.setMouseDownFunction({ _ in
			
		})
		
		backButton.isActiveFunction = {return true}
		backButton.setMouseDownFunction({ _ in
			
		})
	}
	
	private func loadOnboardingView(step: Int){
		let onboardingViewLeft = onboardingSteps[step].leftSideInfoView()
		onboardingViewLeft.translatesAutoresizingMaskIntoConstraints = false
		leftSideInfoView.addSubview(onboardingViewLeft)
		
		NSLayoutConstraint.activate([
			onboardingViewLeft.topAnchor.constraint(equalTo: leftSideInfoView.topAnchor),
			onboardingViewLeft.trailingAnchor.constraint(equalTo: leftSideInfoView.trailingAnchor),
			onboardingViewLeft.bottomAnchor.constraint(equalTo: leftSideInfoView.bottomAnchor),
			onboardingViewLeft.leadingAnchor.constraint(equalTo: leftSideInfoView.leadingAnchor)
		])
	}
}
