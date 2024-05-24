//
//  ContentTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import SQLite
import Cocoa

class ContentTable{
    
    static let table = Table("content")
    static let id = Expression<UUID>("id")
    static let title = Expression<String?>("title")
    static let type = Expression<String>("type")
    static let updatedAt = Expression<Double>("updated_at")
    static let localStorageLocation = Expression<String?>("local_storage_location")
    static let refCounter = Expression<Int>("ref_counter")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(type)
            t.column(updatedAt)
            t.column(localStorageLocation)
            t.column(refCounter, defaultValue: 1)
        })
    }
    
    static func insert(id: UUID, type: String, title: String?){
        do{
            try Storage.db.spacesDB.run(
                table.insert(
                    self.id <- id,
                    self.title <- title,
                    self.type <- type,
                    self.updatedAt <- Date().timeIntervalSince1970
                )
            )
        }catch{
            print("Failed to insert into ContentTable")
        }
    }
	
	static func delete(id: UUID){
		do{
			let record = table.filter(self.id == id)
			try Storage.db.spacesDB.run(record.delete())
		} catch {
			print("Failed to delete content from the content table with id: \(id)")
		}
	}
}
