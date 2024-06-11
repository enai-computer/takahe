//
//  NiMenuView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuView: NSBox{
	
	@IBOutlet var lstOfMenuItems: NSStackView!
	private var dropShadow2 = CALayer()
	
	override func layout() {
		super.layout()
		
		self.clipsToBounds = false
		
		self.layer?.shadowColor = NSColor.sand11.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 0.37
		self.layer?.shadowRadius = 2.0
		self.layer?.masksToBounds = false

		self.dropShadow2.removeFromSuperlayer()
		
		self.dropShadow2 = CALayer(layer: self.layer!)
		self.dropShadow2.shadowPath = NSBezierPath(rect: bounds).cgPath
		self.dropShadow2.shadowColor = NSColor.sand11.cgColor
		self.dropShadow2.shadowOffset = CGSize(width: 2.0, height: -4.0)
		self.dropShadow2.shadowOpacity = 0.23
		self.dropShadow2.shadowRadius = 5.8
		self.dropShadow2.masksToBounds = false

		self.layer?.insertSublayer(self.dropShadow2, at: 0)
	}
}
