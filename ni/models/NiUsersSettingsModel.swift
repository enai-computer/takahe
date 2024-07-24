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
		 demoMode
}

struct NiUsersSettingsModel: Codable{
	let version: Int
	let spaceCachingEnabled: Bool
	let nrOfCachedSpaces: Int
	let eveEnabled: Bool
	let cacheClearedLast: Date
	let demoMode: Bool
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
	}
	
	init(from dic: [String: String]) throws{
		version = try getValueOrThrow(key: .version, from: dic)
		spaceCachingEnabled = try getValueOrThrow(key: .spaceCachingEnabled, from: dic)
		nrOfCachedSpaces = try getValueOrThrow(key: .nrOfCachedSpaces, from: dic)
		eveEnabled = try getValueOrThrow(key: .eveEnabled, from: dic)
		cacheClearedLast = try getValueOrThrow(key: .cacheClearedLast, from: dic)
		demoMode = getValueOrDefault(key: .demoMode, from: dic, defaultVal: false)
	}
	
	func toDic() -> [UserSettingKey: String]{
		return [
			.version: String(version),
			.spaceCachingEnabled: String(spaceCachingEnabled),
			.nrOfCachedSpaces: String(nrOfCachedSpaces),
			.eveEnabled: String(eveEnabled),
			.cacheClearedLast: String(cacheClearedLast.timeIntervalSince1970)
		]
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
