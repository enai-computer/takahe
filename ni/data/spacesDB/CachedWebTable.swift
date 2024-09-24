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
	static let contentId = SQLite.Expression<UUID>("content_id")
	static let url = SQLite.Expression<String>("url")
	static let updatedAt = SQLite.Expression<Double>("updated_at")
	static let cache = SQLite.Expression<SQLite.Blob?>("cache")
	static let htmlWebsite = SQLite.Expression<String?>("html_website")
//    static let history = Expression<String?>("history")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(contentId, primaryKey: true)
            t.column(url)
            t.column(updatedAt)
            t.column(cache)
            t.column(htmlWebsite)
            t.foreignKey(contentId, references: ContentTable.table, ContentTable.id, delete: .cascade)
        })
    }
    
    static func upsert(documentId: UUID, id: UUID, title: String?, url: String){
        do{
            try Storage.instance.spacesDB.run(
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
    }
    
    static func fetchCachedWebsite(contentId: UUID) -> CachedWebsite?{
        do{
            for record in try Storage.instance.spacesDB.prepare(
                table.join(ContentTable.table, on: self.contentId==ContentTable.id)
                    .select(url, ContentTable.title).filter(self.contentId == contentId)
            ){
                return try CachedWebsite(
                    url: record.get(url),
                    title: record.get(ContentTable.title) ?? ""
                )
            }
        }catch{
            debugPrint("failed to fetch url for content \(contentId) with error: \(error)")
        }
        return nil
    }
}

struct CachedWebsite{
    let url: String
    let title: String
}
