//
//  UserSettingsTable.swift
//  ni
//
//  Created by Patrick Lukas on 17/7/24.
//

import Foundation
import SQLite

class UserSettingsTable{
	
	static let table = Table("user_settings")
	static let setting = Expression<String>("setting")
	static let value = Expression<String>("value")
	static let updatedAt = Expression<Double>("updated_at")
	
	static func create(db: Connection) throws{
		try db.run(table.create(ifNotExists: true){ t in
			t.column(setting, primaryKey: true)
			t.column(value)
			t.column(updatedAt)
		})
	}
	
	static func upsertSetting(setting: UserSettingKey, value: String?){
		guard let absolutValue: String = value else {return}
		do{
			try Storage.instance.spacesDB.run(
				table.upsert(
					self.setting <- setting.rawValue,
					self.value <- absolutValue,
					self.updatedAt <- Date().timeIntervalSince1970,
					onConflictOf: self.setting
				)
			)
		}catch{
			print("failed to update settings table with: \(error)")
		}
	}
	
	static func setSettings(settings: NiUsersSettingsModel){
		let settingsDic = settings.toDic()
		for setting in settingsDic{
			upsertSetting(setting: setting.key, value: setting.value)
		}
	}
	
	static func getSettings() -> NiUsersSettingsModel?{
		do{
			var resDic: [String: String] = [:]
			for row in try Storage.instance.spacesDB.prepare(table){
				resDic[row[self.setting]] = row[self.value]
			}
			if(resDic.isEmpty){
				return nil
			}
			return try NiUsersSettingsModel(from: resDic)
		}catch{
			print("failed to fetch user settings with \(error)")
		}
		return nil
	}
}
