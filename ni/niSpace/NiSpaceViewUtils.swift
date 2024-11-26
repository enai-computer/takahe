//
//  NiSpaceViewUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 25/11/24.
//
import Cocoa

func genToolbarStack() -> [NSView]{
	
	return [
		NiActionImage(namedImage: "stickyIcon", with: NSSize(width: 24.0, height: 24.0))!,
		NiActionImage(namedImage: "noteIcon", with: NSSize(width: 24.0, height: 24.0))!,
		NiActionImage(namedImage: "groupIcon", with: NSSize(width: 24.0, height: 24.0))!
	]
}
