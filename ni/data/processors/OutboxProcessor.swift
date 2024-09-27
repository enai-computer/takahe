//
//  OutboxProcessor.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//

import Foundation
import SQLite

class OutboxProcessor{
	
	struct FailedSendCounter{
		var count: Int = 0
		var triedLast: Date?
	}
	
	private let client: MaraeClient
	private var failedSendCounter: FailedSendCounter
	
	init() {
		self.client = MaraeClient()
		self.failedSendCounter = FailedSendCounter()
	}
	
	func run(withDelayInMs: Int? = nil){
		guard UserSettings.shared.onlineSync else {return}
		Task{
			while( await processRecordInTable() ) {
				if let delay = withDelayInMs{
					try await Task.sleep(for: .milliseconds(delay))
				}
			}
		}
	}
	
	private func processRecordInTable() async -> Bool{
		guard allowSending() else {return false}
		
		let record = OutboxTable.getNextMessage()
		guard let (id, type, record) = record else {return false}
		
		if(type == .PUT){
			do{
				let successful = try await client.sendRecord(record: record)
				if(successful){
					succeededSending(message: id)
				}else{
					failedSending(message: id)
				}
			}catch{
				print(error)
				failedSending(message: id)
			}
		}else if(type == .DELETE){
			do{
				if(try await client.deleteRecord(record: record)){
					succeededSending(message: id)
				}else{
					failedSending(message: id)
				}
			}catch{
				print(error)
				failedSending(message: id)
			}
		}else{
			//killing the potential for an endless loop of an undefined object
			OutboxTable.delete(id: id)
		}
		return true
	}
	
	private func allowSending() -> Bool{
		//TODO: tech debt,- needs to be cleaned up. Find a good library implementation
		if(5 < failedSendCounter.count && failedSendCounter.triedLast?.timeIntervalSinceNow ?? 31.0 > -30.0 ){
			if(failedSendCounter.triedLast == nil){
				failedSendCounter.triedLast = Date.now
			}
			return false
		}
		return true
	}
	
	private func succeededSending(message id: UUID){
		OutboxTable.delete(id: id)
		
		failedSendCounter.count = 0
		failedSendCounter.triedLast = nil
	}
	
	private func failedSending(message id: UUID){
		OutboxTable.increaseFailureCount(for: id)
		failedSendCounter.count += 1
		failedSendCounter.triedLast = Date.now
	}
	
	func backfillCloudDB(){
//		let webContent = fetchAllWebContent()
//		for content in webContent {
//			OutboxTable.insertMessage(
//				eventType: .PUT,
//				objectID: content.0,
//				objectType: .webContent,
//				message: content.1
//			)
//		}
//		print("[INFO]: finished creating backfill messages. Created \(webContent.count) messages")
//		let noteMessages = fetchAllNotes()
//		for noteM in noteMessages{
//			OutboxTable.insertMessage(
//				eventType: .PUT,
//				objectID: noteM.0,
//				objectType: .note,
//				message: noteM.1
//			)
//		}
//		print("[INFO]: finished creating note backfill messages. Created \(noteMessages.count) note messages")
//		
		self.run(withDelayInMs: 1)
	}
	
	private func fetchAllWebContent() -> [(UUID, WebContentMessage)]{
		var results: [(UUID, WebContentMessage)] = []
		do{
			let q = ContentTable.table
				.join(
					CachedWebTable.table,
					on: ContentTable.id == CachedWebTable.table[CachedWebTable.contentId]
				)
				.join(
					DocumentIdContentIdTable.table,
					on: DocumentIdContentIdTable.table[DocumentIdContentIdTable.contentId] == ContentTable.id
				)
			
			for record in try Storage.instance.spacesDB.prepare(q){
				let docId = try record.get(ContentTable.id)
				let webM = WebContentMessage(
					spaceId: try record.get(DocumentIdContentIdTable.documentId),
					title: try record.get(ContentTable.title),
					url: try record.get(CachedWebTable.url),
					updatedAt: try record.get(CachedWebTable.table[CachedWebTable.updatedAt])
				)
				results.append((docId, webM))
			}
		}catch{
			print(error)
		}
		return results
	}
	
	private func fetchAllNotes() -> [(UUID, NoteMessage)]{
		var results: [(UUID, NoteMessage)] = []
		
		do{
			let q = ContentTable.table
				.join(
					NoteTable.table,
					on: NoteTable.table[NoteTable.contentId] == ContentTable.id
				)
				.join(
					DocumentIdContentIdTable.table,
					on: DocumentIdContentIdTable.table[DocumentIdContentIdTable.contentId] == ContentTable.id
				)
			for record in try Storage.instance.spacesDB.prepare(q){
				let docId = try record.get(ContentTable.id)
				let webM = NoteMessage(
					spaceId: try record.get(DocumentIdContentIdTable.documentId),
					title: try record.get(ContentTable.title),
					content: try record.get(NoteTable.rawText) ?? "",
					updatedAt: try record.get(NoteTable.table[NoteTable.updatedAt])
				)
				results.append((docId, webM))
			}
		}catch{
			print(error)
		}
		
		return results
	}
}

