//
//  NiMenuItem.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

struct NiMenuItemViewModel{
	
	let title: String
	let isEnabled: Bool
	let mouseDownFunction: ((NSEvent) -> Void)?
	
}
