//
//  TabHeadViewModel.swift
//  ni
//
//  Created by Patrick Lukas on 10/4/24.
//

import Cocoa
import Foundation

enum TabViewModelState: String{
	case empty, error, loading, loaded, cached
}

struct TabViewModel{
	let contentId: UUID
	let type: TabContentType

	var title: String = ""
	var content: String = ""
	var state: TabViewModelState = .empty
	var icon: NSImage?
	
	var view: NSView?
	var webView: NiWebView? {return self.view as? NiWebView? ?? nil}
	var noteView: NiNoteView? {return self.view as? NiNoteView ?? nil}
	
	var position: Int = -1
	var isSelected: Bool = false
	var inEditingMode: Bool = false
}
