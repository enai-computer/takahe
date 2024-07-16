//
//  NiPdfView.swift
//  ni
//
//  Created by Patrick Lukas on 2/7/24.
//

import Cocoa
import PDFKit

class NiPdfView: PDFView, CFContentItem, CFContentSearch{
	var owner: ContentFrameController?
	
	// overlays own view to deactivate clicks and visualise deactivation state
	private var overlay: NSView?
	private var zoomLevel: Int = 7
	var nextFindAvailable: Bool = true
	var prevFindAvailable: Bool = true
	var searchPanel: NiWebViewFindPanel?
	var searchResults: [PDFSelection]?
	var selectedResult: Int = -1
	
	var viewIsActive: Bool = true
	
	init(owner: ContentFrameController, frame: NSRect, document doc: PDFDocument) {
		self.owner = owner
		super.init(frame: frame)
		
		self.document = doc
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		viewIsActive = true
	}
	
	@discardableResult
	func setInactive() -> FollowOnAction {
		overlay = cfOverlay(frame: self.frame, nxtResponder: owner!.view)
		addSubview(overlay!)
		window?.makeFirstResponder(overlay)
		viewIsActive = false
		return .nothing
	}
	
	@IBAction func performFindPanelAction(_ sender: NSMenuItem) {
		guard searchPanel == nil else{return}
		
		//needs to be ordered this way, otherwise the action images will be null
		searchPanel = NiWebViewFindPanel()
		addSubview(searchPanel!.view)
		searchPanel!.setParentViewItem(self)
		searchPanel?.resetOrigin(self.frame.size)
	}
	
	@IBAction func performFindNext(_ sender: NSMenuItem){
		performFindNext()
	}
	
	func performFindNext(){
		if (searchResults == nil || searchResults!.isEmpty){
			guard searchPanel != nil else {return}
			performFind(searchPanel!.searchField.stringValue, backwards: false)
			return
		}
		selectedResult += 1
		gotoSelectedResult()
	}
	
	@IBAction func performFindPrevious(_ sender: NSMenuItem){
		performFindPrevious()
	}
	
	func performFindPrevious(){
		if (searchResults == nil){
			guard searchPanel != nil else {return}
			performFind(searchPanel!.searchField.stringValue, backwards: true)
			return
		}
		selectedResult -= 1
		gotoSelectedResult()
	}
	
	private func performFind(_ search: String, backwards: Bool){
		searchResults = self.document?.findString(search, withOptions: [.caseInsensitive])
		
		if(searchResults?.count == 0){
			noResults()
			return
		}
		selectedResult = 0
		highlightedSelections = searchResults
		gotoSelectedResult()
	}
	
	private func gotoSelectedResult(){
		guard let results: [PDFSelection] = searchResults else {
			noResults()
			return
		}
		if(0 <= selectedResult && selectedResult < results.count){
			go(to: results[selectedResult])
		}
		if(selectedResult == 0){
			prevFindAvailable = false
		}else{
			prevFindAvailable = true
		}
		if(selectedResult == results.count - 1){
			nextFindAvailable = false
		}else{
			nextFindAvailable = true
		}
	}

	private func noResults(){
		prevFindAvailable = false
		nextFindAvailable = false
		highlightedSelections = []
	}
	
	func resetSearchAvailability() {
		prevFindAvailable = true
		nextFindAvailable = true
		highlightedSelections = []
	}
	
	func spaceClosed() {
		
	}
	
	func spaceRemovedFromMemory() {
		self.owner = nil
	}
}
