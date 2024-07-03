//
//  NiViewElementsUtils.swift
//  ni
//
//  Created by Patrick Lukas on 3/7/24.
//

import Foundation

class NiZoomLevels{
	static let levels: [Int: CGFloat] = [
		0 : 0.25,
		1 : 0.33,
		2 : 0.50,
		3 : 0.666,
		4 : 0.75,
		5 : 0.80,
		6 : 0.90,
		7 : 1.00,
		8 : 1.10,
		9 : 1.25,
		10 : 1.50,
		11 : 1.75,
		12 : 2.00,
		13 : 2.50,
		14 : 3.00,
		15 : 4.00,
		16 : 5.00
	]
	static let maxLevel = 16

	static func zoomOut(_ currentLevel: Int) -> (Int, CGFloat){
		if(0 < currentLevel){
			let nxtLevel = currentLevel - 1
			return (nxtLevel, levels[nxtLevel]!)
		}
		return (currentLevel, levels[currentLevel]!)
	}
	
	static func zoomIn(_ currentLevel: Int) -> (Int, CGFloat){
		if(currentLevel < maxLevel){
			let nxtLevel = currentLevel + 1
			return (nxtLevel, levels[nxtLevel]!)
		}
		return (currentLevel, levels[currentLevel]!)
	}
	
	static func defaultZoomLevel() -> (Int, CGFloat){
		return (7, levels[7]!)
	}
}
