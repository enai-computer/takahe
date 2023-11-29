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
    static let owner = Expression<String?>("owner")
    static let shared = Expression<Bool>("shared")
    static let createdAt = Expression<Double>("created_at")
    static let updatedAt = Expression<Double>("updated_at")
    static let updatedBy = Expression<String?>("updated_by")
    static let document = Expression<String?>("document")
    
    static func create(db: Connection) throws{
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(owner)
            t.column(shared, defaultValue: false)
            t.column(createdAt, defaultValue: NSDate().timeIntervalSince1970)
            t.column(updatedAt, defaultValue: NSDate().timeIntervalSince1970)
            t.column(updatedBy)
            t.column(document)
        })
    }
}
