//
//  NiSpaceMenuPopup.swift
//  ni
//
//  Created by Patrick Lukas on 20/6/24.
//

import Cocoa

class NiSpaceMenuPopup: NSObject{
	
	private let parentController: NiSpaceViewController
	private let originInDocument: CGPoint
	
	init(parentController: NiSpaceViewController, originInDocument: CGPoint) {
		self.parentController = parentController
		self.originInDocument = originInDocument
	}
	
	func displayPopupWindow(event: NSEvent, screen: NSScreen) -> NiMenuWindow {
		let adjustedPos = CGPoint(
			x: event.locationInWindow.x - 13.0,
			y: event.locationInWindow.y + 9.0
		)
		let menuWindow = NiMenuWindow(origin: adjustedPos, dirtyMenuItems: getItems(), currentScreen: screen, adjustOrigin: true)
		menuWindow.makeKeyAndOrderFront(nil)
		return menuWindow
	}
	
	private func getItems() -> [NiMenuItemViewModel]{
		let pasteBoardType = NSPasteboard.general.containsImgOrText()
		let pasteItem = getPasteMenuItem(for: pasteBoardType)
		
		return [
			NiMenuItemViewModel(title: "Open a window", isEnabled: true, mouseDownFunction: openAWindow, keyboardShortcut: "⌘ N"),
			NiMenuItemViewModel(title: "Write a note", isEnabled: true, mouseDownFunction: createANote),
			pasteItem
		]
	}
	
	private func openAWindow(with event: NSEvent){
		parentController.openEmptyCF()
	}
	
	private func createANote(with event: NSEvent){
		parentController.createANote(positioned: self.originInDocument)
	}
	
	private func pasteTxt(with event: NSEvent){
		let txt = NSPasteboard.general.tryGetText()
		parentController.createANote(positioned: self.originInDocument, with: txt)
	}
	
	private func pasteImg(with event: NSEvent){
		guard let img = NSPasteboard.general.getImage() else {return}
		let title = NSPasteboard.general.tryGetName()
		parentController.pasteImage(image: img, documentPosition: self.originInDocument, title: title, source: nil)
		
	}
	
	private func getPasteMenuItem(for content: NiPasteboardContent?) -> NiMenuItemViewModel{
		if(content == .image){
			return NiMenuItemViewModel(title: "Paste an image", isEnabled: true, mouseDownFunction: pasteImg)
		}else if(content == .txt){
			return NiMenuItemViewModel(title: "Paste text", isEnabled: true, mouseDownFunction: pasteTxt)
		}
		return NiMenuItemViewModel(title: "Paste image or text", isEnabled: false, mouseDownFunction: nil)
	}
}
