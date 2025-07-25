//
//  Storage.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa
import SQLite
import Atomics

private let DB_SPACES = "/spaces.sqlite3"
private let DB_CACHE = "/niCache.sqlite3"
private let DATA_FOLDER = "/data-0"
private let IMG_FOLDER = "/img-0"
private let PDF_FOLDER = "/pdf-0"
private let CACHE_FOLDER = "/cache"
private let PARTIAL_DOWNLOAD_FOLDER = "/patrial-download"
private let FAVICON_FOLDER = "/favicon"

var CUSTOM_STORAGE_LOCATION: String? = nil

enum FileStorageType{
	case spaceImg, spacePdf, favIcon, partialDownload
}

class Storage{

    static let instance = Storage()
    let spacesDB: Connection
	let cacheDB: Connection
	private let currentWrites = ManagedAtomic<Int>(0)
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
			
			try FileManager.default.createDirectory(atPath: basepath + CACHE_FOLDER + PARTIAL_DOWNLOAD_FOLDER, withIntermediateDirectories: true, attributes: nil)
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
		try UserSettingsTable.create(db: db)
		try GroupTable.create(db: db)
		try GroupIdContentIdTable.create(db: db)
		try DocumentIdGroupIdTable.create(db: db)
		try EveChatTable.create(db: db)
    }
    
	private static func runSpacesMigrations(db: Connection) throws{
		if(db.userVersion! < 1){
			try db.run(ContentTable.table.addColumn(ContentTable.sourceUrl))
			db.userVersion = 1
		}
		if(db.userVersion! < 2){
			try db.run(ContentTable.table.addColumn(ContentTable.extractedContent))
			db.userVersion = 2
		}
	}
	
	private static func createCacheDBIfNotExist(db: Connection) throws {
		try FaviconCacheTable.create(db: db)
		try OutboxTable.create(db: db)
	}
	
	func getDir(for type: FileStorageType) -> URL {
		if(type == .favIcon){
			return URL(
				fileURLWithPath: path! + CACHE_FOLDER + FAVICON_FOLDER,
				isDirectory: true
			)
		}
		preconditionFailure("functionality is not implemented")
	}
	
	func genFileUrl(for id: UUID, ofType type: FileStorageType, with suffix: String? = nil) -> URL{
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
				fileURLWithPath: path! + CACHE_FOLDER + FAVICON_FOLDER + "/\(id).png",
				isDirectory: false
			)
		}
		
		if(type == .partialDownload){
			return URL(
				fileURLWithPath: path! + CACHE_FOLDER + PARTIAL_DOWNLOAD_FOLDER + "/\(id)/\(suffix!)",
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
		let plants = PregenPlantsBorneo()
		let ideas = PregenIdeas()
		let welcome = PregenLearnEnai()
		
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
			
			try db.execute(plants.doc_table)
			try db.execute(plants.contentTable_sql)
			try db.execute(plants.doc_content_sql)
			try db.execute(plants.cached_web_sql)
			try db.execute(plants.user_notes)
			if let m: String = try plants.eve_chat_message(){
				DocumentDal.persistEveChat(spaceId: UUID(uuidString: "4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92")!, id: UUID(uuidString: "C1AA772E-5E9E-4262-BD55-C8DA7338C066")!, title: "Welcome to Space", messages: m, groupId: nil)
				
			}
			
			try db.execute(ideas.doc_table_sql)
			try db.execute(ideas.contentTable_sql)
			try db.execute(ideas.doc_content_sql)
			try db.execute(ideas.cached_web_sql)
			try db.execute(ideas.notes_sql)
			
			try db.execute(welcome.doc_table)
			try db.execute(welcome.contentTable_sql)
			try db.execute(welcome.doc_content_sql)
			try db.execute(welcome.cached_web_sql)
			try db.execute(welcome.user_notes)
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
		
	func startedWrite(){
		currentWrites.wrappingIncrement(ordering: .sequentiallyConsistent)
	}
	
	func finishedWrite(){
		currentWrites.wrappingDecrement(ordering: .sequentiallyConsistent)
	}
	
	func writesInProgress() -> Bool{
		return currentWrites.load(ordering: .sequentiallyConsistent) != 0
	}
	
	struct ImgDataStruct{
		let skiImg1 = UUID(uuidString: "3D33D959-24D6-4EB0-9669-6333ED02AC42")!
		let skiImg2 = UUID(uuidString: "DABFED28-717B-4E91-BBCA-3F7936E1ABC9")!
		let skiImg3 = UUID(uuidString: "EC9DF222-0555-41E2-A1E8-F36CD5CF2456")!
		let cooking1 = UUID(uuidString: "43DC5B56-124C-4368-A341-EAA9D2E33CFD")!
		let cooking2 = UUID(uuidString: "E52F5D89-38ED-42B3-938F-4E52105C7DF7")!
		let cooking3 = UUID(uuidString: "E9762558-E0D7-4FAA-9BEA-405FB306E3E6")!
		
		let plants1 = UUID(uuidString: "5CBD57A2-FDB6-41C7-B6C7-A6E69DDE9EFF")!
		let plants2 = UUID(uuidString: "36A7D9B2-6057-4F35-89FA-E30F89648AC7")!
		let plants3 = UUID(uuidString: "129B617E-3FBA-428C-BB57-91FBF2FE7613")!
		let plants4 = UUID(uuidString: "459F9CE5-13F7-4AAE-B00F-C1ABF2CB8C24")!
		let plants5 = UUID(uuidString: "8125E0A3-62D3-4F4C-87E2-4B781329F29E")!
		let plants6 = UUID(uuidString: "A6E48A0D-D220-4614-9B8E-963795BC4386")!
		
		let ideas1 = UUID(uuidString: "736E9972-42A7-49F8-9141-BE7CA4CA9407")!
		let ideas2 = UUID(uuidString: "019A6F08-E125-4268-A23E-06E6274DF4FB")!
		
		let welcome1 = UUID(uuidString: "8FB53F87-D45C-431B-94D0-E89AF42694D7")!
		
		let imgIDs: [UUID]
		let data: [UUID: ImgMeta]
		
		init(){
			let docIdSkiing = UUID(uuidString: "69BE4F72-9F6E-44FC-88F3-2E285461CEA9")!
			let docIdCooking = UUID(uuidString: "4D90F0F2-064D-42B8-9A16-B9A613A2A162")!
			let docIdplants = UUID(uuidString: "4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92")!
			let docIdIdeas = UUID(uuidString: "8B80A304-9ECB-40EB-934E-DABB8D3E82A4")!
			let docIdWelcome = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
			
			self.imgIDs = [skiImg1, skiImg2 , skiImg3, cooking1, cooking2, cooking3, plants1, plants2, plants3, plants4, plants5, plants6, ideas1, ideas2, welcome1]
			self.data = [
				skiImg1: ImgMeta(docID: docIdSkiing, title: "ryder_alps_1", source: "https://www.fieldmag.com/articles/david-ryder-swiss-alps-ski-photography"),
				skiImg2: ImgMeta(docID: docIdSkiing, title: "Bildschirmfoto-2024-01-08-um-10.20.37", source: "https://www.zai.ch/stories/zai-developments-2024-about-performance-and-forms"),
				skiImg3: ImgMeta(docID: docIdSkiing, title: "Kirkwood_Chris-Whatford--Molly-Armanino--Claire-Hewitt-Demeyer-pow-day-shoot_Dennis-Baggett---social-res--5-of-7-", source: "https://skicalifornia.org/resorts/kirkwood-mountain-resort"),
				cooking1: ImgMeta(docID: docIdCooking, title: "53721_-_Profi_Profi_Y-Schaeler_SPECIALTY_SERIE-1_1920x1920", source: "https://www.microplane-brandshop.com/en/Microplane-Profi-Y-Peeler/53721"),
				cooking2: ImgMeta(docID: docIdCooking, title: "vegetablepeeler-2048px-KMilford045", source: "https://www.nytimes.com/wirecutter/reviews/best-vegetable-peeler/"),
				cooking3: ImgMeta(docID: docIdCooking, title: "1*un-K3W8FI0nwnykyXOFiUQ", source: "https://medium.com/@drspoulsen/a-solution-to-the-onion-problem-of-j-kenji-l%C3%B3pez-alt-c3c4ab22e67c"),
				plants1: ImgMeta(docID: docIdplants, title: "", source: "https://www.rainforestjournal.com/dipterocarp-trees/"),
				plants2: ImgMeta(docID: docIdplants, title: "", source: "https://en.wikipedia.org/wiki/Teak#"),
				plants3: ImgMeta(docID: docIdplants, title: "", source: "https://en.wikipedia.org/wiki/Eusideroxylon"),
				plants4: ImgMeta(docID: docIdplants, title: "", source: "https://en.wikipedia.org/wiki/Rafflesia"),
				plants5: ImgMeta(docID: docIdplants, title: "", source: "https://en.wikipedia.org/wiki/Dipterocarpaceae"),
				plants6: ImgMeta(docID: docIdplants, title: "", source: "https://en.wikipedia.org/wiki/Teak#/media/File:Nilambur_Teak_Plantation_0666.jpg"),
				ideas1: ImgMeta(docID: docIdIdeas, title: "", source: "https://enai.io/"),
				ideas2: ImgMeta(docID: docIdIdeas, title: "", source: "https://www.dubberly.com/articles/design-in-the-age-of-biology.html"),
				welcome1: ImgMeta(docID: docIdWelcome, title: "", source: "https://www.are.na/block/23834922")
			]
		}
	}
	
	struct ImgMeta{
		let docID: UUID
		let title: String
		let source: String
	}
}
