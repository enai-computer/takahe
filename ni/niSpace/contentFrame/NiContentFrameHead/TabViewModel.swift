//
//  TabHeadViewModel.swift
//  ni
//
//  Created by Patrick Lukas on 10/4/24.
//

import Cocoa
import Foundation

enum TabViewModelState: String{
	case empty, error, notLoaded, loading, loaded, cached
}

struct TabViewModel{
	let contentId: UUID
	let type: TabContentType

	var title: String = ""
	var content: String = ""
	var source: String?
	var state: TabViewModelState = .empty
	var icon: NSImage?
	var data: Any?
	
	var viewItem: CFContentItem?
	var webView: NiWebView? {return self.viewItem as? NiWebView? ?? nil}
	var noteView: NiNoteItem? {return self.viewItem as? NiNoteItem ?? nil}
	var imgView: NiImgView? {return self.viewItem as? NiImgView ?? nil}
	var pdfView: NiPdfView? {return self.viewItem as? NiPdfView ?? nil}
	
	var position: Int = -1
	var isSelected: Bool = false
	var inEditingMode: Bool = false
}
