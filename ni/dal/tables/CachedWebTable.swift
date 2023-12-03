//
//  CachedWebTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import Cocoa
import SQLite
import WebKit

class CachedWebTable{
    
    static let table = Table("cached_Web")
    static let contentId = Expression<UUID>("content_id")
    static let url = Expression<String>("url")
    static let updatedAt = Expression<Double>("updated_at")
    static let cache = Expression<SQLite.Blob?>("cache")
    static let htmlWebsite = Expression<String?>("html_website")
//    static let history = Expression<String?>("history")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(contentId, primaryKey: true)
            t.column(url)
            t.column(updatedAt)
            t.column(cache)
            t.column(htmlWebsite)
//            t.column(history)
            t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
        })
    }
    
    static func upsert(documentId: UUID, id: UUID, title: String?, url: String){
        ContentTable.insert(id: id, type: "web", title: title)
        
        do{
            try Storage.db.spacesDB.run(
                table.upsert(
                    self.contentId <- id,
                    self.url <- url,
                    self.updatedAt <- Date().timeIntervalSince1970,
                    onConflictOf: self.contentId
                )
            )
        }catch{
            print("Failed to insert into CachedWebTable")
        }
        
        DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
    }
    
    static func fetchURL(contentId: UUID) -> String{
        do{
            for record in try Storage.db.spacesDB.prepare(table.select(url).filter(self.contentId == contentId)){
                return try record.get(url)
            }
        }catch{
            print("failed to fetch url for content \(contentId) with error: \(error)")
        }
        return "https://enai.io"
    }
}
