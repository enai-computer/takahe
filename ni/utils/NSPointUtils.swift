//
//  NSPointUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 11/11/24.
//
import Foundation

extension NSPoint{
	func distanceTo(_ other: NSPoint) -> CGFloat{
		var dist_x = (self.x - other.x)
		var dist_y = (self.y - other.y)
		if (dist_y < 0){
			dist_y = dist_y * -1
		}
		if (dist_x < 0){
			dist_x = dist_x * -1
		}
		let dist = dist_y - dist_x
		if (dist < 0){
			return dist * -1
		}
		return dist
	}
	
}
