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
	var tabPosition: Int?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		view.layer?.cornerRadius = 5
		view.layer?.cornerCurve = .continuous
		setBackground()
		
		let headView = self.view as! ContentFrameTabHeadView
		headView.parentControler = self
		
		tabHeadTitle.parentView = self.view
		tabHeadTitle.parentController = self
    }
	
	private func setBackground(){
		view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
	}
	
	private func removeBackground(){
		view.layer?.backgroundColor = NSColor(.transparent).cgColor
	}
	
	@MainActor
	func setIcon(_ img: NSImage?){
		self.image.image = img
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
		self.tabHeadTitle.isEditable = false
		self.tabHeadTitle.stringValue = title
	}
	
	func setURL(urlStr: String){
		self.tabHeadTitle.urlStr = urlStr
	}
	
	func loadWebsite(newURL: String) throws {
		guard let url = URL(string: newURL) else {throw NiUserInputError.invalidURL(url: newURL)}
		parentController?.loadWebsiteInSelectedTab(url)
	}
	
	func selectSelf(){
		parentController?.selectTab(at: tabPosition!)
		setBackground()
	}
	
	func deselectSelf(){
		removeBackground()
	}
}
