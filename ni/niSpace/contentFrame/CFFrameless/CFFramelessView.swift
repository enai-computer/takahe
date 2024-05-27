//
//  CFFramelessView.swift
//  ni
//
//  Created by Patrick Lukas on 26/5/24.
//

import Cocoa

class CFFramelessView: CFBaseView {
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	}
	
	func setContentView(view: NSView){
		self.contentView = view
	}
	
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		self.contentView = tabView
		return -1
	}
}
