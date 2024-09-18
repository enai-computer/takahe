//
//  BilgeWater.swift
//  ni
//
//  Created by Patrick Lukas on 18/9/24.
//

import Foundation

/// https://en.wikipedia.org/wiki/Bilge#Bilge_water
struct BilgeWater: Codable{
	var appStats: WaterAppStats
	var systemStats: WaterSystemStats
	
	var openSpaceAsPersistedOnDisk: NiDocumentObjectModel?
	var openSpaceAsOnScreen: NiDocumentObjectModel?
	var spaceAsOnScreenStats: [String: String]?
}


struct WaterAppStats: Codable{
	//app version
	var releaseVersionNumer: String?
	var buildVersionNumber: String?
	
	//App stats
	var memoryUsedInKBytes: String?
	var threadCount: String?
}

struct WaterSystemStats: Codable{
	var osVersion: String?
	
	var activeProcessorCount: Int?
	var processorCount: Int?
	var isLowerPowerModeEnabled: Bool?
	
	var totalMemoryInGB: String?
	var availableMemoryInMB: String?
	
	var systemUptime: String?
	
	var availableNetworks: String
}
