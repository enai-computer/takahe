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

class Storage{

    static let db = Storage()
    let spacesDB: Connection

    
    private init(){
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        do {
            // create parent directory inside application support if it doesn’t exist
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            spacesDB = try Connection(path + DB_SPACES)
            try createSpacesTablesIfNotExist(db: spacesDB)
        }catch{
            print("Failed to init SQLight.")
            //TODO: try to send crash report
            exit(EXIT_FAILURE)
        }


    }
    
    private func createSpacesTablesIfNotExist(db: Connection) throws{
        try DocumentTable.create(db: db)
        try ContentTable.create(db: db)
        try CachedWebTable.create(db: db)
        try DocumentIdContentIdTable.create(db: db)
    }
    

}
