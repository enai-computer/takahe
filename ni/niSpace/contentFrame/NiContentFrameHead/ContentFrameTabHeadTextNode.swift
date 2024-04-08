//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 5/4/24.
//

import Foundation
import Cocoa

class ContentFrameTabHeadTextNode: NSTextField{
	
	var urlStr: String = ""
	var parentView: NSView?
	var parentController: ContentFrameTabHead?
	
	var defaultSize: CGSize?
	
	override func mouseDown(with event: NSEvent) {
		if(event.clickCount == 1){
			parentController?.selectSelf()
		}
		
		if(event.clickCount == 2){
			self.isEditable = true
			self.stringValue = urlStr
			
			defaultSize = parentView?.frame.size
			var nSize = parentView?.frame.size
			if(nSize != nil){
				nSize?.width = CGFloat(urlStr.count) * 8.0 + 30
				parentView!.frame.size = nSize!
			}
			self.currentEditor()?.moveToEndOfLine(nil)
		}
	}
	
	override func textDidEndEditing(_ notification: Notification) {
		do{
			try self.parentController?.loadWebsite(newURL: self.stringValue)
			
			if(defaultSize != nil){
				parentView?.frame.size = defaultSize!
			}
		}catch{
			print("Failed to load website, due to " + error.localizedDescription)
		}
	}
}
