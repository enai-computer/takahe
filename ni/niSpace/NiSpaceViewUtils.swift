//
//  NiSpaceViewUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 25/11/24.
//
import Cocoa

func genToolbarStack(for controller: NiSpaceViewController) -> [NSView]{
	let sticky = NiActionImage(namedImage: "stickyIcon", with: NSSize(width: 24.0, height: 24.0))!
	sticky.isActiveFunction = {return true}
	sticky.setMouseDownFunction({ _ in
		guard var pointOnScreen = sticky.superview?.convert(sticky.frame.origin, to: nil) else {return}
		pointOnScreen.y += sticky.frame.height + 9.0
		let colorPicker = StickyColorPickerWindow(
			origin: pointOnScreen,
			currentScreen: sticky.window!.screen!,
			spaceController: controller
		)
		colorPicker.makeKeyAndOrderFront(nil)
	})
	
	let note = NiActionImage(namedImage: "noteIcon", with: NSSize(width: 24.0, height: 24.0))!
	note.isActiveFunction = {return true}
	note.setMouseDownFunction({ _ in
		controller.createANote(positioned: nil)
	})
	
	let group = NiActionImage(namedImage: "groupIcon", with: NSSize(width: 24.0, height: 24.0))!
	group.isActiveFunction = {return true}
	group.setMouseDownFunction({ _ in
		controller.openEmptyCF()
	})

	let sectionTitle = NiActionImage(namedImage: "sectionTitle", with: NSSize(width: 24.0, height: 24.0))!
	sectionTitle.isActiveFunction = {return true}
	sectionTitle.setMouseDownFunction({ _ in
		controller.createSectionTitle()
	})
	
	return [group, note, sticky, sectionTitle]
}
