//
//  CFSectionTitleView.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa

class CFSectionTitleView: CFBaseView{
	
	@IBOutlet var sectionTitle: NSTextField!
	
	func initAfterViewLoad(sectionName: String?){
		sectionTitle.stringValue = "TEST NAME"//sectionName ?? ""
		
		self.wantsLayer = true
		self.layer?.addSublayer(bottomBorder())
	}
	
	private func bottomBorder() -> CALayer{
		let bottomBorder = CALayer(layer: layer!)
		bottomBorder.borderColor = NSColor.sand115.cgColor
		bottomBorder.borderWidth = 2.0
		bottomBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 2.0)
		return bottomBorder
	}
	
	override func toggleActive(){}
}
