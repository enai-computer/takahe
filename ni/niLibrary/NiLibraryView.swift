//
//  NiLibraryView.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryView: NSBox{
	
	@IBOutlet var contentBox: NSView!
	
	@IBOutlet var attention: DemoLibraryImage!
	@IBOutlet var berlin: DemoLibraryImage!
	@IBOutlet var mlSysDesign: DemoLibraryImage!
	@IBOutlet var books: DemoLibraryImage!
	@IBOutlet var cooking: DemoLibraryImage!
	@IBOutlet var jets: DemoLibraryImage!
	@IBOutlet var interface: DemoLibraryImage!
	@IBOutlet var wedding: DemoLibraryImage!
	@IBOutlet var hciFoundations: DemoLibraryImage!
	@IBOutlet var introOS: DemoLibraryImage!
	
	func setHoverStateImgs(){
		attention.setHoverImg("payAttentionU")
		mlSysDesign.setHoverImg("MLsysDesignU")
		books.setHoverImg("booksU")
		cooking.setHoverImg("cookingU")
		jets.setHoverImg("jetsU")
		interface.setHoverImg("interfacesU")
		wedding.setHoverImg("weddingU")
		hciFoundations.setHoverImg("HCIU")
		introOS.setHoverImg("introOSU")
		berlin.setHoverImg("BerlinU")
	}
	
	func hideSpaces(){
		for v in contentBox.subviews{
			if let demoImage = v as? DemoLibraryImage{
				demoImage.tryHide()
			}
		}
	}
}
