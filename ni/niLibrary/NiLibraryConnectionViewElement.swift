//
//  NiLibraryConnectionViewElement.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

@IBDesignable class NiLibraryConnectionViewElement: NSView{
	
	@IBInspectable public var lineBottomLeftToTopRight: Bool = false {
		didSet {
			needsDisplay = true
		}
	}
	@IBInspectable public var lineBottomRightToTopLeft: Bool = false{
		didSet {
			needsDisplay = true
		}
	}
	@IBInspectable public var strokeColor: NSColor = .birkin
	@IBInspectable public var strokeWidth: CGFloat = 2.0
	@IBInspectable public var dotColor: NSColor = .sand1
	@IBInspectable public var dotDiameter: CGFloat = 30.0
	
	private var hovering: Bool = false
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		let hoverEffect = NSTrackingArea.init(rect: calcDotRect(), options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
	}

	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let context = NSGraphicsContext.current?.cgContext else{return}

		//draws line
		context.beginPath()
		if(lineBottomLeftToTopRight){
			context.move(to: .zero)
			context.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
		}
		if(lineBottomRightToTopLeft){
			context.move(to: NSPoint(x: bounds.maxX, y: bounds.minY))
			context.addLine(to: NSPoint(x: bounds.minX, y: bounds.maxY))
		}
		context.setStrokeColor(strokeColor.cgColor)
		context.setLineWidth(strokeWidth)
		context.strokePath()
		
		//draws middle dot
		let dotRect = calcDotRect()
		context.setFillColor(dotColor.cgColor)
		context.addEllipse(in: dotRect)
		context.drawPath(using: .fill)
		
		context.saveGState()
		
		context.setStrokeColor(.clear)
		context.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 1.0, color: NSColor.sand9.cgColor)
		context.addEllipse(in: dotRect)
		context.drawPath(using: .fillStroke)
		
		context.restoreGState()
		
		if(hovering){
			context.setStrokeColor(strokeColor.cgColor)
			context.setLineWidth(2.0)
			context.addEllipse(in: dotRect)
			context.drawPath(using: .stroke)
			
			context.setFillColor(strokeColor.cgColor)
			context.addEllipse(in: calcMiniHoverDotRect())
			context.drawPath(using: .fill)
		}
	}
	
	private func calcDotRect() -> CGRect{
		return CGRect(
			origin: CGPoint(
				x: bounds.midX - (dotDiameter/2),
				y: bounds.midY - (dotDiameter/2)
			),
			size: CGSize(width: dotDiameter, height: dotDiameter)
		)
	}

	private func calcMiniHoverDotRect() -> CGRect{
		let miniDiameter = 6.0
		return CGRect(
			origin: CGPoint(
				x: bounds.midX - (miniDiameter/2),
				y: bounds.midY - (miniDiameter/2)
			),
			size: CGSize(width: miniDiameter, height: miniDiameter)
		)
	}
	
	override func mouseEntered(with event: NSEvent) {
		hovering = true
		needsDisplay = true
	}
	
	override func mouseExited(with event: NSEvent) {
		hovering = false
		needsDisplay = true
	}
}
