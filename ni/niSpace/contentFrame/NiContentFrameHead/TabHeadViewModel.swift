//
//  TabHeadViewModel.swift
//  ni
//
//  Created by Patrick Lukas on 10/4/24.
//

import FaviconFinder

struct TabHeadViewModel{
	var title: String = ""
	var url: String = ""
	var webView: NiWebView?
	var icon: Favicon?
	var position: Int = -1
	var isSelected: Bool = false
	var inEditingMode: Bool = false
}
