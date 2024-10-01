//
//  GroupTable.swift
//  ni
//
//  Created by Patrick Lukas on 1/10/24.
//

import Foundation
import SQLite

enum GroupType: String, Codable{
	case leaf
}

class GroupTable{
	static let table = Table("group")
	static let id = SQLite.Expression<UUID>("id")
	static let name = SQLite.Expression<String>("name")
	static let type = SQLite.Expression<String>("type")
	static let createdAt = SQLite.Expression<Double>("created_at")
	static let updatedAt = SQLite.Expression<Double>("updated_at")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(id, primaryKey: true)
			t.column(name)
			t.column(type)
			t.column(createdAt)
			t.column(updatedAt)
		})
	}
	
	static func updateName(id: UUID, name: String){
		do{
			let rowToUpdate = table.filter(self.id == id)
			let updatedRows = try Storage.instance.spacesDB.run(
				rowToUpdate.update(
					self.name <- name,
					self.updatedAt <- Date.now.timeIntervalSince1970
				)
			)
			if(updatedRows != 1){
				print("Failed to update the name. Updated \(updatedRows) rows.")
			}
		}catch{
			print("Failed to update the name")
		}
	}
	
	static func createRecord(with id: UUID, name: String){
		do{
			let dateNow = Date.now.timeIntervalSince1970
			try Storage.instance.spacesDB.run(
				table.insert(
					self.id <- id,
					self.name <- name,
					self.type <- GroupType.leaf.rawValue,
					self.updatedAt <- dateNow,
					self.createdAt <- dateNow
				)
			)
		}catch{
			print(error)
		}
	}
}
