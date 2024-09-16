//
//  NiAsyncImgView.swift
//  ni
//
//  Created by Patrick Lukas on 16/9/24.
//

import Cocoa

class NiAsyncImgView: NSView{
	
	private var image: NSImage?
	
	func loadFavIcon(from urlStr: String?) {
		guard let url: String = urlStr else {return}

		Task{ [weak self] in
				guard let image = await FaviconProvider.instance.fetchIcon(url) else {
					return
				}

			DispatchQueue.main.async {
				self?.image = image
				self?.needsDisplay = true
			}
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let image = self.image else {
			return
		}
		image.draw(in: bounds)
	}	
}
