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

    private let spacesDb: Connection

    
    init() throws{
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        // create parent directory inside application support if it doesn’t exist
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        
        
        spacesDb = try Connection(path + DB_SPACES)
        try createSpacesTablesIfNotExist(db: spacesDb)

    }
    
    func createSpacesTablesIfNotExist(db: Connection) throws{
        try DocumentTable.create(db: db)
        try ContentTable.create(db: db)
        try CachedWebTable.create(db: db)
        try DocumentIdContentIdTable.create(db: db)
    }
    

}
