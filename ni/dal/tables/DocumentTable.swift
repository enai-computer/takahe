//
//  DocumentTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import SQLite
import Cocoa

class DocumentTable{
    static let table = Table("document")
    static let id = Expression<String>("id")
    static let owner = Expression<String>("owner?")
    static let shared = Expression<Bool>("shared")
    static let createdAt = Expression<Date>("created_at")
    static let updatedAt = Expression<Date>("updated_at")
    static let updatedBy = Expression<String>("updated_by")
    static let document = Expression<String>("document")
    
    static func create(db: Connection) throws{
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(owner)
            t.column(shared)
            t.column(createdAt)
            t.column(updatedAt)
            t.column(updatedBy)
            t.column(document)
        })
    }
}
