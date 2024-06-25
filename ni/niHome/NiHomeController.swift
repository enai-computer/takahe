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
		
		setWelcomeMessage()
		
		styleLeftSide()
		styleRightSide()
		
		positionAndDisplaySearchView()
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		searchController.view.frame.size = CGSize(width: 678.0, height: 450.0)
		let posY = (welcomeTxt.frame.maxY - searchController.view.frame.height) + 30.0
		let posX = rightSide.frame.origin.x + 100.0
		searchController.view.frame.origin = CGPoint(x: posX, y: posY)
	}

	private func positionAndDisplaySearchView(){
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
