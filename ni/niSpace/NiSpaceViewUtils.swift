//
//  NiSpaceViewUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 25/11/24.
//
import Cocoa

func genToolbarStack(for controller: NiSpaceViewController) -> [NSView]{
	let sticky = NiActionImage(namedImage: "stickyIcon", with: NSSize(width: 24.0, height: 24.0))!
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
	
	return [group, note, sticky]
}
