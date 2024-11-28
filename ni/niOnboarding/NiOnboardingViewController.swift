//
//  NiOnboardingViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import Cocoa

class NiOnboardingViewController: NSViewController{

	@IBOutlet var leftSideBackgroundFrame: NSView!
	@IBOutlet var leftSideInfoView: NSView!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var fwdButton: NiActionImage!
	
	@IBOutlet var rightSideBackgroundFrame: NSView!
	
	private let viewFrame: NSRect
	
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
	}
	
	private func styleLeftSide(){
		leftSideBackgroundFrame.wantsLayer = true
		leftSideBackgroundFrame.layer?.backgroundColor = NSColor.sand3.cgColor
	}
	
	private func styleRightSide(){
		rightSideBackgroundFrame.wantsLayer = true
		rightSideBackgroundFrame.layer?.backgroundColor = NSColor.sand1.cgColor
	}
}
