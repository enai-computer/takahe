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

	@IBOutlet var middleDot: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

//		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
//		self.addTrackingArea(hoverEffect)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
//		updateView()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		strokeColor.set() // choose color
		let figure = NSBezierPath() // container for line(s)
		
		if(lineBottomLeftToTopRight){
			figure.move(to: frame.origin)
			figure.line(to: NSPoint(x: frame.maxX, y: frame.maxY))
			
//			figure.move(to: dirtyRect.origin)
//			figure.line(to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.maxY))
		}
		if(lineBottomRightToTopLeft){
			figure.move(to: NSPoint(x: frame.maxX, y: frame.minY))
			figure.line(to: NSPoint(x: frame.minX, y: frame.maxY))
//			figure.move(to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.minY))
//			figure.line(to: NSPoint(x: dirtyRect.minX, y: dirtyRect.maxY))
		}
		figure.lineWidth = strokeWidth  // hair line
		figure.stroke()  // draw line(s) in color
	}
	
	override func layout() {
		if(middleDot != nil){
			let xDot = frame.midX - 16.0
			let yDot = frame.midY - 16.0
			middleDot.frame.origin = CGPoint(x: xDot, y: yDot)
		}
		super.layout()
	}
}
