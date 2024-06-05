//
//  Cook.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Foundation


/** Named after Captain James Cook
 
 */
class Cook{
	
	static let instance = Cook()
	
	//TBD:
	func search(){}
	
	func searchSpaces(typedChars: String, maxNrOfResults: Int = 10, excludeWelcomeSpaceGeneration: Bool = true) -> [NiDocumentViewModel]{
		var res: [NiDocumentViewModel] = []
		var containsWelcomeSpace: Bool = excludeWelcomeSpaceGeneration
		do{
			for record in try Storage.instance.spacesDB.prepare(
				DocumentTable.table.select(
					DocumentTable.id,
					DocumentTable.name,
					DocumentTable.updatedAt
				)
				.filter(DocumentTable.name .like("%\(typedChars)%"))
				.limit(maxNrOfResults)
				.order(DocumentTable.updatedAt.desc)
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
}
