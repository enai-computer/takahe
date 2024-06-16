//
//  Cook.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Foundation
import SQLite


/** Named after Captain James Cook
 
 */
class Cook{
	
	static let instance = Cook()
	
	//TBD:
	func search(){}
	
	func searchSpaces(typedChars: String?, maxNrOfResults: Int? = nil, excludeWelcomeSpaceGeneration: Bool = true) -> [NiDocumentViewModel]{
		var res: [NiDocumentViewModel] = []
		var containsWelcomeSpace: Bool = excludeWelcomeSpaceGeneration
		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildSearchQuery(typedChars: typedChars, maxNrOfResults: maxNrOfResults)
			){
				res.append(
					NiDocumentViewModel(
						id: try record.get(DocumentTable.id),
						name: try record.get(DocumentTable.name),
						updatedAt: Date(timeIntervalSince1970: try record.get(DocumentTable.updatedAt))
					)
				)
				if(!excludeWelcomeSpaceGeneration){
					if(try record.get(DocumentTable.id) == WelcomeSpaceGenerator.WELCOME_SPACE_ID){
						containsWelcomeSpace = true
					}
				}
			}
		}catch{
			print("Failed to fetch List of last used Docs or a column: \(error)")
		}
		
		if(!containsWelcomeSpace){
			res.append(NiDocumentViewModel(id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME))
		}
		return res
	}
	
	private func buildSearchQuery(typedChars: String?, maxNrOfResults: Int? = nil) -> Table{
		var query = DocumentTable.table.select(
			DocumentTable.id,
			DocumentTable.name,
			DocumentTable.updatedAt
		)
		if(typedChars != nil){
			query = query.filter(DocumentTable.name .like("%\(typedChars!)%"))
		}else{
			query = query.order(DocumentTable.updatedAt.desc)
		}
		if(maxNrOfResults != nil){
			query = query.limit(maxNrOfResults!)
		}
		return query
	}
}
