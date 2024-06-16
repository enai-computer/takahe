//
//  NiSearchController.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiSearchController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSTextFieldDelegate, NSControlTextEditingDelegate {

	@IBOutlet var searchField: NSTextField!
	@IBOutlet var searchFieldBox: NSView!
	@IBOutlet var searchResultsScrollContainer: NSScrollView!
	@IBOutlet var searchResultsCollection: NSCollectionView!
	
	private var selectedPosition: Int = 0
	private var searchResults: [NiDocumentViewModel] = []
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		view.wantsLayer = true
		stlyeSearchField()
		stlyeSearchFieldBox()
		updateResultSet()
    }
	
	private func stlyeSearchField(){
		let attrs = [NSAttributedString.Key.foregroundColor: NSColor.sand11,
					 NSAttributedString.Key.font: NSFont(name: "Sohne-Buch", size: 21.0)]
		searchField.placeholderAttributedString = NSAttributedString(string: "What's next?", attributes: attrs as [NSAttributedString.Key : Any])
	}
	
	private func stlyeSearchFieldBox(){
		searchFieldBox.wantsLayer = true
		searchFieldBox.layer?.backgroundColor = NSColor.sand1.cgColor
		searchFieldBox.layer?.cornerRadius = 8.0
		searchFieldBox.layer?.cornerCurve = .continuous
	}
	
	private func updateResultSet(){
		searchResults = Cook.instance.searchSpaces(typedChars: nil)
		resetSelection()
	}
	
	func controlTextDidChange(_ obj: Notification) {
		if let txt = (obj.object as? NSTextField)?.stringValue{
			searchResults = Cook.instance.searchSpaces(typedChars: txt)
			searchResultsCollection.reloadData()
			resetSelection()
		}
	}
	
	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		 if commandSelector == #selector(moveUp(_:)) {
			 moveSelection(direction: .prev)
			 return true
		 } else if commandSelector == #selector(moveDown(_:)) {
			 moveSelection(direction: .next)
			 return true
		 } else if commandSelector == #selector(insertNewline(_:)) {
			 
			 return true
		 }
		 return false
	}
	

	func controlTextDidEndEditing(_ obj: Notification) {
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.down){
			
			return
		}
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.return){
			//TODO: open selected space
			return
		}
		//Cancel
		if(obj.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			if let txt = (obj.object as? NSTextField)?.stringValue{
				if(txt.isEmpty){
					if let paletteWindow = view.window as? NiPalette{
						paletteWindow.removeSelf()
						return
					}
				}
				searchField.stringValue = ""
			}
			return
		}
	}
	
	private func resetSelection(){
		if let selectedItem = searchResultsCollection.item(at: 0) as? NiSearchResultViewItem{
			selectedItem.select()
		}
		selectedPosition = 0
	}
	
	private func moveSelection(direction: LinkedListDirection){
		if let selectedItem = searchResultsCollection.item(at: selectedPosition) as? NiSearchResultViewItem{
			selectedItem.deselect()
		}
		
		if(direction == .next){
			selectedPosition += 1
		}else{
			selectedPosition -= 1
		}
		if(selectedPosition < 0){
			selectedPosition = searchResults.count - 1
		}else if (searchResults.count <= selectedPosition){
			selectedPosition = 0
		}
		
		if(6 < searchResults.count){
			searchResultsCollection.scrollToItems(at: Set(arrayLiteral: IndexPath(item: selectedPosition, section: 0)), scrollPosition: .centeredVertically)
		}

		if let selectedItem = searchResultsCollection.item(at: selectedPosition) as? NiSearchResultViewItem{
			selectedItem.select()
		}
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, 
						itemForRepresentedObjectAt indexPath: IndexPath
	) -> NSCollectionViewItem {
		let viewItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NiSearchResultViewItem"), for: indexPath)
		guard let resultView = viewItem as? NiSearchResultViewItem else {return viewItem}
		let dataItem = searchResults[indexPath.item]
		resultView.configureView(dataItem.name, spaceId: dataItem.id, position: indexPath.item)
		
		return resultView
	}
	
	func collectionView(
		_ collectionView: NSCollectionView,
		layout collectionViewLayout: NSCollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat{
		return 8.0
	}
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
	
		return NSSize(width: 556.0, height: 47.0)
	}
	
	override func cancelOperation(_ sender: Any?) {
		print("HI")
	}
    
}
