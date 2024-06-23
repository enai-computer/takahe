//
//  NiUserConfigModel.swift
//  ni
//
//  Created by Patrick Lukas on 23/6/24.
//

import Foundation

struct NiUserConfigModel: Codable{
	
	let nrOfCachedSpaces: Int
	let eveEnabled: Bool
}

extension NiUserConfigModel{
	
	/** init with defaults
	 */
	init(){
		nrOfCachedSpaces = 2
		eveEnabled = false
	}
}
