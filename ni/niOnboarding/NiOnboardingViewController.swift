//
//  NiOnboardingViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import Cocoa
import SwiftUI
import Carbon.HIToolbox
import PostHog

protocol OnboardingStep{
	func leftSideInfoView() -> NSView
	func rightSideView() -> NSView
	
	/**
	 returns true if an animation was displayed. If there are no more animations left to run it will return false.
	 */
	func runFwdTransition() -> Bool
	func runBackTransition() -> Bool
}


@Observable
final class StepRunsAnimation{
	var runFwdAnimation: Bool = false
}


class OnboardingStepViews<LeftView: View, RightView: View>: NSObject, OnboardingStep{
	
	private var hostingViewLeft: NSHostingView<LeftView>
	private var hostingViewRight: NSHostingView<RightView>
	private var leftView: LeftView
	private var trigger: StepRunsAnimation?
	
	init(left: LeftView, right: RightView, trigger: StepRunsAnimation? = nil) {
		self.leftView = left
		self.hostingViewLeft = NSHostingView(rootView: left)
		self.hostingViewRight = NSHostingView(rootView: right)
		
		self.trigger = trigger
	}
	
	func leftSideInfoView() -> NSView {
		return hostingViewLeft
	}
	
	func rightSideView() -> NSView {
		return hostingViewRight
	}
	
	func runFwdTransition() -> Bool{
		if(self.trigger?.runFwdAnimation == false){
			self.trigger?.runFwdAnimation = true
			return true
		}
		
		return false
	}
	
	func runBackTransition() -> Bool{
		if(self.trigger?.runFwdAnimation == true){
			self.trigger?.runFwdAnimation = false
			return true
		}
		
		return false
	}
}

class NiOnboardingViewController: NSViewController{

	@IBOutlet var leftSideBackgroundFrame: NSView!
	@IBOutlet var leftSideInfoView: NSView!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var fwdButton: NiActionImage!
	@IBOutlet var progressDotStack: NSStackView!
	
	@IBOutlet var rightSideBackgroundFrame: NSView!
	
	private let viewFrame: NSRect
	
	private let step23Trigger = StepRunsAnimation()
	private let onboardingSteps: [OnboardingStep]
	private var currentStep: Int = 0
	private let animationDurationBetweenSlides_ms: Int = 400
	
	private var onboardingStarted: Date?
	private var movedToSlideAt: Date?
	
