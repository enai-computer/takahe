//
//  NiDocControllerCache.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Cocoa

class NiDocControllerCache{

	//TODO: create logic to make this dynamic based on available memory
	private let maxCachedNiDocControllers: Int = 3
	private var leastRecentlyUsedDocumentKeys: [UUID] = []
	private var cachedNiDocs: [UUID: NiSpaceDocumentController] = [:]
	
	func addToCache(id: UUID, controller: NiSpaceDocumentController){
		if(cachedNiDocs[id] != nil){
			leastRecentlyUsedDocumentKeys.removeAll{$0 == id}
			leastRecentlyUsedDocumentKeys.insert(id, at: 0)
			return
		}
		leastRecentlyUsedDocumentKeys.insert(id, at: 0)
		cachedNiDocs[id] = controller
		
		if(maxCachedNiDocControllers < leastRecentlyUsedDocumentKeys.count){
			removeLeastRecentlyUsed()
		}
	}
	
	func getIfCached(id: UUID) -> NiSpaceDocumentController? {
		return cachedNiDocs[id]
	}
	
	private func removeLeastRecentlyUsed(){
		if let idToRemove = leastRecentlyUsedDocumentKeys.popLast(){
			if let oldDoc = cachedNiDocs.removeValue(forKey: idToRemove){
				deinitOldDocument(oldDoc)
			}
		}
	}
	
	private func deinitOldDocument(_ doc: NiSpaceDocumentController?){
		guard doc != nil else{return}
		for conFrame in doc!.myView.contentFrameControllers{
			conFrame.deinitSelf()
		}
		doc?.removeFromParent()
	}
}
