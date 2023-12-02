//
//  MigrationTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/26/23.
//

import Cocoa
import SQLite
import WebKit

class SchemaHistoryTable{
    
    static let table = Table("schema_history")
    static let rank = Expression<Int>("installed_rank")
    static let version = Expression<Int>("version")
    static let script = Expression<String>("script")
    static let installedOn = Expression<Date>("installed_on")
    static let success = Expression<Bool>("success")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(rank, primaryKey: true)
            t.column(version)
            t.column(script)
            t.column(installedOn)
            t.column(success)
        })
    }
}
