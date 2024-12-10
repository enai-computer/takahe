//
//  DocumentTable.swift
//  ni
//
//  Created by Patrick Lukas on 11/22/23.
//

import Cocoa
import SQLite

struct NiDocumentViewModel: Hashable{
    let id: UUID?
    var name: String
    var updatedAt: Date?
	var isSelected: Bool = false
}

class DocumentTable{
	
    static let table = Table("document")
	static let id = SQLite.Expression<UUID>("id")
	static let name = SQLite.Expression<String>("name")
	static let owner = SQLite.Expression<UUID?>("owner")
	static let shared = SQLite.Expression<Bool>("shared")
	static let createdAt = SQLite.Expression<Double>("created_at")
	static let updatedAt = SQLite.Expression<Double>("updated_at")
	static let updatedBy = SQLite.Expression<UUID?>("updated_by")
	static let document = SQLite.Expression<String?>("document")
    //TODO: bool if top level document or has a parent
    
    static func create(db: Connection) throws{
        try db.run(table.create(ifNotExists: true){ t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(owner)
            t.column(shared, defaultValue: false)
            t.column(createdAt)
            t.column(updatedAt)
            t.column(updatedBy)
            t.column(document)
        })
    }
	
	static func updateName(id: UUID, name: String){
		do{
			let rowToUpdate = table.filter(self.id == id)
			let updatedRows = try Storage.instance.spacesDB.run(
				rowToUpdate.update(
					self.name <- name,
					self.updatedAt <- Date.now.timeIntervalSince1970
				)
			)
			if(updatedRows != 1){
				print("Failed to update the name. Updated \(updatedRows) rows.")
			}
		}catch{
			print("Failed to update the name")
		}
	}
    
    static func upsertDoc(id: UUID, name: String, document: String?){
        do{
            try Storage.instance.spacesDB.run(
                table.upsert(
                    self.id <- id,
                    self.name <- name,
                    self.createdAt <- Date().timeIntervalSince1970,
                    self.updatedAt <- Date().timeIntervalSince1970,
                    self.document <- document,
                    onConflictOf: self.id
                )
            )
        }catch{
            print("Failed to insert into DocumentTable")
        }
    }
    
    static func fetchListofDocs(limit: Int = 50) -> [NiDocumentViewModel]{
        var res: [NiDocumentViewModel] = []
//		var containsWelcomeSpace: Bool = false
        do{
			for record in try Storage.instance.spacesDB.prepare(table.select(id, name, updatedAt).limit(limit).order(updatedAt.desc)){
				res.append(NiDocumentViewModel(id: try record.get(id), name: try record.get(name), updatedAt: Date(timeIntervalSince1970: try record.get(updatedAt))))
//				if(try record.get(id) == WelcomeSpaceGenerator.WELCOME_SPACE_ID){
//					containsWelcomeSpace = true
//				}
			}
        }catch{
            print("Failed to fetch List of last used Docs or a column: \(error)")
        }
		
//		if(!containsWelcomeSpace && res.count < limit){
//			res.append(NiDocumentViewModel(id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME))
//		}
        return res
    }

	static func fetchDocumentName(id: UUID) -> String?{
		do{
			for record in try Storage.instance.spacesDB.prepare(table.select(name).filter(self.id == id)){
				return try record.get(name)
			}
		}catch{
			print("Failed to fetch name from document table with id: \(id) and error: \(error)")
		}
		return nil
	}
	
    static func fetchDocumentModel(id: UUID) -> String?{
        do{
            for record in try Storage.instance.spacesDB.prepare(table.select(document).filter(self.id == id)){
                return try record.get(document)
            }
        }catch{
            print("Failed to fetch JSON document for id: \(id) with error: \(error)")
        }
        return nil
    }
	
	static func deleteDocument(id: UUID){
		do{
			let rowToDelete = table.filter(self.id == id)
			try Storage.instance.spacesDB.run(
				rowToDelete.delete()
			)
		}catch{
			print("Failed to delete document.")
		}
	}
}


