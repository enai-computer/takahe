//
//  Storage.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa
import SQLite

private let DB_SPACES = "/spaces.sqlite3"
private let DATA_FOLDER = "/data-0"
private let IMG_FOLDER = "/img-0"
var CUSTOM_STORAGE_LOCATION: String? = nil

class Storage{

    static let instance = Storage()
    let spacesDB: Connection
	private var path: String?

    private init(){
		let argPos = CommandLine.arguments.firstIndex(of: "-niLocalStorage")
		if (argPos != nil){
			CUSTOM_STORAGE_LOCATION = CommandLine.arguments[(argPos!+1)]
		}
				
		path = if(CUSTOM_STORAGE_LOCATION == nil){
			NSSearchPathForDirectoriesInDomains(
				.applicationSupportDirectory, .userDomainMask, true
			).first! + "/" + Bundle.main.bundleIdentifier!
		}else{
			CUSTOM_STORAGE_LOCATION!
		}
        
        do {
			Storage.createDirsIfNotExist(basepath: path!)
            spacesDB = try Connection(path! + DB_SPACES)
			spacesDB.foreignKeys = true
            try createSpacesTablesIfNotExist(db: spacesDB)
        }catch{
            print("Failed to init SQLight.")
            //TODO: try to send crash report
            exit(EXIT_FAILURE)
        }

    }
	
	private static func createDirsIfNotExist(basepath: String){
		do{
			// creates directories inside container / application support if it doesn’t exist
			try FileManager.default.createDirectory(atPath: basepath, withIntermediateDirectories: true, attributes: nil)
			
			try FileManager.default.createDirectory(atPath: basepath + DATA_FOLDER + IMG_FOLDER, withIntermediateDirectories: true, attributes: nil)
		}catch{
			print("Failed to init nessary Directories.")
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
    
	func genFileUrl(for id: UUID, ofType type: TabContentType = .img) -> URL{
		if(type == .img){
			return URL(
				fileURLWithPath: path! + DATA_FOLDER + IMG_FOLDER + "/\(id).jpg",
				isDirectory: false
			)
		}
		preconditionFailure("functionality is not implemented")
	}
}
