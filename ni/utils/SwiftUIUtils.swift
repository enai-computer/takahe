//
//  SwiftUIUtils.swift
//  ni
//
//  Created by Patrick Lukas on 6/5/24.
//

import SwiftUI

/*
 * MARK: - View extension
 */
extension View {
	
	/**
	 * Example:
	 *	var body: some view {
	 *		myView
	 *			.if(X) { $0.buttonStyle(.bordered) }
	 *	}
	 */
	@ViewBuilder
	func `if`<Transform: View>(
	  _ condition: Bool,
	  transform: (Self) -> Transform
	) -> some View {
	  if condition {
		transform(self)
	  } else {
		self
	  }
	}
	
	/**
	 * Example:
	 *	var body: some view {
	 *		myView
	 *			.if(X) { $0.buttonStyle(.bordered) } else: { $0.buttonStyle(.borderedProminent) }
	 *	}
	 */
	@ViewBuilder
	func `if`<TrueContent: View, FalseContent: View>(
	  _ condition: Bool,
	  if ifTransform: (Self) -> TrueContent,
	  else elseTransform: (Self) -> FalseContent
	) -> some View {
	  if condition {
		ifTransform(self)
	  } else {
		elseTransform(self)
	  }
	}
}

// defines OptionSet, which corners to be rounded – same as UIRectCorner
struct RectCorner: OptionSet {
	
	let rawValue: Int
		
	static let topLeft = RectCorner(rawValue: 1 << 0)
	static let topRight = RectCorner(rawValue: 1 << 1)
	static let bottomRight = RectCorner(rawValue: 1 << 2)
	static let bottomLeft = RectCorner(rawValue: 1 << 3)
	
	static let allCorners: RectCorner = [.topLeft, topRight, .bottomLeft, .bottomRight]
}


// draws shape with specified rounded corners applying corner radius
struct RoundedCornersShape: Shape {
	
	var radius: CGFloat = .zero
	var corners: RectCorner = .allCorners

	func path(in rect: CGRect) -> Path {
		var path = Path()

		let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
		let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

		let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
		let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

		let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
		let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

		let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
		let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )

		
		path.move(to: p1)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
					tangent2End: p2,
					radius: radius)
		path.addLine(to: p3)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
					tangent2End: p4,
					radius: radius)
		path.addLine(to: p5)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
					tangent2End: p6,
					radius: radius)
		path.addLine(to: p7)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
					tangent2End: p8,
					radius: radius)
		path.closeSubpath()

		return path
	}
}

// View extension, to be used like modifier:
// SomeView().roundedCorners(radius: 20, corners: [.topLeft, .bottomRight])
extension View {
	func roundedCorners(radius: CGFloat, corners: RectCorner) -> some View {
		clipShape( RoundedCornersShape(radius: radius, corners: corners) )
	}
}

