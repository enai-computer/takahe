//
//  ImgDal.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa
import SQLite

class ImgDal{
	
	static func insert(documentId: UUID, id: UUID, title: String?, img: NSImage) {
		if(ContentTable.contains(id: id)){
			return
		}
	
		let fUrl: URL = Storage.instance.genFileUrl(for: id, ofType: .spaceImg)
		if(writeImgToDisk(fUrl: fUrl, img: img)){
			ContentTable.upsert(id: id, type: "img", title: title, fileUrl: fUrl.absoluteString)
			DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
		}else{
			print("Failed to write image to disk with Title: \(title ?? "")")
		}
	}

	static func fetchImg(id: UUID, callback: ((NSImage)->Void)? = nil) -> NSImage? {
		if let urlString = ContentTable.fetchURL(for: id){
			if let fUrl = URL(string: urlString){
				return fetchImgFromDisk(fUrl)
			}
		}
		return nil
	}
}
