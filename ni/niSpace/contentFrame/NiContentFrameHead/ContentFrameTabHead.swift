//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 5/4/24.
//

import Cocoa
import FaviconFinder

class ContentFrameTabHead: NSCollectionViewItem {

	@IBOutlet var image: NSImageView!
	@IBOutlet var tabHeadTitle: ContentFrameTabHeadTextNode!
	
	var parentController: ContentFrameController?
	var tabPosition: Int = -1
	
	override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		view.layer?.cornerRadius = 5
		view.layer?.cornerCurve = .continuous
		
		let headView = self.view as! ContentFrameTabHeadView
		headView.parentControler = self
		
		tabHeadTitle.parentController = self
		tabHeadTitle.layer?.cornerRadius = 5
		tabHeadTitle.layer?.cornerCurve = .continuous
		tabHeadTitle.focusRingType = .none
    }
	
	override func prepareForReuse() {
		//TODO: reset everything to default values
		tabPosition = -1
	}
	
	func configureView(parentController: ContentFrameController, tabPosition: Int, viewModel: TabHeadViewModel){
		self.tabPosition = tabPosition
		self.parentController = parentController
		
		self.setText(viewModel)
		self.setIcon(urlStr: viewModel.url)
		
		self.setBackground(isSelected: viewModel.isSelected)
	}
	
	private func setBackground(isSelected: Bool){
		if(isSelected){
			view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
		}else{
			view.layer?.backgroundColor = NSColor(.transparent).cgColor
		}
		
	}
	
	@MainActor
	func setIcon(_ img: NSImage?){
		self.image.image = img
		self.image.alphaValue = 1.0
	}
    
	func setIcon(urlStr: String){
		//FIXME: reloads Website to get FavIcon every time we redraw tabs
		Task {
			do{
				let img = try await fetchFavIcon(url: URL(string: urlStr)!)
				setIcon(img)
			}catch{
				debugPrint(error)
			}
		}
	}
	
	private func fetchFavIcon(url: URL) async throws -> NSImage?{
		return try await FaviconFinder(url: url)
				.fetchFaviconURLs()
				.download()
				.largest().image?.image
	}
	
	@MainActor
	private func setText(_ viewModel: TabHeadViewModel){
		if(viewModel.inEditingMode){
			self.tabHeadTitle.enableEditing(urlStr: viewModel.url)
		}else{
			self.tabHeadTitle.disableEditing(title: viewModel.title)
		}
	}
	
	func loadWebsite(newURL: String) throws {
		guard let url = URL(string: newURL) else {throw NiUserInputError.invalidURL(url: newURL)}
		parentController?.loadWebsiteInSelectedTab(url)
	}
	
	func selectSelf(mouseDownEvent: NSEvent? = nil){
		parentController?.selectTab(at: tabPosition, mouseDownEvent: mouseDownEvent)
	}
	
	func startEditMode(){
		parentController?.editTabUrl(at: tabPosition)
	}
	
	func endEditMode(){
		parentController?.endEditingTabUrl(at: tabPosition)
	}
	
	func redraw(){
		parentController?.niContentFrameView?.cfTabHeadCollection.reloadData()
	}
}
