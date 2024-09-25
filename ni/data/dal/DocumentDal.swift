//
//  DocumentDal.swift
//  ni
//
//  Created by Patrick Lukas on 24/9/24.
//
import Foundation


class DocumentDal{
	
	static func persistDocument(spaceId: UUID, document tab: TabViewModel){
		if(tab.type == .web){
			let url = getTabUrl(for: tab)
			persistWebcontent(spaceId: spaceId, id: tab.contentId, title: tab.title, url: url)
		}
		if(tab.type == .note){
			guard let txt = tab.noteView?.getText() else {return}
			let title = tab.noteView?.getTitle()
			persistNote(spaceId: spaceId, id: tab.contentId, title: title, rawText: txt)
		}
		if(tab.type == .img){
			if let img = tab.imgView?.image{
				ImgDal.insert(documentId: spaceId, id: tab.contentId, title: tab.title, img: img, source: tab.source)
			}
		}
		if(tab.type == .pdf){
			if let pdfDoc = tab.pdfView?.document{
				PdfDal.insert(documentId: spaceId, id: tab.contentId, title: tab.title, pdf: pdfDoc, source: tab.source)
			}
		}
	}
	
	static func deleteDocument(documentId: UUID, docType: TabContentType){
		ContentTable.delete(id: documentId)
		guard let type = resolveType(docType) else {return}
		guard UserSettings.shared.onlineSync else {return}
		
		OutboxTable.insert(eventType: .DELETE, objectID: documentId, objectType: type, message: "")
		Storage.instance.outboxProcessor.run()
	}
	
	private static func resolveType(_ docType: TabContentType) -> RestObjectType?{
		switch (docType){
			case .note:
				return .note
			case .pdf:
				return .pdf
			case .web:
				return .webContent
			default:
				return nil
		}
	}
	
	private static func persistWebcontent(
		spaceId: UUID,
		id: UUID,
		title: String?,
		url:String
	){
		var updatedRecord = false
		let storedRec = CachedWebTable.fetchCachedWebsite(contentId: id)
		if (storedRec?.title != title || storedRec?.title == nil){
			ContentTable.upsert(id: id, type: "web", title: title)
			updatedRecord = true
		}
		if(storedRec?.url != url){
			CachedWebTable.upsert(documentId: spaceId, id: id, title: title, url: url)
			updatedRecord = true
		}
		
		if(updatedRecord && UserSettings.shared.onlineSync){
			OutboxTable.insertMessage(
				eventType: .PUT,
				objectID: id,
				objectType: .webContent,
				message: WebContentMessage(
					spaceId: spaceId,
					title: title,
					url: url,
					updatedAt: Date.now.timeIntervalSince1970
				)
			)
		}
		
		DocumentIdContentIdTable.insert(documentId: spaceId, contentId: id)
	}
	
	private static func persistNote(spaceId: UUID, id: UUID, title: String?, rawText: String){
		var updatedRecord = false
		let storedRec = NoteTable.fetchNote(contentId: id)
		
		if (storedRec?.title != title){
			ContentTable.upsert(id: id, type: "note", title: title)
			updatedRecord = true
		}
		if(storedRec?.rawText != rawText){
			NoteTable.upsert(documentId: spaceId, id: id, title: title, rawText: rawText)
			updatedRecord = true
		}
		if(updatedRecord && UserSettings.shared.onlineSync){
			OutboxTable.insertMessage(
				eventType: .PUT,
				objectID: id,
				objectType: .note,
				message: NoteMessage(
					spaceId: spaceId,
					title: title,
					content: rawText,
					updatedAt: Date.now.timeIntervalSince1970
				)
			)
		}
		DocumentIdContentIdTable.insert(documentId: spaceId, contentId: id)
	}
	
	private static func getTabUrl(for tab: TabViewModel) -> String{
		if(tab.state == .loaded){
			return tab.webView?.getCurrentURL() ?? tab.content
		}
		return tab.content
	}
}
