//
//  Storage.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa
import SQLite

//private let STORAGE_PATH = "~/Library/Application Support/io.enai.app/"
private let DB_SPACES = "/spaces.sqlite3"

class DBStorage{

    init() throws{
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        // create parent directory inside application support if it doesn’t exist
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        
        do{
            let db = try Connection(path + DB_SPACES)
            try createSpacesTablesIfNotExist(db: db)
        }catch{
            print("Unexpected error: \(error)")
        }
    }
    
    func createSpacesTablesIfNotExist(db: Connection) throws{
        let documentTableFkId = try createDocumentTable(db: db)
        let contentTableFkId = try createContentTable(db: db)
        try createCachedWebTable(db: db, contentTable: contentTableFkId.table, contentTableId: contentTableFkId.fkKey)
        try createDocumentIdContentIdTable(db: db, documentTable: documentTableFkId.table, documentTableId: documentTableFkId.fkKey, contentTable: contentTableFkId.table, contentTableId: contentTableFkId.fkKey)
    }
    
    func createDocumentTable(db: Connection) throws -> (table: Table, fkKey: Expression<String>){
        let documentTable = Table("document")
        let id = Expression<String>("id")
        let owner = Expression<String>("owner")
        let shared = Expression<Bool>("shared")
        let createdAt = Expression<Date>("created_at")
        let updatedAt = Expression<Date>("updated_at")
        let updatedBy = Expression<String>("updated_by")
        let document = Expression<String>("document")
        
        try db.run(documentTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(owner)
            t.column(shared)
            t.column(createdAt)
            t.column(updatedAt)
            t.column(updatedBy)
            t.column(document)
        })
        return (documentTable, id)
    }
    
    func createContentTable(db: Connection) throws -> (table: Table, fkKey: Expression<String>){
        let contentTable = Table("content")
        let id = Expression<String>("id")
        let type = Expression<String>("owner")
        let updatedAt = Expression<Date>("updated_at")
        let localStorageLocation = Expression<String>("local_storage_location")
        let refCounter = Expression<Int>("ref_counter")
        
        try db.run(contentTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(type)
            t.column(updatedAt)
            t.column(localStorageLocation)
            t.column(refCounter)
        })
        return (contentTable, id)
    }
    
    func createDocumentIdContentIdTable(db: Connection, documentTable: Table, documentTableId: Expression<String>, contentTable: Table, contentTableId: Expression<String>) throws{
        let documentIdContentIdTable = Table("doc_id_content_id")
        let contentId = Expression<String>("content_id")
        let documentId = Expression<String>("document_id")
        
        try db.run(documentIdContentIdTable.create(ifNotExists: true){ t in
            t.column(documentId)
            t.column(contentId)
            t.primaryKey(documentId, contentId)
            t.foreignKey(documentId, references: documentTable, documentTableId, delete: .setNull)
            t.foreignKey(contentId, references: contentTable, contentTableId, delete: .cascade)
        })
    }
    
    func createCachedWebTable(db: Connection, contentTable: Table, contentTableId: Expression<String>) throws{
        let cachedWebTable = Table("cached_Web")
        let contentId = Expression<String>("content_id")
        let url = Expression<String>("url")
        let updatedAt = Expression<Date>("updated_at")
        let cookies = Expression<String>("cookies")
        let htmlWebsite = Expression<String>("html_website")
        let history = Expression<String>("history")
        
        try db.run(cachedWebTable.create(ifNotExists: true){ t in
            t.column(contentId, primaryKey: true)
            t.column(url)
            t.column(updatedAt)
            t.column(cookies)
            t.column(htmlWebsite)
            t.column(history)
            t.foreignKey(contentId, references: contentTable, contentTableId, delete: .cascade)
        })
    }
}
