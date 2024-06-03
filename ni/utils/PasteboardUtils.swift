//
//  PasteboardUtils.swift
//  ni
//
//  Created by Patrick Lukas on 31/5/24.
//

import Cocoa

enum NiPasteboardContent{
	case empty, image, txt
}

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
	
	func tryGetName() -> String?{
		if let pasteboardItem = self.pasteboardItems?[0]{
			if(pasteboardItem.types.contains(.URL)){
				if let urlBytes = pasteboardItem.data(forType: .URL){
					return getFileName(from: urlBytes)
				}
			}
			if(pasteboardItem.types.contains(.fileURL)){
				if let urlBytes = pasteboardItem.data(forType: .fileURL){
					return getFileName(from: urlBytes)
				}
			}
		}
		return nil
	}
	
	func tryGetFileURL() -> String?{
		if let pasteboardItem = self.pasteboardItems?[0]{
			if(pasteboardItem.types.contains(.fileURL)){
				if let urlBytes = pasteboardItem.data(forType: .fileURL){
					return String(decoding: urlBytes, as: UTF8.self)
				}
			}
		}
		return nil
	}
	
	func tryGetText() -> String?{
		if let pasteboardItem = self.pasteboardItems?[0]{
			if(pasteboardItem.types.contains(.string)){
				if let urlBytes = pasteboardItem.data(forType: .string){
					return String(decoding: urlBytes, as: UTF8.self)
				}
			}
		}
		return nil
	}
	
	func containsImgOrText() -> NiPasteboardContent{
		if let item = self.pasteboardItems?[0]{
			var containsText: Bool = false
			for t in item.types{
				switch(t){
					case .png:
						return .image
					case .tiff:
						return .image
					case .rtf, .html, .multipleTextSelection, .tabularText, .string:
						containsText = true
					default:
						break
				}
			}
			if containsText{
				return .txt
			}
		}
		return .empty
	}
	
	private func getFileName(from urlBytes: Data) -> String?{
		let urlStr = String(decoding: urlBytes, as: UTF8.self)
		if let url = URL(string: urlStr){
			if let fullName = url.pathComponents.last{
				if let lastDot = fullName.lastIndex(of: "."){
					return fullName.substring(to: lastDot)
				}
				return fullName
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
