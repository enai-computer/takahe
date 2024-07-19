//
//  CFElement.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

enum FollowOnAction{
	case nothing, removeSelf
}

protocol CFContentItem{
	var owner: ContentFrameController? {get}
	var viewIsActive: Bool {get}
	func setActive() -> Void
	func setInactive() -> FollowOnAction
	func cancelOperation(_ sender: Any?) -> Void
	func spaceClosed() -> Void
	func spaceRemovedFromMemory() -> Void
	func printView(_ sender: Any?) -> Void
}

protocol CFContentSearch{
	var nextFindAvailable: Bool {get}
	var prevFindAvailable: Bool {get}
	var searchPanel: NiWebViewFindPanel? {set get}
	func resetSearchAvailability() -> Void
	func performFindNext() -> Void
	func performFindPrevious() -> Void
}
