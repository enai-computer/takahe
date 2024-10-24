//
//  EveChatTable.swift
//  ni
//
//  Created by Patrick Lukas on 23/10/24.
//

import SQLite
import Foundation

class EveChatTable{
	
	static let table = Table("eve_chat")
	static let contentId = SQLite.Expression<UUID>("content_id")
	static let messages = SQLite.Expression<String>("messages")
	static let updatedAt = SQLite.Expression<Double>("updated_at")

	static func create(db: Connection) throws {
		try db.run(table.create(ifNotExists: true){ t in
			t.column(contentId, primaryKey: true)
			t.column(messages)
			t.column(updatedAt)
			t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
		})
	}
	
	static func upsert(id: UUID, messages: String){
		do{
			try Storage.instance.spacesDB.run(
				table.upsert(
					self.contentId <- id,
					self.messages <- messages,
					self.updatedAt <- Date.now.timeIntervalSince1970,
					onConflictOf: self.contentId
				)
			)
		}catch{
			print("Failed to insert into CachedWebTable")
		}
	}
	
	static func fetchMessageHistory(contentId: UUID) -> String?{
		do{
			for record in try Storage.instance.spacesDB.prepare(
				table.select(messages).filter(self.contentId == contentId)
			){
				return try record.get(messages)
			}
		}catch{
			debugPrint("failed to fetch message history for content \(contentId) with error: \(error)")
		}
		return nil
	}
}
