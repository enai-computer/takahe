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

func getNSSizeFrom(width: NSNumber?, height: NSNumber?) -> NSSize?{
	guard let width: Double = width?.doubleValue else{return nil}
	guard let height: Double = height?.doubleValue else{return nil}
	return NSSize(width: width, height: height)
}

func maxSize(enclosingFrameSize: CGSize, subFrame: CGSize, margin: CGFloat) -> CGSize{
	var resultingSize = subFrame
	let maxHeight = enclosingFrameSize.height - margin * 2
	let maxWidth = enclosingFrameSize.width - margin * 2
	
	if maxHeight < subFrame.height{
		resultingSize.height = maxHeight
	}
	if maxWidth < subFrame.width{
		resultingSize.width = maxWidth
	}
	return resultingSize
}

func centeredFrameOrigin(enclosingRect: NSRect, subFrame: CGSize, margin: CGFloat) -> CGPoint{
	
	let x_center: CGFloat = enclosingRect.origin.x + enclosingRect.width / 2
	let y_center: CGFloat = enclosingRect.origin.y + enclosingRect.height / 2
	
	
	let x_dist_to_center = subFrame.width / 2
	let y_dist_to_center = subFrame.height / 2
	
	var yOrigin = (y_center - y_dist_to_center)
	if(yOrigin < margin){
		yOrigin = margin
	}
	var xOrigin = (x_center-x_dist_to_center)
	if(xOrigin < margin){
		xOrigin = margin
	}
	return CGPoint(x: xOrigin, y: yOrigin)
}
