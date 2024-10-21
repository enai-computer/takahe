//
//  ContentFrameTabHead+Dragging.swift
//  ni
//
//  Created by Christian Tietze on 21.10.24.
//

import AppKit

extension NSPasteboard.PasteboardType {
	/// Drag type for draggable ``ContentFrameTabHead``s.
	static let tabHeadDragType = NSPasteboard.PasteboardType("io.enai.ni.tab-head")
}
