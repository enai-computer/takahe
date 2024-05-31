//
//  Storage.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa
import SQLite

private let DB_SPACES = "/spaces.sqlite3"
private let DB_CACHE = "/niCache.sqlite3"
private let DATA_FOLDER = "/data-0"
private let IMG_FOLDER = "/img-0"
private let CACHE_FOLDER = "/cache"
private let FAVICON_FOLDER = "/favicon"

var CUSTOM_STORAGE_LOCATION: String? = nil

enum FileStorageType{
	case spaceImg, favIcon
}

class Storage{

    static let instance = Storage()
    let spacesDB: Connection
	let cacheDB: Connection
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
			try Storage.createSpacesTablesIfNotExist(db: spacesDB)
			
			cacheDB = try Connection(path! + DB_CACHE)
			cacheDB.foreignKeys = true
			try Storage.createCacheDBIfNotExist(db: cacheDB)
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
			
			try FileManager.default.createDirectory(atPath: basepath + CACHE_FOLDER + FAVICON_FOLDER, withIntermediateDirectories: true, attributes: nil)
		}catch{
			print("Failed to init nessary Directories.")
			exit(EXIT_FAILURE)
		}
	}
	
    private static func createSpacesTablesIfNotExist(db: Connection) throws {
        try DocumentTable.create(db: db)
        try ContentTable.create(db: db)
        try CachedWebTable.create(db: db)
        try DocumentIdContentIdTable.create(db: db)
		try NoteTable.create(db: db)
    }
    
	private static func createCacheDBIfNotExist(db: Connection) throws {
		try FaviconCacheTable.create(db: db)
	}
	
	func genFileUrl(for id: UUID, ofType type: FileStorageType) -> URL{
		if(type == .spaceImg){
			return URL(
				fileURLWithPath: path! + DATA_FOLDER + IMG_FOLDER + "/\(id).jpg",
				isDirectory: false
			)
		}
		
		if(type == .favIcon){
			return URL(
				fileURLWithPath: path! + CACHE_FOLDER + FAVICON_FOLDER + "/\(id).jpg",
				isDirectory: false
			)
		}
		preconditionFailure("functionality is not implemented")
	}
}
