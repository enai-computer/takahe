//
//  Storage.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa
import SQLite

private let DB_SPACES = "/spaces.sqlite3"
var CUSTOM_STORAGE_LOCATION: String? = nil

class Storage{

	
    static let db = Storage()
    let spacesDB: Connection

    private init(){
		let argPos = CommandLine.arguments.firstIndex(of: "-niLocalStorage")
		if (argPos != nil){
			CUSTOM_STORAGE_LOCATION = CommandLine.arguments[(argPos!+1)]
		}
				
		let path = if(CUSTOM_STORAGE_LOCATION == nil){
			NSSearchPathForDirectoriesInDomains(
				.applicationSupportDirectory, .userDomainMask, true
			).first! + "/" + Bundle.main.bundleIdentifier!
		}else{
			CUSTOM_STORAGE_LOCATION!
		}
        
        do {
            // create parent directory inside application support if it doesn’t exist
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            spacesDB = try Connection(path + DB_SPACES)
			spacesDB.foreignKeys = true
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
		try NoteTable.create(db: db)
    }
    

}
