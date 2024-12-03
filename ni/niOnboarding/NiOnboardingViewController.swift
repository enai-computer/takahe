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
	
	/**
	 returns true if an animation was displayed. If there are no more animations left to run it will return false.
	 */
	func runFwdTransition() -> Bool
}


protocol ViewAnimationProtocol {
	/**
	 returns true if an animation was displayed. If there are no more animations left to run it will return false.
	 */
	func runFwdTransition() -> Bool
}

class OnboardingStepViews<LeftView: View, RightView: View>: NSObject, OnboardingStep{
	
	private var hostingViewLeft: NSHostingView<LeftView>
	private var hostingViewRight: NSHostingView<RightView>
	private var leftView: LeftView
	private var trigger: Step23RunAnimation?
	
	init(swiftViewLeft: LeftView, swiftViewRight: RightView, trigger: Step23RunAnimation? = nil) {
		self.leftView = swiftViewLeft
		self.hostingViewLeft = NSHostingView(rootView: swiftViewLeft)
		self.hostingViewRight = NSHostingView(rootView: swiftViewRight)
		
		self.trigger = trigger
	}
	
	func leftSideInfoView() -> NSView {
		return hostingViewLeft
	}
	
	func rightSideView() -> NSView {
		return hostingViewRight
	}
	
	func runFwdTransition() -> Bool{
		var ranAnimation = false
//		if let leftView = hostingViewLeft.rootView as? (any View & ViewAnimationProtocol) {
//			ranAnimation = ranAnimation || leftView.runFwdTransition()
//		}
//		if let leftViewAnimationRan = (self.leftView as? (any View & ViewAnimationProtocol))?.runFwdTransition() {
//			ranAnimation = ranAnimation || leftViewAnimationRan
//		}
//		if let rightViewAnimationRan = (hostingViewRight.rootView as? (any View & ViewAnimationProtocol))?.runFwdTransition() {
//			ranAnimation = ranAnimation || rightViewAnimationRan
//		}
		if(self.trigger?.runFwdAnimation == false){
			self.trigger?.runFwdAnimation = true
			return true
		}
		
		return ranAnimation
	}
}

class NiOnboardingViewController: NSViewController{

	@IBOutlet var leftSideBackgroundFrame: NSView!
	@IBOutlet var leftSideInfoView: NSView!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var fwdButton: NiActionImage!
	
	@IBOutlet var rightSideBackgroundFrame: NSView!
	
	private let viewFrame: NSRect
	
	private let step23Trigger = Step23RunAnimation()
	private let onboardingSteps: [OnboardingStep] //= [
//		OnboardingStepViews<Step1ViewLeft, Step1ViewRight>(swiftViewLeft: Step1ViewLeft(), swiftViewRight: Step1ViewRight()),
//		OnboardingStepViews<Step23ViewLeft, Step23ViewRight>(swiftViewLeft: Step23ViewLeft(step23Trigger), swiftViewRight: Step23ViewRight())
//	]

	private var currentStep: Int = 0
	
	init(frame: NSRect) {
		self.viewFrame = frame
		
		onboardingSteps = [
			OnboardingStepViews<Step1ViewLeft, Step1ViewRight>(swiftViewLeft: Step1ViewLeft(), swiftViewRight: Step1ViewRight()),
			OnboardingStepViews<Step23ViewLeft, Step23ViewRight>(swiftViewLeft: Step23ViewLeft(step23Trigger), swiftViewRight: Step23ViewRight(), trigger: step23Trigger)
		]
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
		
		currentStep = 0
		loadOnboardingView(step: currentStep)
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
			self.nextStep()
		})
		
		backButton.isActiveFunction = {return true}
		backButton.setMouseDownFunction({ _ in
			self.prevStep()
		})
	}
	
	//TODO: this works only running forward for now
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
		
		let onboardingViewRight: NSView = onboardingSteps[step].rightSideView()
		onboardingViewRight.translatesAutoresizingMaskIntoConstraints = false
		rightSideBackgroundFrame.addSubview(onboardingViewRight)
		NSLayoutConstraint.activate([
			onboardingViewRight.topAnchor.constraint(equalTo: rightSideBackgroundFrame.topAnchor),
			onboardingViewRight.trailingAnchor.constraint(equalTo: rightSideBackgroundFrame.trailingAnchor),
			onboardingViewRight.bottomAnchor.constraint(equalTo: rightSideBackgroundFrame.bottomAnchor),
			onboardingViewRight.leadingAnchor.constraint(equalTo: rightSideBackgroundFrame.leadingAnchor)
		])
		
	}
	
	private func nextStep(){
		if(onboardingSteps[currentStep].runFwdTransition()){
			return
		}
		
		guard (currentStep + 1) < onboardingSteps.count else {return}
		currentStep += 1
		
		for subView in leftSideInfoView.subviews{
			subView.removeFromSuperview()
		}
		for subView in rightSideBackgroundFrame.subviews{
			subView.removeFromSuperview()
		}
		loadOnboardingView(step: currentStep)
	}
	
	private func prevStep(){
		
		guard 0 <= (currentStep - 1) else {return}
		currentStep -= 1
		
		for subView in leftSideInfoView.subviews{
			subView.removeFromSuperview()
		}
		for subView in rightSideBackgroundFrame.subviews{
			subView.removeFromSuperview()
		}
		loadOnboardingView(step: currentStep)
	}
}
