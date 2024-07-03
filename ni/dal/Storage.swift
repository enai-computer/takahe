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
private let PDF_FOLDER = "/pdf-0"
private let CACHE_FOLDER = "/cache"
private let FAVICON_FOLDER = "/favicon"

var CUSTOM_STORAGE_LOCATION: String? = nil

enum FileStorageType{
	case spaceImg, spacePdf, favIcon
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
			
			try FileManager.default.createDirectory(atPath: basepath + DATA_FOLDER + PDF_FOLDER, withIntermediateDirectories: true, attributes: nil)
			
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
		
		if(type == .spacePdf){
			return URL(
				fileURLWithPath: path! + DATA_FOLDER + PDF_FOLDER + "/\(id).pdf",
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
		let cooking = PregenCookingSpace()
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
			
			try db.execute(cooking.doc_table)
			try db.execute(cooking.content_sql)
			try db.execute(cooking.doc_content_sql)
			try db.execute(cooking.cached_web_sql)
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
		let cooking1 = UUID(uuidString: "43DC5B56-124C-4368-A341-EAA9D2E33CFD")!
		let cooking2 = UUID(uuidString: "E52F5D89-38ED-42B3-938F-4E52105C7DF7")!
		let cooking3 = UUID(uuidString: "E9762558-E0D7-4FAA-9BEA-405FB306E3E6")!
		let imgIDs: [UUID]
		let data: [UUID: ImgMeta]
		
		init(){
			let docIdSkiing = UUID(uuidString: "69BE4F72-9F6E-44FC-88F3-2E285461CEA9")!
			let docIdCooking = UUID(uuidString: "4D90F0F2-064D-42B8-9A16-B9A613A2A162")!
			
			self.imgIDs = [skiImg1, skiImg2 , skiImg3, cooking1, cooking2, cooking3]
			self.data = [
				skiImg1: ImgMeta(docID: docIdSkiing, title: "ryder_alps_1", source: "https://www.fieldmag.com/articles/david-ryder-swiss-alps-ski-photography"),
				skiImg2: ImgMeta(docID: docIdSkiing, title: "Bildschirmfoto-2024-01-08-um-10.20.37", source: "https://www.zai.ch/stories/zai-developments-2024-about-performance-and-forms"),
				skiImg3: ImgMeta(docID: docIdSkiing, title: "Kirkwood_Chris-Whatford--Molly-Armanino--Claire-Hewitt-Demeyer-pow-day-shoot_Dennis-Baggett---social-res--5-of-7-", source: "https://skicalifornia.org/resorts/kirkwood-mountain-resort"),
				cooking1: ImgMeta(docID: docIdCooking, title: "53721_-_Profi_Profi_Y-Schaeler_SPECIALTY_SERIE-1_1920x1920", source: "https://www.microplane-brandshop.com/en/Microplane-Profi-Y-Peeler/53721"),
				cooking2: ImgMeta(docID: docIdCooking, title: "vegetablepeeler-2048px-KMilford045", source: "https://www.nytimes.com/wirecutter/reviews/best-vegetable-peeler/"),
				cooking3: ImgMeta(docID: docIdCooking, title: "1*un-K3W8FI0nwnykyXOFiUQ", source: "https://medium.com/@drspoulsen/a-solution-to-the-onion-problem-of-j-kenji-l%C3%B3pez-alt-c3c4ab22e67c")
			]
		}
	}
	
	struct ImgMeta{
		let docID: UUID
		let title: String
		let source: String
	}
}
