//
//  NiHomeController.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa

class NiHomeController: NSViewController {
	
	@IBOutlet var leftSide: NSView!
	@IBOutlet var rightSide: NSView!
	@IBOutlet var welcomeTxt: NSTextField!
	
	private var searchController: NiSearchController
	private let viewFrame: NSRect
	private var dropShadow2 = CALayer()
	
	init(frame: NSRect) {
		self.viewFrame = frame
		self.searchController = NiSearchController(style: .homeView)
		super.init(nibName: NSNib.Name("NiHomeView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.frame = viewFrame
		
		view.wantsLayer = true
		styleHomeView()
		
		setWelcomeMessage()
		styleLeftSide()
		styleRightSide()
		
		positionAndDisplaySearchView()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		self.addShadow()
	}
	
	private func styleHomeView(){
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 30.0
		view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer?.masksToBounds = true
	}
	
	private func addShadow(){
		let shadowView = RoundedRectView(frame: viewFrame)
		shadowView.wantsLayer = true
		shadowView.clipsToBounds = false
		shadowView.layer?.shadowColor = NSColor.sand11.cgColor
		shadowView.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		shadowView.layer?.shadowOpacity = 0.15
		shadowView.layer?.shadowRadius = 4.0
		shadowView.layer?.shadowPath = roundedCornersPath(in: view.bounds,
													having: [.bottomLeft, .bottomRight],
													with: 30.0)
		self.dropShadow2 = CALayer(layer: shadowView.layer!)
		self.dropShadow2.shadowPath = NSBezierPath(rect: view.bounds).cgPath
		self.dropShadow2.shadowColor = NSColor.sand11.cgColor
		self.dropShadow2.shadowOffset = CGSize(width: 2.0, height: -4.0)
		self.dropShadow2.shadowOpacity = 0.15
		self.dropShadow2.shadowRadius = 10.0
		self.dropShadow2.masksToBounds = false

		shadowView.layer?.insertSublayer(self.dropShadow2, at: 0)
		self.view.superview?.addSubview(shadowView, positioned: .below, relativeTo: self.view)
	}
	
	private func positionAndDisplaySearchView(){
		searchController.view.frame.size = CGSize(width: 678.0, height: 450.0)
		let posY = (welcomeTxt.frame.maxY - searchController.view.frame.height)
		let posX = rightSide.frame.origin.x + 100.0
		searchController.view.frame.origin = CGPoint(x: posX, y: posY)
		
		self.view.addSubview(searchController.view)
		view.window?.makeFirstResponder(searchController.searchField)
	}
	
	private func setWelcomeMessage(){
		welcomeTxt.stringValue = "\(getWelcomeMessage()), \(NSUserName())"
	}
	
	private func styleLeftSide(){
		leftSide.wantsLayer = true
		leftSide.layer?.backgroundColor = NSColor.sand1.cgColor
	}
	
	private func styleRightSide(){
		rightSide.wantsLayer = true
		rightSide.layer?.backgroundColor = NSColor.sand3.cgColor
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

}
