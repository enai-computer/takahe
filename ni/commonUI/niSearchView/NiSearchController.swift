//
//  NiSearchController.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa
import Carbon.HIToolbox

enum NiSearchViewStyle{
	case palette, homeView
}

class NiSearchController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSTextFieldDelegate, NSControlTextEditingDelegate {
	
	@IBOutlet var searchField: NSTextField!
	@IBOutlet var searchFieldBox: NSView!
	@IBOutlet var searchResultsScrollContainer: NSScrollView!
	@IBOutlet var searchResultsCollection: NSCollectionView!
	
	private var eveChatResultView: EveChatView?
	private var chatShown: Bool = false
	private var selectedPosition: Int = 0
	private var searchResults: [NiSearchResultItem] = []
	private var currentSpaceId: UUID? = nil
	private let style: NiSearchViewStyle
	
	init(style: NiSearchViewStyle){
		self.style = style
		super.init(nibName: NSNib.Name("NiSearchView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		updateResultSet()
	}
	
	override func viewDidAppear(){
		super.viewDidAppear()
		if let appDelegate = NSApplication.shared.delegate as? AppDelegate{
			currentSpaceId = appDelegate.getNiSpaceViewController()?.niSpaceID
		}
	}
	
	override func viewWillLayout() {
		stlyeSelf()
		stlyeSearchField()
		stlyeSearchFieldBox()
		styleSearchResultsScrollContainer()
		
		super.viewWillLayout()
	}
	
	private func stlyeSelf(){
		view.wantsLayer = true
		
		if(style == .palette){return}
		
		view.layer?.borderColor = NSColor.clear.cgColor
		view.layer?.backgroundColor = NSColor.clear.cgColor
		if let myView = view as? NSBox{
			myView.fillColor = NSColor.clear
			myView.borderColor = NSColor.clear
		}
	}
	
	private func stlyeSearchField(){
		let attrs = [NSAttributedString.Key.foregroundColor: NSColor.sand11,
					 NSAttributedString.Key.font: NSFont(name: "Sohne-Buch", size: 21.0)]
		if(style == .palette){
			searchField.placeholderAttributedString = NSAttributedString(string: "What's next?", attributes: attrs as [NSAttributedString.Key : Any])
		}else if(style == .homeView){
			searchField.placeholderAttributedString = NSAttributedString(string: "What would you like to do?", attributes: attrs as [NSAttributedString.Key : Any])
		}
		searchField.focusRingType = .none
	}
	
	private func stlyeSearchFieldBox(){
		searchFieldBox.wantsLayer = true
		searchFieldBox.layer?.backgroundColor = NSColor.sand1.cgColor
		searchFieldBox.layer?.cornerRadius = 8.0
		searchFieldBox.layer?.cornerCurve = .continuous
	}
	
	private func styleSearchResultsScrollContainer(){
		if(style == .homeView){
			searchResultsScrollContainer.frame.size.height += 4.0
			searchResultsScrollContainer.frame.origin.y -= 10
			return
		}
		searchResultsScrollContainer.contentView.wantsLayer = true
		searchResultsScrollContainer.contentView.layer?.backgroundColor = NSColor.sand8T20.cgColor
		searchResultsScrollContainer.contentView.layer?.cornerRadius = 4.0
		searchResultsScrollContainer.contentView.layer?.cornerCurve = .continuous
	}
	
	private func updateResultSet(){
		if(view.window is NiPalette){
			searchResults = Cook.instance.search(typedChars: nil, excludeWelcomeSpaceGeneration: false)
			searchResults.removeFirst()
		}else{
			searchResults = Cook.instance.search(typedChars: nil, excludeWelcomeSpaceGeneration: false, insertWelcomeSpaceGenFirst: true, returnAskEnaiOption: false)
		}
		searchResultsCollection.reloadData()
		resetSelection()
	}
	
	func controlTextDidChange(_ obj: Notification) {
		if chatShown{
			eveChatResultView?.removeFromSuperview()
			view.addSubview(searchResultsScrollContainer)
			chatShown = false
		}
		if let dirtyTxt = (obj.object as? NSTextField)?.stringValue{
			let updatedResults: [NiSearchResultItem]
			if(view.window is NiPalette){
				updatedResults = Cook.instance.search(typedChars: dirtyTxt, giveCreateNewSpaceOption: true, currentSpaceId: currentSpaceId)
			}else{
				updatedResults = Cook.instance.search(typedChars: dirtyTxt, giveCreateNewSpaceOption: true, returnAskEnaiOption: false)
			}

			updateResultsCollection(updatedResults)
			resetSelection()
		}
	}
	
	private func updateResultsCollection(_ updatedResults:[NiSearchResultItem]){
		// 0. Diff
		let diff = ListDiffHelper.diff(searchResults, updatedResults)

		searchResultsCollection.performBatchUpdates({
			// 1. update data-source
			self.searchResults = updatedResults
			
			// 2. update UI
			searchResultsCollection.deleteItems(at: diff.removals)
			for item in diff.moves{
				searchResultsCollection.moveItem(at: item.0, to: item.1)
			}
			searchResultsCollection.insertItems(at: diff.insertions)
		})
		
		for item in diff.moves{
			if let resultViewItem = searchResultsCollection.item(at: item.1.item) as? NiSearchResultViewItem{
				resultViewItem.moved(to: item.1.item)
			}
		}
	}
	
	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == #selector(NSTextView.moveUp) {
			moveSelection(direction: .prev)
			return true
		} else if commandSelector == #selector(NSTextView.moveDown) {
			moveSelection(direction: .next)
			return true
		} else if commandSelector == #selector(NSTextView.insertNewline) {
			preActionStyle()
			return true
		} else if commandSelector == NSSelectorFromString("noop:") {
			if let event = view.window?.currentEvent{
				handleNoopCommand(with: event)
				return true
			}
			return false
		}
		return false
	}
	
	override func keyUp(with event: NSEvent){
		if(event.keyCode == kVK_Return || event.keyCode == kVK_ANSI_KeypadEnter){
			openSpace()
			return
		}
		super.keyUp(with: event)
	}
	
	private func handleNoopCommand(with event: NSEvent){
		if(event.modifierFlags.contains(.command)){
			switch Int(event.keyCode){
				case kVK_ANSI_1:
					openSpace(1)
				case kVK_ANSI_2:
					openSpace(2)
				case kVK_ANSI_3:
					openSpace(3)
				case kVK_ANSI_4:
					openSpace(4)
				case kVK_ANSI_5:
					openSpace(5)
				default:
					return
			}
		}
	}
	
	private func openSpace(_ selected: Int? = nil){
		let selectedItemIndex = selected ?? self.selectedPosition
		guard let selectedItem = searchResultsCollection.item(at: selectedItemIndex) as? NiSearchResultViewItem else { return }
		selectedItem.tryOpenResult()
	}
	
	private func preActionStyle(_ selected: Int? = nil){
		let selectedItemIndex = selected ?? self.selectedPosition
		guard let selectedItem = searchResultsCollection.item(at: selectedItemIndex) as? NiSearchResultViewItem else { return }
		selectedItem.preActionStyle()
	}
	
	func controlTextDidEndEditing(_ obj: Notification) {
		return
	}
	
	func displayCallToAction(){
		guard let img = CallToActionImageView(namedImage: "homeViewCallToAction", with: CGSize(width: 256.0, height: 44.0)) else {return}
		img.setMouseDownFunction({ _ in
			self.simulateEnterKey()
		})
		img.frame.origin = CGPoint(x: -275, y: view.frame.height - (44.0 + 110.0))
		view.addSubview(img)
		DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))){
			self.view.window?.makeFirstResponder(img)
		}
	}
	
	func simulateEnterKey(){
		preActionStyle()
		DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(300))){
			self.openSpace()
		}
	}
	
	private func resetSelection(){
		if let selectedItem = searchResultsCollection.item(at: 0) as? NiSearchResultViewItem{
			selectedItem.select()
		}
		selectedPosition = 0
		
		if(6 < searchResults.count){
			searchResultsCollection.scrollToItems(at: Set(arrayLiteral: IndexPath(item: selectedPosition, section: 0)), scrollPosition: .centeredVertically)
		}
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
		resultView.configureView(
			dataItem,
			position: indexPath.item,
			style: self.style,
			controller: self
		)
		
		resultView.deselect(skippRightSideElement: true)
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
		return getCollectionViewItemSize()
	}
	
	private func getCollectionViewItemSize() -> NSSize{
		if(self.style == .palette){
			return NSSize(width: 620.0, height: 47.0)
		}
		return NSSize(width: 648.0, height: 47.0)
	}

	override func cancelOperation(_ sender: Any?) {
		if searchField.stringValue.isEmpty,
		   let window = view.window,
		   window.responds(to: #selector(cancelOperation(_:))) {
			window.cancelOperation(sender)
		}
		searchField.stringValue = ""
		updateResultSet()
	}
	
	func getAnswerFromEve(){
		let question = searchField.stringValue
		searchField.stringValue = "Thinking ..."
		searchField.isEditable = false
		
		eveChatResultView = (NSView.loadFromNib(nibName: "EveChatView", owner: self) as! EveChatView)
		eveChatResultView?.questionLabel.stringValue = question
		
		eveChatResultView?.frame = searchResultsScrollContainer.frame
		eveChatResultView?.style()
		
		searchResultsScrollContainer.removeFromSuperview()
		view.addSubview(eveChatResultView!)
		chatShown = true
		
		Task{
			let mdResult = await Eve.instance.ask(question: question)
			eveChatResultView?.setText(markdown: mdResult)
			searchField.isEditable = true
			searchField.stringValue = ""
		}
	}
}
