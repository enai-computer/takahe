//
//  FaviconTable.swift
//  ni
//
//  Created by Patrick Lukas on 30/5/24.
//

import Cocoa
import SQLite

class FaviconCacheTable{
	
	static let table = Table("favicon_cache")
	static let domain = Expression<String>("domain")
	static let updatedAt = Expression<Double>("updated_at")
	static let storageLocation = Expression<String>("stored_at")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(domain, primaryKey: true)
			t.column(updatedAt)
			t.column(storageLocation)
		})
	}
	
	static func upsert(domain: String, storageLocation: String){
		do{
			try Storage.instance.cacheDB.run(
				table.upsert(
					self.domain <- domain,
					self.storageLocation <- storageLocation,
					self.updatedAt <- Date().timeIntervalSince1970,
					onConflictOf: self.domain
				)
			)
		}catch{
			print("failed to insert into note table")
		}
	}
	
	static func flushTable(){
		do{
			let delQuery = table.delete()
			let numbDelRows = try Storage.instance.cacheDB.run(delQuery)
			print("deleted \(numbDelRows) of rows in FavIcon cache table")
		}catch{
			print("Failed to delete content in table")
		}
	}
	
	static func fetchIconLocation(domain: String) -> String?{
		do{
			let q = table.where(self.domain == domain)
			for r in try Storage.instance.cacheDB.prepare(q){
				return try r.get(self.storageLocation)
			}
		}catch{
			print("Failed to run select on ContentTable")
		}
		return nil
	}
}
