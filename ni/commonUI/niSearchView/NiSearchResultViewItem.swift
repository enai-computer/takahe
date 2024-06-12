//
//  NiSearchResultViewItem.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa
//    NiSearchResultViewItem
class NiSearchResultViewItem: NSCollectionViewItem {

	@IBOutlet var resultTitle: NSTextField!
	@IBOutlet var rightSideElement: NiSearchResultViewItemRightIcon!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.sand1T80.cgColor
    }
    
}
