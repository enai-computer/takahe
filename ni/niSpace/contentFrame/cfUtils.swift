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

func genCollapsedMinimzedStackItems(
	tabs: [TabViewModel],
	handler: CFCollapsedMinimizedView
) -> [NSView]{
	var stackItems: [NSView] = []
	let toManyToDisplay: Bool = 7 < tabs.count
	
	for (i, tab) in tabs.enumerated(){
		if(i == 6 && toManyToDisplay){
			stackItems.append(genPlusXItems(tabs.count - 6))
			break
		}else{
			let itemView = NiAsyncImgView(
				mouseHandler: handler,
				mouseDownContext: tab.position
			)
			
			if let img = tab.icon{
				itemView.setImage(img)
			}else{
				itemView.loadFavIcon(from: tab.content)
			}
			styleCollapsedMinimzedStackItem(itemView)
			stackItems.append(itemView)
		}
	}
	return stackItems
}

private func genPlusXItems(_ nrOfAddItems: Int) -> NSView{
	let item = NSTextField(labelWithString: "+ \(nrOfAddItems)")
	item.frame.size = CGSize(width: 24.0, height: 24.0)
	item.textColor = NSColor.sand115
	item.font = NSFont(name: "Sohne-Buch", size: 16.0)
	
	return item
}

private func styleCollapsedMinimzedStackItem(_ item: NSView){
	item.wantsLayer = true
	item.layer?.cornerRadius = 2.0
	item.layer?.cornerCurve = .continuous
	item.frame.size = CGSize(width: 24.0, height: 24.0)
}
