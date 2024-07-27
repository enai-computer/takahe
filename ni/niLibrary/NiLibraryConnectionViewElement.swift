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

	required init?(coder: NSCoder) {
		super.init(coder: coder)

//		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
//		self.addTrackingArea(hoverEffect)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
	}

	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let context = NSGraphicsContext.current?.cgContext else{return}

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
	}
	

}
