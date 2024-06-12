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
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		<#code#>
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		<#code#>
	}
	
    
}
