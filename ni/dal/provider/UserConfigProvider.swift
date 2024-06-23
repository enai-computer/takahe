//
//  UserConfigProvider.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation

private let CONFIG_NAME = "userConfig.json"

class UserConfigProvider {
	
	let userConfig: NiUserConfigModel
	
	init(configPath: String){
		if let config = UserConfigProvider.tryLoadConfigFromFile(configPath){
			self.userConfig = config
		}else{
			self.userConfig = NiUserConfigModel()
		}
	}
	
	private static func tryLoadConfigFromFile(_ path: String) -> NiUserConfigModel?{
		do{
			let path = URL(fileURLWithPath: (path + CONFIG_NAME))
			if let jsonDoc: NSData = NSData(contentsOf: path){
				let jsonDecoder = JSONDecoder()
				let docModel = try jsonDecoder.decode(NiUserConfigModel.self, from: jsonDoc as Data)
				return docModel
			}
		}catch{
			return nil
		}
		return nil
	}
	
}
