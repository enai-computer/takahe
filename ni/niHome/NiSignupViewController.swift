//
//  NiSignupViewController.swift
//  ni
//
//  Created by Patrick Lukas on 12/9/24.
//

import Cocoa
import PostHog

class NiSignupViewController: NSViewController, NSTextFieldDelegate{
	
	@IBOutlet var emailFieldBox: NSView!
	@IBOutlet var emailField: NSTextField!
	@IBOutlet var confirmButton: NiActionImage!
	@IBOutlet var welcomeMessageLabel: NSTextField!
	private weak var homeViewController: NiHomeController?
	
	init(_ parentController: NiHomeController){
		self.homeViewController = parentController
		super.init(nibName: NSNib.Name("NiSignupView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		emailField.focusRingType = .none
		confirmButton.setMouseDownFunction(confirmButtonClicked)
		welcomeMessageLabel.attributedStringValue = getWelcomeMessage()
		stlyeSearchFieldBox()
	}
	
	override func viewDidDisappear() {
		confirmButton.deinitSelf()
		super.viewDidDisappear()
	}
	
	private func stlyeSearchFieldBox(){
		emailFieldBox.wantsLayer = true
		emailFieldBox.layer?.backgroundColor = NSColor.sand1.cgColor
		emailFieldBox.layer?.cornerRadius = 8.0
		emailFieldBox.layer?.cornerCurve = .continuous
	}
	
	func confirmButtonClicked(_ with: NSEvent){
		setEmail()
	}
	
	func controlTextDidEndEditing(_ notification: Notification) {
		if(notification.userInfo?["NSTextMovement"] as? Int == 16){	//return
			setEmail()
		}
	}
	
	private func setEmail(){
		guard validInput() else {
			failedValidation()
			return
		}
		let usrEmail = emailField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
		UserSettings.updateValue(setting: .userEmail, value: usrEmail)
		if !usrEmail.isEmpty{
			PostHogSDK.shared.identify(
				PostHogSDK.shared.getDistinctId(),
				userPropertiesSetOnce: ["email": usrEmail]
			)
			PostHogSDK.shared.flush()
		}
		homeViewController?.transitionFromSignupToSearch()
	}
	
	//we don't care that much right now...
	private func validInput() -> Bool{
		return true
	}
	
	private func failedValidation(){
		emailFieldBox.wantsLayer = true
		emailFieldBox.layer?.borderColor = NSColor.birkin.cgColor
		emailFieldBox.layer?.borderWidth = 2.0
	}
	
	override func cancelOperation(_ sender: Any?) {
		emailField.stringValue = ""
	}
	
	func getWelcomeMessage() -> NSAttributedString{
		let welcomeMessage: String = """
		 We are Curran & Patrick, the people behind Enai.
		 Our email is hello@enai.io.
		 If you have any questions or feedback,
		 we are available any time.
		 Texts are also welcome:

		 iMessage: +49 151 404 82120
		 WhatsApp: +1 626 818 4954
		"""
		let textParagraph = NSMutableParagraphStyle()
		textParagraph.lineSpacing = 3.0
		let attrs = [NSAttributedString.Key.foregroundColor: NSColor.sand11,
					 NSAttributedString.Key.paragraphStyle: textParagraph,
					 NSAttributedString.Key.font: NSFont(name: "Sohne-Buch", size: 16.0)]
		
		let res = NSMutableAttributedString(
			string: welcomeMessage,
			attributes: attrs as [NSAttributedString.Key : Any])
		
//		let linkRange = NSRange(location: 56, length: 15)
//		res.addAttribute(.link,
//						 value: URL(string: "mailto:curran@enai.io") as Any,
//						 range: linkRange)
//		res.addAttribute(.foregroundColor,
//						 value: NSColor.birkin.cgColor,
//						 range: linkRange)
//		res.addAttribute(.backgroundColor,
//						 value: NSColor.transparent.cgColor,
//						 range: linkRange)
//		res.addAttribute(.color, value: <#T##Any#>, range: <#T##NSRange#>)
		return res
	}
	
}
