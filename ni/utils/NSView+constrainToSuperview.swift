//
//  NSView+constrainToSuperview.swift
//  Enai
//
//  Created by Christian Tietze on 17.11.24.
//

import AppKit

extension NSView {
	func addConstraintsToFillSuperview(edgeInsets: NSEdgeInsets = .zero) {
		guard let superview = self.superview else { preconditionFailure("superview has to be set first") }

		self.translatesAutoresizingMaskIntoConstraints = false

		// Direction (+/−) is important: to inset e.g. on the right in left-to-right layouts, the value needs to be negative to "subtract" from maxX and not extend beyond the container.

		NSLayoutConstraint.activate([
			self.leftAnchor.constraint(equalTo: superview.leftAnchor,
									   constant: edgeInsets.left),
			self.rightAnchor.constraint(equalTo: superview.rightAnchor,
										constant: -edgeInsets.right),

			self.topAnchor.constraint(equalTo: superview.topAnchor,
									  constant: edgeInsets.top),
			self.bottomAnchor.constraint(equalTo: superview.bottomAnchor,
										 constant: -edgeInsets.bottom),
		])
	}
}

extension NSEdgeInsets {
	static var zero: NSEdgeInsets { .init(top: 0, left: 0, bottom: 0, right: 0) }

	init(allSides value: CGFloat) {
		self.init(top: value, left: value, bottom: value, right: value)
	}

	init(horizontal: CGFloat, vertical: CGFloat) {
		self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
	}
}
