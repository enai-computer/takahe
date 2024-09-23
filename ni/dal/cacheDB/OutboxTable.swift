//
//  OutboxTable.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//

import Foundation
import SQLite

class OutboxTable{
	
	static let table = Table("spacesSyncOutbox")
	static let id = SQLite.Expression<UUID>("id")
	static let createdAt = SQLite.Expression<Double>("created_at")
	static let eventType = SQLite.Expression<String>("event_type")
	static let objectID = SQLite.Expression<UUID>("object_id")
	static let objectType = SQLite.Expression<String>("object_type")
	static let message = SQLite.Expression<String>("message")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(id, primaryKey: true)
			t.column(createdAt)
			t.column(eventType)
			t.column(objectID)
			t.column(objectType)
			t.column(message)
		})
	}
	
	static func insert(eventType: RestEventType, objectID: UUID, objectType: RestObjectType, message: String) -> UUID{
		let id = UUID()
		do{
			try Storage.instance.cacheDB.run(
				table.insert(
					self.id <- id,
					self.createdAt <- Date.now.timeIntervalSince1970,
					self.eventType <- eventType.rawValue,
					self.objectID <- objectID,
					self.objectType <- objectType.rawValue,
					self.message <- message
				)
			)
		}catch{
			print("failed to insert into Outbox table. May occur data loss, with following error: \(error)")
		}
		return id
	}
	
	static func getMessages(first: Int) -> [(UUID, RestEventType, OutboxMessage)]{
		//TODO: return array with the first x elements - id, type, objID, objType, message
		return []
	}
	
	static func delete(id: UUID){
		do{
			let record = table.filter(self.id == id)
			try Storage.instance.cacheDB.run(record.delete())
		} catch {
			print("Failed to delete message from the outbox table with id: \(id)")
		}
	}
}
