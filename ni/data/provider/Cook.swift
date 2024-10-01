//
//  Cook.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Foundation
import SQLite


enum NiSearchResultType{
	case niSpace, pinnedWebsite, eve, group, web, pdf, note
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
	
	
	func search(typedChars: String?,
				maxNrOfResults: Int? = nil,
				excludeWelcomeSpaceGeneration: Bool = true,
				giveCreateNewSpaceOption: Bool = false,
				insertWelcomeSpaceGenFirst: Bool = false
	) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []

		res.append(contentsOf: searchSpaces(
			typedChars: typedChars,
			excludeWelcomeSpaceGeneration: excludeWelcomeSpaceGeneration,
			insertWelcomeSpaceGenFirst: insertWelcomeSpaceGenFirst )
		)
		
		if let searchStr = typedChars{
			if(1 < searchStr.count){
				res.append(contentsOf: searchGroups(searchStr))
			}
			if(2 < searchStr.count){
				res.append(contentsOf: searchContent(searchStr))
			}
		}
		
		//MARK: sorting
		if(giveCreateNewSpaceOption && typedChars != nil && !typedChars!.isEmpty){
			//FIXME: hacky sorting solution
			res = res.sorted{
				if($1.name.lowercased().starts(with: typedChars!.lowercased())){
					return false
				}
				return true
			}
			res.append(NiSearchResultItem(type: .niSpace, id: NiSpaceDocumentController.EMPTY_SPACE_ID, name: "Create a new space", data: nil))
			
			let wordCount = countWords(in: typedChars!)
			if(UserSettings.shared.eveEnabled && 1 < wordCount){
				let askEveResultItem = NiSearchResultItem(type: .eve, id: nil, name: "Ask Eve", data: nil )
				if(wordCount == 2){
					res.append(askEveResultItem)
				}else{
					res.insert(askEveResultItem, at: 0)
				}
			}
			if(UserSettings.shared.demoMode){
				res.append(NiSearchResultItem(type: .niSpace, id: NiSpaceDocumentController.DEMO_GEN_SPACE_ID, name: "Generate a new space", data: nil))
			}
		}
		return res
	}
	
	private func searchSpaces(typedChars: String?,
							  maxNrOfResults: Int? = nil,
							  excludeWelcomeSpaceGeneration: Bool,
							  insertWelcomeSpaceGenFirst: Bool
	) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
		var containsWelcomeSpace: Bool = excludeWelcomeSpaceGeneration

		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildSpacesSearchQuery(typedChars: typedChars, maxNrOfResults: maxNrOfResults)
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
		return res
	}
	
	private func buildSpacesSearchQuery(typedChars: String?, maxNrOfResults: Int? = nil) -> Table{
		var query = DocumentTable.table.select(
			DocumentTable.id,
			DocumentTable.name,
			DocumentTable.updatedAt
		)
		if(typedChars != nil){
			query = query.filter(
				DocumentTable.name.like("\(typedChars!)%")
				|| DocumentTable.name.like("% \(typedChars!)%")
			)
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
	
	private func searchContent(_ searchContent: String) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
		
		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildContentSearchQuery(searchContent)
			){
				if let type = contentTableTypeToNiSearchResultType(
					type: try record.get(ContentTable.table[ContentTable.type])
				){
					res.append(
						NiSearchResultItem(
							type: type,
							id: try record.get(ContentTable.table[ContentTable.id]),
							name: try record.get(ContentTable.table[ContentTable.title]) ?? "",
							data: try record.get(DocumentTable.table[DocumentTable.name])
						)
					)
				}

			}
		}catch{
			print(error)
		}
		
		return res
	}
	
	private func buildContentSearchQuery(_ searchStr: String) -> Table{
		return ContentTable.table.select(
			ContentTable.table[ContentTable.id],
			ContentTable.table[ContentTable.title],
			ContentTable.table[ContentTable.type],
			DocumentTable.table[DocumentTable.name]
		)
		.join(
			DocumentIdContentIdTable.table,
			on: DocumentIdContentIdTable.contentId == ContentTable.table[ContentTable.id]
		)
		.join(
			DocumentTable.table,
			on: DocumentIdGroupIdTable.documentId == DocumentTable.table[DocumentTable.id])
		.filter(
			ContentTable.table[ContentTable.title].like("\(searchStr)%")
			|| ContentTable.table[ContentTable.title].like("% \(searchStr)%")
		)
		.order(ContentTable.table[ContentTable.updatedAt].desc)
	}
	
	private func contentTableTypeToNiSearchResultType(type: String) -> NiSearchResultType?{
		let contentTabletype = ContentTableRecordType(rawValue: type)
		switch(contentTabletype){
			case .img:
				return nil
			case .note:
				return nil
			case .pdf:
				return .pdf
			case .web:
				return .web
			case .none:
				return nil
		}
	}
	
	private func searchGroups(_ searchStr: String) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildGroupSearchQuery(searchStr)
			){
				res.append(
					NiSearchResultItem(
						type: .group,
						id: try record.get(GroupTable.table[GroupTable.id]),
						name: try record.get(GroupTable.table[GroupTable.name]),
						data: try record.get(DocumentTable.table[DocumentTable.name])
					)
				)
			}
		}catch{
			print(error)
		}
		return res
	}
	
	private func buildGroupSearchQuery(_ searchStr: String) -> Table{
		return GroupTable.table.select(
			GroupTable.table[GroupTable.id],
			GroupTable.table[GroupTable.name],
			DocumentTable.table[DocumentTable.name]
		)
		.join(
			DocumentIdGroupIdTable.table,
			on: DocumentIdGroupIdTable.groupId == GroupTable.table[GroupTable.id]
		)
		.join(
			DocumentTable.table,
			on: DocumentIdGroupIdTable.documentId == DocumentTable.table[DocumentTable.id])
		.filter(
			GroupTable.table[GroupTable.name].like("\(searchStr)%")
			|| GroupTable.table[GroupTable.name].like("% \(searchStr)%")
		)
		.order(GroupTable.table[GroupTable.updatedAt].desc)
		
	}
	
	func countWords(in text: String) -> Int {
		let components = text.components(separatedBy: .whitespacesAndNewlines)
		return components.filter { !$0.isEmpty }.count
	}
//
//	let preConfigedWebApps: [String: URL] = [
//		"nebula": URL(string: "https://nebula.tv/featured")!,
//		"HBO Max": URL(string: "https://www.max.com/")!,
//		"YouTube": URL(string: "https://www.youtube.com/")!,
//		"Curiosity Stream": URL(string: "https://curiositystream.com/")!,
//		"Disney+": URL(string: "https://www.disneyplus.com/")!,
//		"Paramount+": URL(string: "https://www.paramountplus.com")!,
//		"hulu": URL(string: "https://www.hulu.com")!,
//		"Netflix": URL(string: "https://www.netflix.com")!
//	]
//	
////	//FIXME: very hacky - needs to be done properly
//	private func getWebApps(_ searchTerm: String) -> [NiSearchResultItem]{
//		var res: [NiSearchResultItem] = []
//		for item in preConfigedWebApps.keys{
//			if(item.lowercased().starts(with: searchTerm.lowercased())){
//				let data = preConfigedWebApps[item]
//				res.append(
//					NiSearchResultItem(type: .video, id: nil, name: item, data: data)
//				)
//			}
//		}
//		return res
//	}
}
