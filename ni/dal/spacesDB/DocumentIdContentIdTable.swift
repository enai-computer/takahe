//
//  DocumentIdContentIdTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import Cocoa
import SQLite

class DocumentIdContentIdTable{
    
    static let table = Table("doc_id_content_id")
    static let contentId = Expression<UUID>("content_id")
    static let documentId = Expression<UUID>("document_id")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(documentId)
            t.column(contentId)
            t.primaryKey(documentId, contentId)
            t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
            t.foreignKey(documentId, references: DocumentTable.table, DocumentTable.id, delete: .cascade)
        })
    }
    
    static func insert(documentId: UUID, contentId: UUID){
        do{
            try Storage.instance.spacesDB.run(
                table.insert(
                    self.documentId <- documentId,
                    self.contentId <- contentId
                )
            )
        }catch{
//            print("Failed insert into DocumentIdContentIdTable")
        }
    }
}
