//
//  DocumentDal.swift
//  ni
//
//  Created by Patrick Lukas on 24/9/24.
//
import Foundation


class DocumentDal{
	
	static func persistGroup(id: UUID?, name: String?, spaceId: UUID){
		guard name != nil && name?.isEmpty == false else {return}
		guard let groupId = id else {return}
		
		let storedName = GroupTable.fetchName(id: groupId)
		if(storedName == nil){
			GroupTable.createRecord(with: groupId, name: name!)
			DocumentIdGroupIdTable.insert(documentId: spaceId, groupId: groupId)
		}else if(storedName != name){
			GroupTable.updateName(id: groupId, name: name!)
		}
	}
	
	static func persistDocument(spaceId: UUID, document tab: TabViewModel, groupId: UUID?){
		if(tab.type == .web){
			let url = getTabUrl(for: tab)
			persistWebcontent(spaceId: spaceId, id: tab.contentId, title: tab.title, url: url, groupId: groupId)
		}
		if(tab.type == .note || tab.type == .sticky){
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
		if(tab.type == .eveChat){
			//creating a reference to the webview, so it doesn't get removed from memory before we fetched the messages
			let eveWebview = tab.webView
			Task{
				if let eveMessages = await eveWebview?.fetchEveMessages() as? String{
					persistEveChat(spaceId: spaceId, id: tab.contentId, title: tab.title, messages: eveMessages, groupId: groupId)
				}
			}
		}
	}
	
	static func deleteDocument(documentId: UUID, docType: TabContentType){
		ContentTable.delete(id: documentId)
		guard let type = resolveType(docType) else {return}
		guard UserSettings.shared.onlineSync else {return}
		
//		OutboxTable.insert(eventType: .DELETE, objectID: documentId, objectType: type, message: "")
//		Storage.instance.outboxProcessor.run()
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
		title: String,
		url: String,
		groupId: UUID?
	){
		var updatedRecord = false
		let storedRec = CachedWebTable.fetchCachedWebsite(contentId: id)
		if (storedRec?.title != title || storedRec?.title == nil){
			ContentTable.upsert(id: id, type: ContentTableRecordType.web, title: title)
			updatedRecord = true
		}
		if(storedRec?.url != url){
			CachedWebTable.upsert(documentId: spaceId, id: id, title: title, url: url)
			updatedRecord = true
		}
		
		if(false){ 	//updatedRecord && UserSettings.shared.onlineSync
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
		
		if let gId = groupId{
			GroupIdContentIdTable.insert(groupId: gId, contentId: id)
		}
	}

	private static func persistEveChat(
		spaceId: UUID,
		id: UUID,
		title: String,
		messages: String,
		groupId: UUID?
	){
		let storedRec = CachedWebTable.fetchCachedWebsite(contentId: id)
		if (storedRec?.title != title || storedRec?.title == nil){
			ContentTable.upsert(id: id, type: ContentTableRecordType.web, title: title)
		}

		EveChatTable.upsert(id: id, messages: messages)
		DocumentIdContentIdTable.insert(documentId: spaceId, contentId: id)
		
		if let gId = groupId{
			GroupIdContentIdTable.insert(groupId: gId, contentId: id)
		}
	}
	
	private static func persistNote(spaceId: UUID, id: UUID, title: String?, rawText: String){
		var updatedRecord = false
		let storedRec = NoteTable.fetchNote(contentId: id)
		
		if (storedRec?.title != title){
			ContentTable.upsert(id: id, type: ContentTableRecordType.note, title: title)
			updatedRecord = true
		}
		if(storedRec?.rawText != rawText){
			NoteTable.upsert(documentId: spaceId, id: id, title: title, rawText: rawText)
			updatedRecord = true
		}
		if(false){ //updatedRecord && UserSettings.shared.onlineSync
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
