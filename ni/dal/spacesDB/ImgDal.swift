//
//  ImgDal.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa
import SQLite

class ImgDal{
	
	static func insert(documentId: UUID, id: UUID, title: String?, img: NSImage, source: String?) {
		if(ContentTable.contains(id: id)){
			return
		}
	
		let fUrl: URL = Storage.instance.genFileUrl(for: id, ofType: .spaceImg)
		if(writeImgToDisk(fUrl: fUrl, img: img)){
			ContentTable.upsert(id: id, type: "img", title: title, fileUrl: fUrl.absoluteString, source: source)
			DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
		}else{
			print("Failed to write image to disk with Title: \(title ?? "")")
		}
	}

	/** returns title, image, sourceURL
	 
	 */
	static func fetchImgWMetaData(id: UUID, callback: ((NSImage)->Void)? = nil) -> (String?, NSImage?, String?)? {
		let (urlString, title, sourceUrl) = ContentTable.fetchURLTitleSource(for: id) ?? (nil, nil, nil)
		if(urlString == nil){return nil}
		
		if let fUrl = URL(string: urlString!){
			return (title, fetchImgFromDisk(fUrl), sourceUrl)
		}
		
		return nil
	}
	
	static func deleteImg(id: UUID){
		//TODO: impelement me
	}
}
