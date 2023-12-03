//
//  DocumentTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import SQLite
import Cocoa

struct NiDocumentMetaData{
    let id: UUID
    var name: String?
    var updatedAt: Date
}

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
    //TODO: bool if top level document or has a parent
    
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
            print("Failed to insert into DocumentTable")
        }
    }
    
    static func fetchListofDocs(limit: Int = 10) -> [NiDocumentMetaData]{
        var res: [NiDocumentMetaData] = []
        
        do{
            for record in try Storage.db.spacesDB.prepare(table.select(id, name, updatedAt).limit(limit).order(updatedAt.desc)){
                res.append(NiDocumentMetaData(id: try record.get(id), name: try record.get(name), updatedAt: Date(timeIntervalSince1970: try record.get(updatedAt))))
            }
        }catch{
            print("Failed to fetch List of last used Docs or a column: \(error)")
        }
        return res
    }
    
    static func fetchDocumentModel(id: UUID) -> String?{
        do{
            for record in try Storage.db.spacesDB.prepare(table.select(document).filter(self.id == id)){
                return try record.get(document)
            }
        }catch{
            print("Failed to fetch JSON document for id: \(id) with error: \(error)")
        }
        return nil
    }
}


