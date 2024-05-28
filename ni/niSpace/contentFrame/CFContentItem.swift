//
//  CFElement.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Foundation

enum FollowOnAction{
	case nothing, removeSelf
}

protocol CFContentItem{
	var viewIsActive: Bool {get}
	func setActive() -> Void
	func setInactive() -> FollowOnAction
	func cancelOperation(_ sender: Any?) -> Void
}
