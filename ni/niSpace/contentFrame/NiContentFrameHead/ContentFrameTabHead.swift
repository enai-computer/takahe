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
	@IBOutlet var tabHeadTitle: NSTextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		view.layer?.cornerRadius = 5
		view.layer?.cornerCurve = .continuous
		view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
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
	
}
