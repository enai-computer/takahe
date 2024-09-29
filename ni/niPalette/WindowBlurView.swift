//
//  WindowBlurView.swift
//  ni
//
//  Created by Patrick Lukas on 29/9/24.
//
import Cocoa

class WindowBlurView: NSView{
	
	public weak var niPalette: NiPalette?
	
	override func mouseDown(with event: NSEvent) {
		niPalette?.removeSelf()
	}
}
