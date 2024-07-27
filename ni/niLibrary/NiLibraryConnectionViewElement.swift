//
//  NiLibraryConnectionViewElement.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryConnectionViewElement: NSView{
	
	@IBInspectable public var showLeftRight: Bool = false
	//	 {
	//		didSet {
	//			updateView()
	//		}
	//}
	
	@IBInspectable public var showRightLeft: Bool = false
//	 {
//		didSet {
//			updateView()
//		}
//	}
	
	@IBOutlet var diagonal: NSImageView!
	@IBOutlet var diagonalMirrored: NSImageView!
	@IBOutlet var middleDot: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

//		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
//		self.addTrackingArea(hoverEffect)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		updateView()
	}
	
	private func updateView(){
		if(showLeftRight){
			diagonal?.isHidden = false
		}
		if(showRightLeft){
			diagonalMirrored?.isHidden = false
		}
	}
//	override func layout() {
//		if(middleDot != nil){
//			let xDot = frame.midX - 16.0
//			let yDot = frame.midY - 16.0
//			middleDot.frame.origin = CGPoint(x: xDot, y: yDot)
//		}
//		super.layout()
//	}
}
