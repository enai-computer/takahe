//
//  EventUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Foundation
import AppKit

struct EventUtils{
	
	static let ModifierFlagsWithoutFunction = NSEvent.ModifierFlags.command.union(.option).union(.control).union(.capsLock).union(.shift)
}

