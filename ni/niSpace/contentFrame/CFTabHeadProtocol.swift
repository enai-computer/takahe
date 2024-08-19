//
//  CFTabHeadProtocol.swift
//  ni
//
//  Created by Patrick Lukas on 19/8/24.
//

import Cocoa

protocol CFTabHeadProtocol{
	var cfTabHeadCollection: NSCollectionView? {get set}
	var niContentTabView: NSTabView! {get set}
	func updateFwdBackTint() -> Void
	func deleteSelectedTab(at position: Int) -> Void
}
