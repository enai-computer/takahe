//
//  CachedWebTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import Cocoa
import SQLite

class CachedWebTable{
    
    static let table = Table("cached_Web")
    static let contentId = Expression<String>("content_id")
    static let url = Expression<String>("url")
    static let updatedAt = Expression<Date>("updated_at")
    static let cookies = Expression<String>("cookies")
    static let htmlWebsite = Expression<String>("html_website")
    static let history = Expression<String>("history")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(contentId, primaryKey: true)
            t.column(url)
            t.column(updatedAt)
            t.column(cookies)
            t.column(htmlWebsite)
            t.column(history)
            t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
        })
    }
}
