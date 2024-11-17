//
//  NiHomeController.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa

class NiHomeController: NSViewController, NSTextFieldDelegate {
	
	@IBOutlet var leftSideFrame: NSView!
	@IBOutlet var rightSideFrame: NSView!
	@IBOutlet var welcomeStackView: NSStackView!
	@IBOutlet var welcomeTxt: NSTextField!
	@IBOutlet var userName: NiTextField!
	
	private var weatherView: WeatherNSView?
	
	private var searchController: NiSearchController
	private var signupViewController: NiSignupViewController?
	private weak var rightSideContentView: NSView?
	@available(*, deprecated, message: "Prefer to auto-size the `view` to its container view")
	private var viewFrame: NSRect?
	private var dropShadow2 = CALayer()

	@available(*, deprecated, message: "Prefer to auto-size the `view` to its container view")
	convenience init(frame: NSRect? = nil) {
		self.init()
		self.viewFrame = frame
	}

	required init() {
		self.searchController = NiSearchController(style: .homeView)
		super.init(nibName: NSNib.Name("NiHomeView"), bundle: Bundle.main)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let viewFrame {
			self.view.frame = viewFrame
		}

		view.wantsLayer = true

		self.setWelcomeMessage()
		self.addWeatherWidget()

		styleLeftSide()
		styleRightSide()
		
		if(UserSettings.shared.userEmail != nil){
			displaySearchView()
		}else{
			displaySignupView()
		}
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		positionRightSideContentView()
	}
	
	override func viewDidLayout(){
		super.viewDidLayout()
	}
	
	private func positionRightSideContentView(){
		if let viewObj = rightSideContentView{
			viewObj.frame.size = CGSize(width: 678.0, height: 450.0)
			let posY = (welcomeStackView.frame.maxY - viewObj.frame.height) + 30.0
			let posX = rightSideFrame.frame.origin.x + 100.0
			viewObj.frame.origin = CGPoint(x: posX, y: posY)
		}
	}
	
	private func displaySearchView(){
		self.view.addSubview(searchController.view)
		rightSideContentView = searchController.view
		view.window?.makeFirstResponder(searchController.searchField)
	}
	
	private func displaySignupView(){
		signupViewController = NiSignupViewController(self)
		self.view.addSubview(signupViewController!.view)
		rightSideContentView = signupViewController!.view
		view.window?.makeFirstResponder(signupViewController!.emailField)
	}
	
	func transitionFromSignupToSearch(){
		rightSideContentView?.removeFromSuperview()
		signupViewController?.removeFromParent()
		signupViewController = nil
		displaySearchView()
		positionRightSideContentView()
	}
	
	private func setWelcomeMessage(){
		welcomeTxt.stringValue = "\(getWelcomeMessage()),"
		userName.stringValue = " \(UserSettings.shared.userFirstName)"
	}
	
	private func styleLeftSide(){
		leftSideFrame.wantsLayer = true
		leftSideFrame.layer?.backgroundColor = NSColor.sand1.cgColor
		userName.hasHoverEffect = true
		userName.hoverTint = nil
		userName.hoverCursor = NSCursor.pointingHand
		userName.hoverBackground = .sand4
	}
	
	private func addWeatherWidget(){
		let width = 300.0
		let height = 60.0
		let padding = 44.0
		weatherView = WeatherNSView(
			frame: NSRect(
				x: welcomeStackView.frame.maxX - width,
				y: welcomeStackView.frame.minY - padding - height,
				width: width,
				height: height
			)
		)
		view.addSubview(weatherView!)
	}
	
	private func styleRightSide(){
		rightSideFrame.wantsLayer = true
		rightSideFrame.layer?.backgroundColor = NSColor.sand3.cgColor
	}

	private func roundedCornersPath(in rect: CGRect, having corners: RectCorner, with radius: CGFloat = .zero) -> CGPath {
		let path = CGMutablePath()
		
		let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
		let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

		let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
		let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

		let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
		let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

		let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
		let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )

		
		path.move(to: p1)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
					tangent2End: p2,
					radius: radius)
		path.addLine(to: p3)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
					tangent2End: p4,
					radius: radius)
		path.addLine(to: p5)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
					tangent2End: p6,
					radius: radius)
		path.addLine(to: p7)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
					tangent2End: p8,
					radius: radius)
		path.closeSubpath()
		
		return path
	}
	
	struct RectCorner: OptionSet {
		
		let rawValue: Int
			
		static let topLeft = RectCorner(rawValue: 1 << 0)
		static let topRight = RectCorner(rawValue: 1 << 1)
		static let bottomRight = RectCorner(rawValue: 1 << 2)
		static let bottomLeft = RectCorner(rawValue: 1 << 3)
		
		static let allCorners: RectCorner = [.topLeft, topRight, .bottomLeft, .bottomRight]
	}
	
	//MARK: - mouse down edit name
	override func mouseDown(with event: NSEvent) {
		let cursorPos = self.welcomeStackView.convert(event.locationInWindow, from: nil)
		
		if(NSPointInRect(cursorPos, userName.frame)){
			if(event.clickCount == 1){
				editUserName()
			}
		}
	}

	private func editUserName(){
		guard !userName.isEditable else {return}
		
		userName.refusesFirstResponder = false
		userName.isSelectable = true
		userName.isEditable = true
		
		userName.focusRingType = .none
		userName.delegate = self
		
		view.window?.makeFirstResponder(userName)
	}
	
	
	func controlTextDidEndEditing(_ obj: Notification){
		userName.layer?.backgroundColor = .clear
		
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			revertRenamingChanges()
			endEditing()
			return
		}
		if(userName.stringValue.isEmpty){
			revertRenamingChanges()
			endEditing()
			return
		}
		endEditing()
		let cleanName = userName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).truncate(20)
		UserSettings.updateValue(setting: .userFirstName, value: cleanName)
		
		userName.stringValue = " " + cleanName
	}
	
	private func endEditing(){
		userName.currentEditor()?.selectedRange = NSMakeRange(0, 0)
		userName.isEditable = false
		userName.isSelectable = false
		
		//need to have a different first responder right away,
		//otherwise we cannot click directly onto the spaceName again to rename, as the click will not be registered correctly
		view.window?.makeFirstResponder(searchController.searchField)
	}
	
	private func revertRenamingChanges(){
		userName.stringValue = " \(UserSettings.shared.userFirstName)"
	}
}
