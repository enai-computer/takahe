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
    static let id = Expression<UUID>("id")
    static let name = Expression<String?>("name")
    static let owner = Expression<UUID?>("owner")
    static let shared = Expression<Bool>("shared")
    static let createdAt = Expression<Double>("created_at")
    static let updatedAt = Expression<Double>("updated_at")
    static let updatedBy = Expression<UUID?>("updated_by")
    static let document = Expression<String?>("document")
    
    static func create(db: Connection) throws{
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(owner)
            t.column(shared, defaultValue: false)
            t.column(createdAt)
            t.column(updatedAt)
            t.column(updatedBy)
            t.column(document)
        })
    }
    
    static func insertDoc(id: UUID, name: String, document: String?){
        do{
            try Storage.db.spacesDB.run(
                table.insert(
                    self.id <- id,
                    self.name <- name,
                    self.createdAt <- Date().timeIntervalSince1970,
                    self.updatedAt <- Date().timeIntervalSince1970,
                    self.document <- document
                )
            )
        }catch{
            print("Failed insert")
        }
    }
    
//    static func fetchListofDocs(limit: Int = 10){
//        return table.limit(limit).order(updatedAt.desc)
//    }
}
