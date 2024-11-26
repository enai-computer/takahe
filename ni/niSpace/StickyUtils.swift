//
//  StickyUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 26/11/24.
//

import Cocoa

enum StickyColor: String, CaseIterable{
	case yellow, mint, blue, plum, orange, brown
	
	func toNSColor() -> NSColor{
		switch self{
			case .yellow:
				return NSColor.stickyYellow
			case .mint:
				return NSColor.stickyMint
			case .blue:
				return NSColor.stickyBlue
			case .plum:
				return NSColor.stickyPlum
			case .orange:
				return NSColor.stickyOrange
			case .brown:
				return NSColor.stickyBrown
		}
	}
}

class StickyColorPicker: NSViewController{
	
	let initPos: NSPoint
	private weak var spaceController: NiSpaceViewController?
	
	init(spaceController: NiSpaceViewController, pos: NSPoint) {
		self.spaceController = spaceController
		initPos = pos
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let padding = 4.0
		let colorFieldWidth = 16.0
		let nrOfColors = Double(StickyColor.allCases.count)
		let w: Double = padding * nrOfColors + colorFieldWidth * nrOfColors
		
		let frame = NSRect(origin: initPos, size: CGSize(width: w, height: (colorFieldWidth + padding)))
		view = NSView(frame: frame)
		
		styleView()
		
		let defaultColorSize = CGSize(width: colorFieldWidth, height: colorFieldWidth)
		var originX = (padding / 2)
		for color in StickyColor.allCases.makeIterator(){
			let colViewFrame = NSRect(origin: CGPoint(x: originX, y: 2.0), size: defaultColorSize)
			let colView = SingleStickyColorPickerColorView(frame: colViewFrame, color: color, spaceController: spaceController)
			
			view.addSubview(colView)
			originX += colViewFrame.width + padding
		}
	}
	
	private func styleView(){
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand3.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.cornerRadius = 4.0
	}
}

class SingleStickyColorPickerColorView: NSView{
	
	private weak var spaceController: NiSpaceViewController?
	private let color: StickyColor
	private let outerShadow: NSShadow
	private let innerShadowLayer: CALayer
	
	init(frame frameRect: NSRect, color: StickyColor, spaceController: NiSpaceViewController?) {
		self.spaceController = spaceController
		self.color = color
		
		innerShadowLayer = CALayer()
		innerShadowLayer.cornerRadius = 15.0
		innerShadowLayer.masksToBounds = true
		innerShadowLayer.shadowColor = NSColor.sand1.cgColor
		innerShadowLayer.shadowOffset = NSSize(width: 0.0, height: -1.0)
		innerShadowLayer.shadowOpacity = 1.0
		innerShadowLayer.shadowRadius = 1.0
		outerShadow = NSShadow()
		outerShadow.shadowColor = NSColor.sand9
		outerShadow.shadowOffset = CGSize(width: 0.0, height: -1.0)
		outerShadow.shadowBlurRadius = 1.5
		
		super.init(frame: frameRect)
		
		wantsLayer = true
		layer?.cornerCurve = .continuous
		layer?.cornerRadius = 2.0
		layer?.backgroundColor = color.toNSColor().cgColor
		layer?.masksToBounds = false
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func mouseEntered(with event: NSEvent) {
		shadow = outerShadow
		innerShadowLayer.frame = bounds.insetBy(dx: 0.2, dy: 0.5)
		layer?.addSublayer(innerShadowLayer)
	}
	
	override func mouseDown(with event: NSEvent){
		spaceController?.createSticky(with: color)
	}
	
	override func mouseExited(with event: NSEvent) {
		shadow = nil
		innerShadowLayer.removeFromSuperlayer()
	}
	
}
