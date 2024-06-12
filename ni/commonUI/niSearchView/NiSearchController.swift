//
//  NiSearchController.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiSearchController: NSViewController, NSCollectionViewDataSource, NSTextFieldDelegate {

	@IBOutlet var searchField: NSTextField!
	@IBOutlet var searchResultsScrollContainer: NSScrollView!
	@IBOutlet var searchResultsCollection: NSCollectionView!
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.birkin.cgColor
    }
	
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		//TODO: build me
		return 0
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NiSearchResultViewItem"), for: indexPath)
		return item
	}
	
    
}
