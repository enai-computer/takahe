//
//  CFProtocols.swift
//  ni
//
//  Created by Patrick Lukas on 19/8/24.
//

import Cocoa

protocol CFTabHeadProtocol{
	var cfTabHeadCollection: NSCollectionView? {get set}
	var niContentTabView: NSTabView! {get set}
	func updateFwdBackTint() -> Void
	/**returns true in case of success*/
	func swapView(newView: NSView, at position: Int) -> Bool
	func deleteSelectedTab(at position: Int) -> Void
}

protocol CFFwdBackButtonProtocol{
	func setBackButtonTint(_ canGoBack: Bool, trigger: NSView) -> Void
	func setForwardButtonTint(_ canGoFwd: Bool, trigger: NSView) -> Void
}

protocol CFHasGroupButtonProtocol{
	var cfGroupButton: CFGroupButton! {get set}
	func updateGroupButtonLeftConstraint() -> Void
	func layoutHeadView() -> Void
}
