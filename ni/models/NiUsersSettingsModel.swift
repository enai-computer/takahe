//
//  NiUserConfigModel.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation

enum UserSettingKey: String{
	case version, 
		 spaceCachingEnabled,
		 nrOfCachedSpaces,
		 eveEnabled,
		 cacheClearedLast,
		 demoMode,
		 pinnedWebApps
}

struct NiUsersSettingsModel: Codable{
	let version: Int
	let spaceCachingEnabled: Bool
	let nrOfCachedSpaces: Int
	let eveEnabled: Bool
	let cacheClearedLast: Date
	let demoMode: Bool
	let pinnedWebApps: [WebAppItemModel]
}

extension NiUsersSettingsModel{
	
	/** init with defaults
	 */
	init(){
		version = 1	//version to be increased after every breaking change
		spaceCachingEnabled = false
		nrOfCachedSpaces = 3
		eveEnabled = false
		cacheClearedLast = Date(timeIntervalSince1970: 0.0)
		demoMode = false
		pinnedWebApps = []
	}
	
	init(from dic: [String: String]) throws{
		version = try getValueOrThrow(key: .version, from: dic)
		spaceCachingEnabled = try getValueOrThrow(key: .spaceCachingEnabled, from: dic)
		nrOfCachedSpaces = try getValueOrThrow(key: .nrOfCachedSpaces, from: dic)
		eveEnabled = try getValueOrThrow(key: .eveEnabled, from: dic)
		cacheClearedLast = try getValueOrThrow(key: .cacheClearedLast, from: dic)
		demoMode = getValueOrDefault(key: .demoMode, from: dic, defaultVal: false)
		pinnedWebApps = getValueOrEmptyList(key: .pinnedWebApps, from: dic, of: WebAppItemModel.self)
	}
	
	func toDic() -> [UserSettingKey: String]{
		return [
			.version: String(version),
			.spaceCachingEnabled: String(spaceCachingEnabled),
			.nrOfCachedSpaces: String(nrOfCachedSpaces),
			.eveEnabled: String(eveEnabled),
			.cacheClearedLast: String(cacheClearedLast.timeIntervalSince1970),
			.pinnedWebApps: encodeToJsonString(pinnedWebApps)
		]
	}
	
	func appendSetting(setting: UserSettingKey, with element: WebAppItemModel) -> String{
		if(setting != .pinnedWebApps){
			fatalError("appending Setting \(setting) is not implemented")
		}
		return encodeToJsonString(pinnedWebApps + [element])
	}
			
}


enum NiUsersSettingsModelError: Error{
	case initErrorOn(setting: String)
}

private func getValueOrThrow(key: UserSettingKey, from dic: [String: String]) throws -> Int{
	if let valStr: String = dic[key.rawValue]{
		
		return try Int(valStr) ?? {
			throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
		}()
	}
	throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
}

private func getValueOrThrow(key: UserSettingKey, from dic: [String: String]) throws -> Bool{
	if let valStr: String = dic[key.rawValue]{
		
		return try Bool(valStr) ?? {
			throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
		}()
	}
	throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
}

private func getValueOrThrow(key: UserSettingKey, from dic: [String: String]) throws -> Date{
	if let valStr: String = dic[key.rawValue]{
		let dateInDouble: Double = try Double(valStr) ?? {
			throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
		}()
		return Date(timeIntervalSince1970: dateInDouble)
	}
	throw NiUsersSettingsModelError.initErrorOn(setting: key.rawValue)
}

private func getValueOrDefault(key: UserSettingKey, from dic: [String: String], defaultVal: Bool) -> Bool{
	if let valStr: String = dic[key.rawValue]{
		return Bool(valStr) ?? defaultVal
	}
	return defaultVal
}

private func getValueOrEmptyList<T>(key: UserSettingKey, from dic: [String: String], of type: T.Type) -> [T] where T : Decodable
{
	do{
		let jsonDecoder = JSONDecoder()
		if let data: Data = dic[key.rawValue]?.data(using: .utf8){
			let docModel = try jsonDecoder.decode([T].self, from: data)
			return docModel
		}
	}catch{}
	
	return []
}

private func encodeToJsonString<T>(_ toEncode: [T]) -> String where T: Encodable{
	do{
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		let jsonData = try jsonEncoder.encode(toEncode)
		return String(data: jsonData, encoding: .utf8) ?? "[]"
	}catch{}
	return "[]"
}