	init(frame: NSRect) {
		self.viewFrame = frame
		
		onboardingSteps = [
			OnboardingStepViews<Step1ViewLeft, Step1ViewRight>(left: Step1ViewLeft(), right: Step1ViewRight()),
			OnboardingStepViews<Step23ViewLeft, Step23ViewRight>(left: Step23ViewLeft(step23Trigger), right: Step23ViewRight(step23Trigger), trigger: step23Trigger),
			OnboardingStepViews<Step3ViewLeft, Step3ViewRight>(left: Step3ViewLeft(), right: Step3ViewRight()),
			OnboardingStepViews<Step4ViewLeft, Step4ViewRight>(left: Step4ViewLeft(), right: Step4ViewRight()),
			OnboardingStepViews<Step5ViewLeft, Step5ViewRight>(left: Step5ViewLeft(), right: Step5ViewRight())
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
		
		setupProgressDots()
		loadOnboardingView(step: currentStep)
		
		onboardingStarted = Date()
		movedToSlideAt = Date()
		PostHogSDK.shared.capture("onboarding_started")
	}
	
	private func styleLeftSide(){
		leftSideBackgroundFrame.wantsLayer = true
		leftSideBackgroundFrame.layer?.backgroundColor = NSColor.sand3.cgColor
	}
	
	private func styleRightSide(){
		rightSideBackgroundFrame.wantsLayer = true
		rightSideBackgroundFrame.layer?.backgroundColor = NSColor.sand2.cgColor
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
	
	private func setupProgressDots(){
		guard let dotImg = NSImage(named: "progressDot") else {return}
		dotImg.size = CGSize(width: 10.0, height: 10.0)
		var dots: [NSImageView] = []
		for _ in onboardingSteps.indices{
			let dot = NSImageView(image: dotImg)
			dot.frame.size = CGSize(width: 10.0, height: 10.0)
			dots.append(dot)
		}

		progressDotStack.setViews(dots, in: .center)
		progressDotStack.spacing = 5.0
		updateDots()
	}
	
	private func loadOnboardingView(step: Int) -> (){
		let onboardingViewLeft = onboardingSteps[step].leftSideInfoView()
		onboardingViewLeft.translatesAutoresizingMaskIntoConstraints = false
		
		onboardingViewLeft.wantsLayer = true
		onboardingViewLeft.layer?.opacity = 0.0
		
		leftSideInfoView.addSubview(onboardingViewLeft)
		NSLayoutConstraint.activate([
			onboardingViewLeft.topAnchor.constraint(equalTo: leftSideInfoView.topAnchor),
			onboardingViewLeft.trailingAnchor.constraint(equalTo: leftSideInfoView.trailingAnchor),
			onboardingViewLeft.bottomAnchor.constraint(equalTo: leftSideInfoView.bottomAnchor),
			onboardingViewLeft.leadingAnchor.constraint(equalTo: leftSideInfoView.leadingAnchor)
		])
		
	
		
		let onboardingViewRight: NSView = onboardingSteps[step].rightSideView()
		onboardingViewRight.translatesAutoresizingMaskIntoConstraints = false
		onboardingViewRight.wantsLayer = true
		onboardingViewRight.layer?.opacity = 0.0
		
		rightSideBackgroundFrame.addSubview(onboardingViewRight)
		NSLayoutConstraint.activate([
			onboardingViewRight.topAnchor.constraint(equalTo: rightSideBackgroundFrame.topAnchor),
			onboardingViewRight.trailingAnchor.constraint(equalTo: rightSideBackgroundFrame.trailingAnchor),
			onboardingViewRight.bottomAnchor.constraint(equalTo: rightSideBackgroundFrame.bottomAnchor),
			onboardingViewRight.leadingAnchor.constraint(equalTo: rightSideBackgroundFrame.leadingAnchor)
		])
		
		DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(animationDurationBetweenSlides_ms))){ [self] in
			onboardingViewRight.layer?.add(getAppearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
			onboardingViewLeft.layer?.add(getAppearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
		}
	}
	
	private func getAppearingOpacityAnimation(for animationTime_ms: Int) -> CABasicAnimation{
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.fromValue = 0.0
		opacityAnimation.toValue = 1.0
		opacityAnimation.duration = Double(animationTime_ms) / 1000.0
		opacityAnimation.isRemovedOnCompletion = false
		opacityAnimation.fillMode = .forwards
		return opacityAnimation
	}
	
	private func getDisappearingOpacityAnimation(for animationTime_ms: Int) -> CABasicAnimation{
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.fromValue = 1.0
		opacityAnimation.toValue = 0.0
		opacityAnimation.duration = Double(animationTime_ms) / 1000.0
		opacityAnimation.isRemovedOnCompletion = false
		opacityAnimation.fillMode = .forwards
		return opacityAnimation
	}
	
	func nextStep(){
		if(onboardingSteps[currentStep].runFwdTransition()){
			return
		}
		
		if let movedToSlideAt = movedToSlideAt{
			let timeOnSlideS = (Date().timeIntervalSinceReferenceDate - movedToSlideAt.timeIntervalSinceReferenceDate)
			PostHogSDK.shared.capture("viewed_onboarding_slide", properties: ["slide": currentStep, "time_spent": timeOnSlideS])
		}
		movedToSlideAt = Date()
		
		guard (currentStep + 1) < onboardingSteps.count else {
			let timeSinceStartS = (Date().timeIntervalSinceReferenceDate - onboardingStarted!.timeIntervalSinceReferenceDate)
			PostHogSDK.shared.capture("onboarding_completed", properties: ["total_time_spent_s": timeSinceStartS])
			if let window = view.window as? NiOnboardingWindow{
				window.removeSelf()
			}
			return
		}
		currentStep += 1
		
		updateDots()
		
		for subView in leftSideInfoView.subviews{
			subView.layer?.add(getDisappearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
			DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(animationDurationBetweenSlides_ms))){
				subView.removeFromSuperview()
			}
		}
		for subView in rightSideBackgroundFrame.subviews{
			subView.layer?.add(getDisappearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
			DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(animationDurationBetweenSlides_ms))){
				subView.removeFromSuperview()
			}
		}
		loadOnboardingView(step: currentStep)
	}
	
	func prevStep(){
		if(onboardingSteps[currentStep].runBackTransition()){
			return
		}
		
		guard 0 <= (currentStep - 1) else {return}
		currentStep -= 1
		
		updateDots()
		
		for subView in leftSideInfoView.subviews{
			subView.layer?.add(getDisappearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
			DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(animationDurationBetweenSlides_ms))){
				subView.removeFromSuperview()
			}
		}
		for subView in rightSideBackgroundFrame.subviews{
			subView.layer?.add(getDisappearingOpacityAnimation(for: animationDurationBetweenSlides_ms), forKey: "opacity")
			DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(animationDurationBetweenSlides_ms))){
				subView.removeFromSuperview()
			}
		}
		loadOnboardingView(step: currentStep)
	}
		
	private func updateDots(){
		for (i, subView) in progressDotStack.arrangedSubviews.enumerated(){
			if let imgView = subView as? NSImageView{
				if(i == currentStep){
					imgView.contentTintColor = .birkin
				}else{
					imgView.contentTintColor = .sand7
				}
			}
		}
	}
	
}
