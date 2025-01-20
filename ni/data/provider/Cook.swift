//
//  Cook.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Foundation
import SQLite
import PostHog


enum NiSearchResultType{
	case niSpace, pinnedWebsite, eve, group, web, pdf, note
	
	func isContentItem() -> Bool{
		switch(self){
			case .niSpace, .group, .eve:
				return false
			default:
				return true
		}
	}
}

struct NiSearchResultItem: Equatable{
	let type: NiSearchResultType
	let id: UUID?
	let name: String
	let data: Any?
	
	static func == (lhs: NiSearchResultItem, rhs: NiSearchResultItem) -> Bool {
		return lhs.type == rhs.type && lhs.id == rhs.id && lhs.name == rhs.name
	}
}

struct NiSRIOriginData{
	let id: UUID
	let name: String
}


/** Named after Captain James Cook
 
 */
class Cook{
	
	static let instance = Cook()
	
	
	func search(typedChars: String?,
				maxNrOfResults: Int? = nil,
				excludeWelcomeSpaceGeneration: Bool = true,
				giveCreateNewSpaceOption: Bool = false,
				insertWelcomeSpaceGenFirst: Bool = false,
				returnAskEnaiOption: Bool = true,
				currentSpaceId: UUID? = nil
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
			let searchStr = typedChars!.lowercased()
			res = res.sorted{compareResult(r0: $0, r1: $1, searchStr: searchStr, currentSpaceId: currentSpaceId)}
			
			res.append(NiSearchResultItem(type: .niSpace, id: NiSpaceDocumentController.EMPTY_SPACE_ID, name: "Create a new space", data: nil))
			
			let wordCount = countWords(in: typedChars!)
			if(PostHogSDK.shared.isFeatureEnabled("en-ai") && 4 < wordCount && returnAskEnaiOption){
				let askEveResultItem = NiSearchResultItem(type: .eve, id: nil, name: "Ask Enai", data: nil )
				if(wordCount < 8){
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
	
	/**
	 returns true if its first argument should be ordered before its second argument; otherwise, false.
	 
	 Desired order:
		 1. spaces
		 2. groups
		 3. content items
		 4. sub-order:
			names/titles that start with the search string first.
			others that contain that string 2nd
	 */
	private func compareResult(r0: NiSearchResultItem, r1: NiSearchResultItem, searchStr: String, currentSpaceId: UUID?) -> Bool{
		if(r0.type == .niSpace && r1.type != .niSpace){
			return true
		}
		if(r1.type == .niSpace && r0.type != .niSpace){
			return false
		}
		if let currentSpaceId: UUID = currentSpaceId{
			if let result: Bool = resultsInSameSpaceReorder(r0: r0, r1: r1, currentSpaceId: currentSpaceId){
				return result
			}
		}
		if(r1.name.lowercased().starts(with: searchStr)){
			return false
		}
		return true
	}
	
	/**
	 checks if the two results are content items and if yes checks if one of them is in the same space. If thats the case true if in correct order otherwise false. Nil if both are not in the same space
	 */
	private func resultsInSameSpaceReorder(
		r0: NiSearchResultItem, r1: NiSearchResultItem, currentSpaceId: UUID
	) -> Bool?{
		guard (r0.type.isContentItem() && r1.type.isContentItem()) else {
			return nil
		}
		guard let d0 = r0.data as? NiSRIOriginData else {return nil}
		guard let d1 = r1.data as? NiSRIOriginData else {return nil}

		guard (d1.id != d0.id) else {return nil}

		if(d0.id == currentSpaceId){
			return true
		}
		return false
	}
	
	private func searchSpaces(typedChars: String?,
							  maxNrOfResults: Int? = nil,
							  excludeWelcomeSpaceGeneration: Bool,
							  insertWelcomeSpaceGenFirst: Bool
	) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
//		var containsWelcomeSpace: Bool = excludeWelcomeSpaceGeneration

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
//				if(!excludeWelcomeSpaceGeneration){
//					if(try record.get(DocumentTable.id) == WelcomeSpaceGenerator.WELCOME_SPACE_ID){
//						containsWelcomeSpace = true
//					}
//				}
			}
		}catch{
			print("Failed to fetch List of last used Docs or a column: \(error)")
		}

//		if(!containsWelcomeSpace){
//			if(insertWelcomeSpaceGenFirst){
//				res.insert(NiSearchResultItem(type: .niSpace, id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME, data: nil), at: 0)
//			}else{
//				res.append(NiSearchResultItem(type: .niSpace, id: WelcomeSpaceGenerator.WELCOME_SPACE_ID, name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME, data: nil))
//			}
//		}
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
	
	private struct SearchResultContentHash: Hashable{
		let title: String
		let type: NiSearchResultType
		let spaceId: UUID
	}
	
	private func searchContent(_ searchContent: String) -> [NiSearchResultItem]{
		var res: [NiSearchResultItem] = []
		var titleTypeSpaceIdSet: Set<SearchResultContentHash> = []
		do{
			for record in try Storage.instance.spacesDB.prepare(
				buildContentSearchQuery(searchContent)
			){
				if let type = contentTableTypeToNiSearchResultType(
					type: try record.get(ContentTable.table[ContentTable.type])
				){
					let name = try record.get(ContentTable.table[ContentTable.title]) ?? ""
					if(name.contains("Google Search")){
						continue
					}
					let spaceId = try record.get(DocumentTable.table[DocumentTable.id])
					
					//Users might have multiple tabs with the same title in the same space. For now we are filtering out these duplicates.
					let newResult = titleTypeSpaceIdSet.insert(SearchResultContentHash(title: name, type: type, spaceId: spaceId))
					if(!newResult.inserted){
						continue
					}
					res.append(
						NiSearchResultItem(
							type: type,
							id: try record.get(ContentTable.table[ContentTable.id]),
							name: name,
							data: NiSRIOriginData(
								id: spaceId,
								name: try record.get(DocumentTable.table[DocumentTable.name])
							)
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
			DocumentTable.table[DocumentTable.id],
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
						data: NiSRIOriginData(
							id: try record.get(DocumentTable.table[DocumentTable.id]),
							name: try record.get(DocumentTable.table[DocumentTable.name])
						)
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
			DocumentTable.table[DocumentTable.id],
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
