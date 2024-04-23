//
//  TabHeadViewModel.swift
//  ni
//
//  Created by Patrick Lukas on 10/4/24.
//

import FaviconFinder
import Foundation

enum WebViewState: String{
	case empty, error, loading, loaded, cached
}

struct TabViewModel{
	let contentId: UUID
	
	var title: String = ""
	var url: String = ""
	var state: WebViewState = .empty
	var webView: NiWebView?
	var icon: Favicon?
	
	var position: Int = -1
	var isSelected: Bool = false
	var inEditingMode: Bool = false
}
