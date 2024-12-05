//
//  NiUserConfigModel.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation
import CoreLocation

enum UserSettingKey: String{
	case version, 
		 spaceCachingEnabled,
		 nrOfCachedSpaces,
		 eveEnabled,
		 cacheClearedLast,
		 demoMode,
		 pinnedWebApps,	//maps to pinnedWebsites --- DB migration needed for renaming
		 userFirstName,
		 userEmail,
		 homeViewWeatherLocation,
		 onlineSync,
		 showedOnboarding
}

struct NiUsersSettingsModel: Codable{
	let isDefaultConfig: Bool
	let version: Int
	let spaceCachingEnabled: Bool
	let nrOfCachedSpaces: Int
	let eveEnabled: Bool
	let cacheClearedLast: Date
	let demoMode: Bool
	let pinnedWebsites: [PinnedWebsiteItemModel]
	let userFirstName: String
	let userEmail: String?
	let homeViewWeatherLocation: WeatherLocationModel
	let onlineSync: Bool
	let	showedOnboarding: Bool
}

let defaultWeatherLocation = WeatherLocationModel(city: "Berlin", country: "Germany", coordinates: CLLocation(latitude: 52.5200, longitude: 13.4050))

extension NiUsersSettingsModel{
	
	/** init with defaults
	 */
	init(){
		isDefaultConfig = true
		version = 1	//version to be increased after every breaking change
		spaceCachingEnabled = false
		nrOfCachedSpaces = 3
		eveEnabled = false
		cacheClearedLast = Date(timeIntervalSince1970: 0.0)
		demoMode = false
		pinnedWebsites = []
		userFirstName = NSUserName()
		userEmail = nil
		homeViewWeatherLocation = defaultWeatherLocation
		onlineSync = false
		showedOnboarding = false
	}
	
	init(from dic: [String: String]) throws{
		isDefaultConfig = false
		version = try getValueOrThrow(key: .version, from: dic)
		spaceCachingEnabled = try getValueOrThrow(key: .spaceCachingEnabled, from: dic)
		nrOfCachedSpaces = try getValueOrThrow(key: .nrOfCachedSpaces, from: dic)
		eveEnabled = try getValueOrThrow(key: .eveEnabled, from: dic)
		cacheClearedLast = try getValueOrThrow(key: .cacheClearedLast, from: dic)
		demoMode = getValueOrDefault(key: .demoMode, from: dic, defaultVal: false)
		pinnedWebsites = getValueOrEmptyList(key: .pinnedWebApps, from: dic, of: PinnedWebsiteItemModel.self)
		userFirstName = getValueOrDefault(key: .userFirstName, from: dic, defaultVal: NSUserName()) ?? ""
		userEmail = getValueOrDefault(key: .userEmail, from: dic, defaultVal: nil)
		homeViewWeatherLocation = getStructValueOrDefault(key: .homeViewWeatherLocation, from: dic, defaultVal: defaultWeatherLocation)
		onlineSync = getValueOrDefault(key: .onlineSync, from: dic, defaultVal: false)
		showedOnboarding = getValueOrDefault(key: .showedOnboarding, from: dic, defaultVal: true)
	}
	
	func toDic() -> [UserSettingKey: String?]{
		return [
			.version: String(version),
			.spaceCachingEnabled: String(spaceCachingEnabled),
			.nrOfCachedSpaces: String(nrOfCachedSpaces),
			.eveEnabled: String(eveEnabled),
			.cacheClearedLast: String(cacheClearedLast.timeIntervalSince1970),
			.pinnedWebApps: encodeListToJsonString(pinnedWebsites),
			.userFirstName: userFirstName,
			.userEmail: userEmail,
			.homeViewWeatherLocation: encodeToJsonString(homeViewWeatherLocation),
			.onlineSync: String(onlineSync),
			.showedOnboarding: String(showedOnboarding)
		]
	}
	
	func appendSetting(setting: UserSettingKey, with element: PinnedWebsiteItemModel) -> String{
		if(setting != .pinnedWebApps){
			fatalError("appending Setting \(setting) is not implemented")
		}
		return encodeListToJsonString(pinnedWebsites + [element])
	}
	
	func removeSetting(setting: UserSettingKey, with element: PinnedWebsiteItemModel) -> String{
		if(setting != .pinnedWebApps){
			fatalError("appending Setting \(setting) is not implemented")
		}
		let filteredApp = pinnedWebsites.filter({$0 != element})
		return encodeListToJsonString(filteredApp)
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

private func getValueOrDefault(key: UserSettingKey, from dic: [String: String], defaultVal: String?) -> String?{
	if let valStr: String = dic[key.rawValue]{
		return valStr
	}
	return defaultVal
}

private func getStructValueOrDefault<T>(key: UserSettingKey, from dic: [String: String], defaultVal: T) -> T where T : Decodable{
	do{
		let jsonDecoder = JSONDecoder()
		if let data: Data = dic[key.rawValue]?.data(using: .utf8){
			let docModel = try jsonDecoder.decode(T.self, from: data)
			return docModel
		}
	}catch{}
	return defaultVal
}


func encodeToJsonString<T>(_ toEncode: T) -> String where T: Encodable{
	do{
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		let jsonData = try jsonEncoder.encode(toEncode)
		return String(data: jsonData, encoding: .utf8) ?? ""
	}catch{}
	return ""
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

private func encodeListToJsonString<T>(_ toEncode: [T]) -> String where T: Encodable{
	do{
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		let jsonData = try jsonEncoder.encode(toEncode)
		return String(data: jsonData, encoding: .utf8) ?? "[]"
	}catch{}
	return "[]"
}
