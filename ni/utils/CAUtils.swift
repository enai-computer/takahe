//
//  CAUtils.swift
//  ni
//
//  Created by Patrick Lukas on 20/6/24.
//

import Foundation
import AppKit

/** overlay on a view to round the corners of the subviews (z-layer needs to be above the subview)
 
 example:
 ```
 let border = CAShapeLayer()
 border.path = CGInvertedRoundedRect(outerRect: searchResultsScrollContainer.contentView.bounds, innerRect: layerRect, innerRectRadius: 10.0).cgPath
 border.frame = layerRect
 border.fillColor = NSColor.birkin.cgColor
 border.fillRule = .evenOdd
 ```
 */
class CGInvertedRoundedRect: NSObject{

	let cgPath: CGPath
	
	init(outerRect: NSRect, innerRect: NSRect, innerRectRadius: CGFloat) {
		let path = CGMutablePath()
		
		let outerPath = NSBezierPath(rect: outerRect)
		let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: innerRectRadius, yRadius: innerRectRadius)
		
		path.addPath(outerPath.cgPath)
		path.addPath(innerPath.cgPath)
		
		self.cgPath = path
	}
}
