//
//  Cook.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Foundation
import SQLite


enum NiSearchResultType{
	case niSpace, webApp
}

struct NiSearchResultItem{
	let type: NiSearchResultType
	let id: UUID?
	let name: String
	let data: Any?
}


/** Named after Captain James Cook
 
 */
class Cook{
	
	static let instance = Cook()
	
	//TBD:
	func search(){}
	
	func searchSpaces(typedChars: String?, 
					  maxNrOfResults: Int? = nil,
					  excludeWelcomeSpaceGeneration: Bool = true,
					  giveCreateNewSpaceOption: Bool = false,
					  insertWelcomeSpaceGenFirst: Bool = false,
					  displayOption: NiSearchViewStyle = .homeView
	) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
		var containsWelcomeSpace: Bool = excludeWelcomeSpaceGeneration
		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildSearchQuery(typedChars: typedChars, maxNrOfResults: maxNrOfResults)
			){
				res.append(
					NiSearchResultItem(
						type: .niSpace,
						id: try record.get(DocumentTable.id),
						name: try record.get(DocumentTable.name),
						data: nil
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
			if(insertWelcomeSpaceGenFirst){
				res.insert(NiSearchResultItem(type: .niSpace, id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME, data: nil), at: 0)
			}else{
				res.append(NiSearchResultItem(type: .niSpace, id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME, data: nil))
			}
		}
		
//		//adding WebApps to search results
//		if(UserSettings.shared.demoMode && typedChars != nil && !typedChars!.isEmpty && displayOption == .palette){
//			res.append(contentsOf: getWebApps(typedChars!))
//		}
		
		//sorting
		if(giveCreateNewSpaceOption && typedChars != nil && !typedChars!.isEmpty){
			//FIXME: hacky sorting solution
			res = res.sorted{
				if($1.name.lowercased().starts(with: typedChars!.lowercased())){
					return false
				}
				return true
			}
			if(UserSettings.shared.demoMode){
				res.append(NiSearchResultItem(type: .niSpace, id: NiSpaceDocumentController.DEMO_GEN_SPACE_ID, name: "Generate a new space", data: nil))
			}
			res.append(NiSearchResultItem(type: .niSpace, id: NiSpaceDocumentController.EMPTY_SPACE_ID, name: "Create a new space", data: nil))
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
			query = query.filter(DocumentTable.name.like("%\(typedChars!)%"))
		}else{
			query = query.order(DocumentTable.updatedAt.desc)
		}
		if(maxNrOfResults != nil){
			query = query.limit(maxNrOfResults!)
		}
		if(UserSettings.shared.demoMode){
			query = query.where(NiSpaceDocumentController.DEMO_GEN_SPACE_ID != DocumentTable.id)
		}
		return query
	}
	
//	//FIXME: very hacky - needs to be done properly
//	private func getWebApps(_ searchTerm: String) -> [NiSearchResultItem]{
//		var res: [NiSearchResultItem] = []
//		for item in preConfigedWebApps.keys{
//			if(item.lowercased().starts(with: searchTerm.lowercased())){
//				let data = preConfigedWebApps[item]
//				res.append(
//					NiSearchResultItem(type: .webApp, id: nil, name: item, data: data)
//				)
//			}
//		}
//		return res
//	}
}
