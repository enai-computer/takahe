//
//  DocumentIdGroupIdTable.swift
//  ni
//
//  Created by Patrick Lukas on 1/10/24.
//

import Foundation
import SQLite

class DocumentIdGroupIdTable{
	
	static let table = Table("doc_id_group_id")
	static let groupId = SQLite.Expression<UUID>("groupId_id")
	static let documentId = SQLite.Expression<UUID>("document_id")
	
	static func create(db: Connection) throws {
		try db.run(table.create(ifNotExists: true){ t in
			t.column(documentId)
			t.column(groupId)
			t.primaryKey(documentId, groupId)
			t.foreignKey(groupId, references: GroupTable.table, GroupTable.id, delete: .cascade)
			t.foreignKey(documentId, references: DocumentTable.table, DocumentTable.id, delete: .cascade)
		})
	}
	
	static func insert(documentId: UUID, groupId: UUID){
		do{
			try Storage.instance.spacesDB.run(
				table.insert(
					or: .ignore,
					self.documentId <- documentId,
					self.groupId <- groupId
				)
			)
		}catch{
			print(error)
		}
	}
}
