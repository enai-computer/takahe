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
	let userConfig: NiUserConfigModel
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
			if(!Storage.doesSQLiteDBExist(path!)){
				AppDelegate.dbExists = false
			}
			Storage.createDirsIfNotExist(basepath: path!)
            spacesDB = try Connection(path! + DB_SPACES)
			spacesDB.foreignKeys = true
			try Storage.createSpacesTablesIfNotExist(db: spacesDB)
			try Storage.runSpacesMigrations(db: spacesDB)
			
			cacheDB = try Connection(path! + DB_CACHE)
			cacheDB.foreignKeys = true
			try Storage.createCacheDBIfNotExist(db: cacheDB)
			
			userConfig = UserConfigProvider(configPath: path!).userConfig
        }catch{
            print("Failed to init SQLight.")
            //TODO: try to send crash report
            exit(EXIT_FAILURE)
        }

    }
	
	private static func doesSQLiteDBExist(_ basepath: String) -> Bool{
		return FileManager.default.fileExists(atPath: (basepath + DB_SPACES))
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
    
	private static func runSpacesMigrations(db: Connection) throws{
		if(db.userVersion! < 1){
			try db.run(ContentTable.table.addColumn(ContentTable.sourceUrl))
			db.userVersion = 1
		}
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
	
	func createDemoSpaces(){
		let db = Storage.instance.spacesDB
		let skiing = PregenSpaceSkiing()
		let intent = PregenIntent()
		do{
			try db.execute(skiing.skiing_doc_tabe)
			try db.execute(skiing.skiing_contentTable_SQL)
			try db.execute(skiing.skiing_doc_content_sql)
			try db.execute(skiing.skiing_cached_web_sql)
			
			try db.execute(intent.intent_doc_table)
			try db.execute(intent.intent_content_sql)
			try db.execute(intent.intent_doc_content_sql)
			try db.execute(intent.intent_cached_web_sql)
			try db.execute(intent.intent_note_sql)
		}catch{
			print("Failed to create demo space with: \(error)")
			return
		}

		//load img from assests
		let imgData = ImgDataStruct()
		for id in imgData.imgIDs{
			if let nsImageBits = fetchImgFromMainBundle(id: id){
				if let data = imgData.data[id]{
					ImgDal.insert(documentId: data.docID, id: id, title: data.title, img: nsImageBits, source: data.source)
				}
			}
		}
	}
		
	struct ImgDataStruct{
		let skiImg1 = UUID(uuidString: "3D33D959-24D6-4EB0-9669-6333ED02AC42")!
		let skiImg2 = UUID(uuidString: "DABFED28-717B-4E91-BBCA-3F7936E1ABC9")!
		let skiImg3 = UUID(uuidString: "EC9DF222-0555-41E2-A1E8-F36CD5CF2456")!
		let imgIDs: [UUID]
		let data: [UUID: ImgMeta]
		
		init(){
			let docId = UUID(uuidString: "69BE4F72-9F6E-44FC-88F3-2E285461CEA9")!
			self.imgIDs = [skiImg1, skiImg2 , skiImg3]
			self.data = [
				skiImg1: ImgMeta(docID: docId, title: "ryder_alps_1", source: "https://www.fieldmag.com/articles/david-ryder-swiss-alps-ski-photography"),
				skiImg2: ImgMeta(docID: docId, title: "Bildschirmfoto-2024-01-08-um-10.20.37", source: "https://www.zai.ch/stories/zai-developments-2024-about-performance-and-forms"),
				skiImg3: ImgMeta(docID: docId, title: "Kirkwood_Chris-Whatford--Molly-Armanino--Claire-Hewitt-Demeyer-pow-day-shoot_Dennis-Baggett---social-res--5-of-7-", source: "https://skicalifornia.org/resorts/kirkwood-mountain-resort")
			]
		}
	}
	
	struct ImgMeta{
		let docID: UUID
		let title: String
		let source: String
	}
}
