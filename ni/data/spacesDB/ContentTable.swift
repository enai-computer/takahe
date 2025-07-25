//
//  ContentTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import SQLite
import Cocoa

enum ContentTableRecordType: String, Codable{
	case img, pdf, note, web
}

class ContentTable{
    
    static let table = Table("content")
	static let id = SQLite.Expression<UUID>("id")
	static let title = SQLite.Expression<String?>("title")
	static let type = SQLite.Expression<String>("type")
	static let updatedAt = SQLite.Expression<Double>("updated_at")
	static let localStorageLocation = SQLite.Expression<String?>("local_storage_location")
	static let sourceUrl = SQLite.Expression<String?>("source_url")
	static let refCounter = SQLite.Expression<Int>("ref_counter")
	static let extractedContent = SQLite.Expression<String?>("extracted_content")
    
    static func create(db: Connection) throws {
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(type)
            t.column(updatedAt)
            t.column(localStorageLocation)
            t.column(refCounter, defaultValue: 1)
        })
		//all other columns got added with the migration scripts
		// sourceUrl is the first one and got added with version 1
    }
	
	static func contains(id: UUID) -> Bool {
		do{
			let q = table.where(self.id == id)
			for _ in try Storage.instance.spacesDB.prepare(q){
				return true
			}
		}catch{
			print("Failed to run select on ContentTable")
		}
		return false
	}
	
	static func updateTitle(id: UUID, title: String?){
		do{
			let rowToUpdate = table.where(self.id == id)
			try Storage.instance.spacesDB.run(
				rowToUpdate.update(
					self.title <- title,
					self.updatedAt <- Date().timeIntervalSince1970
				)
			)
		}catch{
			print("Failed to insert into ContentTable")
		}
	}
    
	static func fetchURLTitleSource(for id: UUID) -> (String?, String?, String?)?{
		do{
			let q = table.where(self.id == id)
			for r in try Storage.instance.spacesDB.prepare(q){
				return try (
					r.get(self.localStorageLocation),
					r.get(self.title),
					r.get(self.sourceUrl)
					)
			}
		}catch{
			print("Failed to run select on ContentTable")
		}
		return nil
	}
	
	static func fetchExtractedContent(for id: UUID) -> String?{
		do{
			let q = table.where(self.id == id)
			for r in try Storage.instance.spacesDB.prepare(q){
				return try r.get(self.extractedContent)
			}
		}catch{
			print("Failed to run select on ContentTable")
		}
		return nil
	}
	
	/** do not use this function for rows that require a local storage location as that will be overwrite them with null!!!
	 
	 */
    static func upsert(id: UUID, type: ContentTableRecordType, title: String?){
        do{
            try Storage.instance.spacesDB.run(
                table.upsert(
                    self.id <- id,
                    self.title <- title,
					self.type <- type.rawValue,
                    self.updatedAt <- Date().timeIntervalSince1970,
					onConflictOf: self.id
                )
            )
        }catch{
            print("Failed to insert into ContentTable")
        }
    }
	
	static func upsert(id: UUID, type: ContentTableRecordType, title: String?, extractedContent: String){
		do{
			try Storage.instance.spacesDB.run(
				table.upsert(
					self.id <- id,
					self.title <- title,
					self.type <- type.rawValue,
					self.updatedAt <- Date().timeIntervalSince1970,
					self.extractedContent <- extractedContent,
					onConflictOf: self.id
				)
			)
		}catch{
			print("Failed to insert into ContentTable")
		}
	}
	
	static func upsert(id: UUID, type: ContentTableRecordType, title: String?, fileUrl: String, source: String?){
		do{
			try Storage.instance.spacesDB.run(
				table.upsert(
					self.id <- id,
					self.title <- title,
					self.type <- type.rawValue,
					self.localStorageLocation <- fileUrl,
					self.sourceUrl <- source,
					self.updatedAt <- Date().timeIntervalSince1970,
					onConflictOf: self.id
				)
			)
		}catch{
			print("Failed to insert into ContentTable")
		}
	}
	
	static func delete(id: UUID){
		do{
			let record = table.filter(self.id == id)
			try Storage.instance.spacesDB.run(record.delete())
		} catch {
			print("Failed to delete content from the content table with id: \(id)")
		}
	}
}
