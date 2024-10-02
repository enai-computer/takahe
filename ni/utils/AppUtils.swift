//
//  AppUtils.swift
//  ni
//
//  Created by Patrick Lukas on 2/10/24.
//

import AppKit

func isDarkModeEnabled() -> Bool {
	if #available(macOS 10.14, *) {
		return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
	} else {
		return false
	}
}
