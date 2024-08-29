//
//  UserConfigProvider.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation


class UserSettings {
	
	static var shared = NiUsersSettingsModel()
	
	static func reload(){
		guard let updatedSettings = UserSettingsTable.getSettings() else {
			UserSettingsTable.setSettings(settings: shared)
			return
		}
		self.shared = updatedSettings
	}
	
	static func updateValue(setting: UserSettingKey, value: Date){
		UserSettingsTable.upsertSetting(setting: setting, value: String(value.timeIntervalSince1970))
		reload()
	}
	
	static func updateValue(setting: UserSettingKey, value: Int){
		UserSettingsTable.upsertSetting(setting: setting, value: String(value))
		reload()
	}
	
	static func updateValue(setting: UserSettingKey, value: Bool){
		UserSettingsTable.upsertSetting(setting: setting, value: String(value))
		reload()
	}
	
	static func appendValue<T>(setting: UserSettingKey, value: T) where T: Encodable{
		let updatedSettingStr = shared.appendSetting(
			setting: setting,
			with: value as! PinnedWebsiteItemModel
		)
		UserSettingsTable.upsertSetting(
			setting: setting,
			value: updatedSettingStr
		)
		reload()
	}
	
	static func removeValue<T>(setting: UserSettingKey, value: T) where T: Encodable{
		let updatedSettingStr = shared.removeSetting(
			setting: setting,
			with: value as! PinnedWebsiteItemModel
		)
		UserSettingsTable.upsertSetting(
			setting: setting,
			value: updatedSettingStr
		)
		reload()
	}
}
