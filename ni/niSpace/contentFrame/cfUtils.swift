//
//  cfUtils.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

func genMinimizedStackItems(tabs: [TabViewModel], owner: Any?) -> [CFMinimizedStackItem]{
	
	var stackItems: [CFMinimizedStackItem] = []
	
	for tab in tabs {
		let itemView = (NSView.loadFromNib(nibName: "CFMinimizedStackItem", owner: owner) as! CFMinimizedStackItem)
		itemView.setItemData(position: tab.position, title: tab.title, icon: tab.icon)
		stackItems.append(itemView)
	}
	
	return stackItems
}
