//
//  OutboxTable.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//

import Foundation
import SQLite

class OutboxTable{
	
	private static let tableName = "spacesSyncOutbox"
	static let table = Table(tableName)
	static let id = SQLite.Expression<UUID>("id")
	static let createdAt = SQLite.Expression<Double>("created_at")
	static let eventType = SQLite.Expression<String>("event_type")
	static let objectID = SQLite.Expression<UUID>("object_id")
	static let objectType = SQLite.Expression<String>("object_type")
	static let message = SQLite.Expression<String>("message")
	static let failureCount = SQLite.Expression<Int>("failure_count")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(id, primaryKey: true)
			t.column(eventType)
			t.column(objectType)
			t.column(objectID)
			t.column(message)
			t.column(createdAt)
			t.column(failureCount)
		})
	}
	
	@discardableResult
	static func insert(eventType: RestEventType, objectID: UUID, objectType: RestObjectType, message: String) -> UUID?{
		do{
			let messageId = UUID()
			try Storage.instance.cacheDB.run(
				table.insert(
					self.id <- messageId,
					self.createdAt <- Date.now.timeIntervalSince1970,
					self.eventType <- eventType.rawValue,
					self.objectID <- objectID,
					self.objectType <- objectType.rawValue,
					self.message <- message,
					self.failureCount <- 0
				)
			)
			return messageId
		}catch{
			print("failed to insert into Outbox table. May occur data loss, with following error: \(error)")
		}
		return nil
	}
	
	/** returns the record with the lowest failure count that has been in this table the longest
	 */
	static func getNextMessage() -> (UUID, RestEventType, OutboxMessage)?{
		do{
			for record in try Storage.instance.cacheDB.prepare(
				table.order(failureCount.asc, createdAt.asc).limit(1)
			){
				let recId: UUID = try record.get(id)
				let eventType = RestEventType(rawValue: try record.get(eventType))
				let outboxMessage = OutboxMessage(
					objectId: try record.get(objectID),
					objectType: RestObjectType(rawValue: try record.get(objectType))!,
					message: try record.get(message)
				)
				return ((recId, eventType , outboxMessage) as! (UUID, RestEventType, OutboxMessage))
			}
		}catch{
			print("\(error)")
		}
		return nil
	}
	
	static func delete(id: UUID){
		do{
			let record = table.filter(self.id == id)
			try Storage.instance.cacheDB.run(record.delete())
		} catch {
			print("Failed to delete message from the outbox table with id: \(id)")
		}
	}
	
	@discardableResult
	static func insertMessage(eventType: RestEventType, objectID: UUID, objectType: RestObjectType, message: Codable) -> UUID?{
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		do{
			let jsonData = try jsonEncoder.encode(message)
			guard let jsonStrMessage = String(data: jsonData, encoding: .utf8) else{return nil}
			return OutboxTable.insert(
				eventType: eventType,
				objectID: objectID,
				objectType: objectType,
				message: jsonStrMessage
			)
		}catch{
			print(error)
		}
		return nil
	}
	
	static func increaseFailureCount(for id: UUID){
		do{
			let fNrName = failureCount.template
			try Storage.instance.cacheDB.execute("UPDATE \(tableName) SET \(fNrName) = \(fNrName) + 1 WHERE \(self.id.template) = '\(id.uuidString)';")
		}catch{
			print(error)
		}
	}
}
