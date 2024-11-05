//
//  NiMenuItem.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

struct NiMenuItemViewModel{
	enum Label {
		case title(String)
		case views([NSView])
	}

	let label: Label
	var title: String {
		return switch label {
		case .title(let string): string
		case .views: ""
		}
	}
	let isEnabled: Bool
	let mouseDownFunction: ((NSEvent) -> Void)?
	var keyboardShortcut: String? = nil
}

extension NiMenuItemViewModel {
	init(
		title: String,
		isEnabled: Bool,
		mouseDownFunction: ((NSEvent) -> Void)?,
		keyboardShortcut: String? = nil
	) {
		self.init(
			label: .title(title),
			isEnabled: isEnabled,
			mouseDownFunction: mouseDownFunction,
			keyboardShortcut: keyboardShortcut
		)
	}
}
