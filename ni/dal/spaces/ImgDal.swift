//
//  ImgDal.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa
import SQLite

class ImgDal{
	
	static func insert(documentId: UUID, id: UUID, title: String?, img: NSImage) async {
		if(ContentTable.contains(id: id)){
			return
		}
		
		let imgRep = img.representations[0] as? NSBitmapImageRep
		if let rawImg = imgRep?.representation(using: .png, properties:[:]){
			let fUrl: URL = Storage.instance.genFileUrl(for: id)
			do{
				try rawImg.write(to: fUrl, options: .withoutOverwriting)
				ContentTable.upsert(id: id, type: "img", title: title, fileUrl: fUrl.absoluteString)
				DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
			}catch{
				print(error)
			}
		}
	}

	static func fetchImg(id: UUID, callback: ((NSImage)->Void)) async {
		if let urlString = ContentTable.fetchURL(for: id){
			if let fUrl = URL(string: urlString){
				if(fUrl.isFileURL){
					if let img = NSImage(contentsOf: fUrl){
						callback(img)
					}
				}
			}
		}
	}
}
