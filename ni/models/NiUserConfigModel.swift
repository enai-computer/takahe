//
//  NiUserConfigModel.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation

struct NiUserConfigModel: Codable{
	
	let spaceCachingEnabled: Bool
	let nrOfCachedSpaces: Int
	let eveEnabled: Bool
}

extension NiUserConfigModel{
	
	/** init with defaults
	 */
	init(){
		spaceCachingEnabled = false
		nrOfCachedSpaces = 3
		eveEnabled = false
	}
}
