//
//  CFFullScreenScrollView.swift
//  ni
//
//  Created by Patrick Lukas on 30/9/24.
//
import Cocoa

class CFFullScreenScrollView: NSScrollView{
	
	override func mouseDown(with event: NSEvent) {
		guard let appDel = NSApplication.shared.delegate as? AppDelegate else{return}
		appDel.getNiSpaceViewController()?.saveAndOpenHome()
	}
}
