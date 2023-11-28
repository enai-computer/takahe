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
    static let id = Expression<String>("id")
    static let type = Expression<String>("owner")
    static let updatedAt = Expression<Date>("updated_at")
    static let localStorageLocation = Expression<String>("local_storage_location")
    static let refCounter = Expression<Int>("ref_counter")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(type)
            t.column(updatedAt)
            t.column(localStorageLocation)
            t.column(refCounter)
        })
    }
}
