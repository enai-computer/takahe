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
		
		tabHeadTitle.parentView = self.view
		tabHeadTitle.parentController = self
		tabHeadTitle.layer?.cornerRadius = 5
		tabHeadTitle.layer?.cornerCurve = .continuous
		tabHeadTitle.focusRingType = .none
    }
	
	override func prepareForReuse() {
		//TODO: reset everything to default values
		tabPosition = -1
	}
	
	func setBackground(isSelected: Bool){
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
	func setTitle(_ title: String){
		self.tabHeadTitle.stringValue = title
		self.tabHeadTitle.isSelectable = false
	}
	
	func setURL(urlStr: String){
		self.tabHeadTitle.urlStr = urlStr
	}
	
	func loadWebsite(newURL: String) throws {
		guard let url = URL(string: newURL) else {throw NiUserInputError.invalidURL(url: newURL)}
		parentController?.loadWebsiteInSelectedTab(url)
	}
	
	func selectSelf(){
		parentController?.selectTab(at: tabPosition)
	}
	
	func redraw(){
		parentController?.niContentFrameView?.cfTabHeadCollection.reloadData()
	}
}
