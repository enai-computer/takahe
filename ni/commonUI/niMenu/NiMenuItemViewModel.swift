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

extension NiMenuItemViewModel.Label {
	init(fromContentFrameController controller: CFProtocol) {
		if let groupName = controller.groupName {
			self = .title(groupName)
		} else {
			guard !controller.tabs.isEmpty else {
				assertionFailure("ContentFrameController expected to have either a groupName or tabs")
				self = .title("(Empty)")
				return
			}
			self = .views(genCollapsedMinimzedStackItems(
				tabs: controller.tabs,
				limit: NiMenuItemView.menuItemIconLimit,
				handler: nil
			))
		}
	}
}
