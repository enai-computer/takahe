//
//  PasteboardUtils.swift
//  ni
//
//  Created by Patrick Lukas on 31/5/24.
//

import Cocoa

extension NSPasteboard{
	
	/** returns nil if no image or fileURL to an image was found on pasteboard.
	 
	 */
	func getImage() -> NSImage? {
		if let pasteboardItem = self.pasteboardItems?[0]{
			if let img = loadImg(from: pasteboardItem){
				return img
			}
		}
		return nil
	}
	
	private func loadImg(from item: NSPasteboardItem) -> NSImage?{
		let type = getPasteboardItemType(for: item)
		if(type == .png || type == .tiff){
			return NSImage(pasteboard: self)
		}else if(type == .fileURL){
			if let fileUrl = getImgfileURL(from: item){
				return NSImage(contentsOf: fileUrl)
			}
		}
		return nil
	}
	
	private func getImgfileURL(from item: NSPasteboardItem) -> URL?{
		if let pasteBoardFileUrl = item.data(
			forType: NSPasteboard.PasteboardType.fileURL
		){
			let fileStr = String(decoding: pasteBoardFileUrl, as: UTF8.self)
			if(hasImgExtension(fileStr)){
				let fileUrl = URL(string: fileStr)
				return fileUrl
			}
		}
		return nil
	}
	
	private func getPasteboardItemType(for item: NSPasteboardItem) -> NSPasteboard.PasteboardType?{
		//order is not garanteed, we'd prefer png or tiff pasteboard over fileURL
		var containsFileURL: Bool = false
		for t in item.types{
			switch(t){
				case .fileURL:
					containsFileURL = true
				case .png:
					return .png
				case .tiff:
					return .tiff
				default:
					break
			}
		}
		if(containsFileURL){
			return .fileURL
		}
		return nil
	}
}
