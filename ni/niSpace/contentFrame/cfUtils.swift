//
//  cfUtils.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa
import FaviconFinder

func genMinimizedStackItems(tabs: [TabViewModel], owner: Any?) -> [CFMinimizedStackItem]{
	
	var stackItems: [CFMinimizedStackItem] = []
	
	for tab in tabs {
		let itemView = (NSView.loadFromNib(nibName: "CFMinimizedStackItem", owner: owner) as! CFMinimizedStackItem)
		let url = tab.webView?.url?.absoluteString ?? tab.content
		itemView.setItemData(position: tab.position, title: tab.title, icon: tab.icon, urlStr: url)
		stackItems.append(itemView)
	}

	if(stackItems.count == 1){
		stackItems.first?.setRoundedCorners(.all)
	}else{
		stackItems.first?.setRoundedCorners(.top)
		stackItems.last?.setRoundedCorners(.bottom)
	}

	return stackItems
}
