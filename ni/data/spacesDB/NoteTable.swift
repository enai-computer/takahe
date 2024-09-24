//
//  NoteTable.swift
//  ni
//
//  Created by Patrick Lukas on 24/5/24.
//

import Cocoa
import SQLite

class NoteTable{
	
	static let table = Table("user_notes")
	static let contentId = SQLite.Expression<UUID>("content_id")
	static let updatedAt = SQLite.Expression<Double>("updated_at")
	static let rawText = SQLite.Expression<String?>("raw_text")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(contentId, primaryKey: true)
			t.column(updatedAt)
			t.column(rawText)
			t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
		})
	}
	
	static func upsert(documentId: UUID, id: UUID, title: String?, rawText: String){
		ContentTable.upsert(id: id, type: "note", title: title)
		
		do{
			let updatedAt = Date.now.timeIntervalSince1970
			try Storage.instance.spacesDB.run(
				table.upsert(
					self.contentId <- id,
					self.rawText <- rawText,
					self.updatedAt <- updatedAt,
					onConflictOf: self.contentId
				)
			)
			OutboxTable.insertNote(
				objId: id,
				message: NoteMessage(
					spaceId: documentId,
					title: title,
					rawText: rawText,
					updatedAt: updatedAt
				)
			)
			Storage.instance.outboxProcessor.run()
		}catch{
			print("failed to insert into note table")
		}
		DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
	}
	
	static func fetchNote(contentId: UUID) -> NoteDataModel{
		do{
			for record in try Storage.instance.spacesDB.prepare(
				table.join(ContentTable.table, on: self.contentId==ContentTable.id)
					.select(rawText, ContentTable.title).filter(self.contentId == contentId)
			){
				return try NoteDataModel(
					title: record.get(ContentTable.title) ?? "",
					rawText: record.get(self.rawText) ?? ""
				)
			}
		}catch{
			debugPrint("failed to fetch note for content \(contentId) with error: \(error)")
		}
		return NoteDataModel(title: "", rawText: "")
	}
}

struct NoteDataModel{
	let title: String
	let rawText: String
}
