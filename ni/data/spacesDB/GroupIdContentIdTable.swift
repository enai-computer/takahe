//
//  GroupIdContentIdTable.swift
//  ni
//
//  Created by Patrick Lukas on 1/10/24.
//

import Foundation
import SQLite

class GroupIdContentIdTable{
	
	static let table = Table("group_id_content_id")
	static let contentId = SQLite.Expression<UUID>("content_id")
	static let groupId = SQLite.Expression<UUID>("group_id")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(groupId)
			t.column(contentId)
			t.primaryKey(groupId, contentId)
			t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
			t.foreignKey(groupId, references: GroupTable.table, GroupTable.id, delete: .cascade)
		})
	}
	
	static func insert(groupId: UUID, contentId: UUID){
		do{
			try Storage.instance.spacesDB.run(
				table.insert(
					or: .ignore,
					self.groupId <- groupId,
					self.contentId <- contentId
				)
			)
		}catch{
			print(error)
		}
	}
}
