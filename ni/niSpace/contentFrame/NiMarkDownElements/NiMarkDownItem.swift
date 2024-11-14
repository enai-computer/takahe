//
//  NiMarkDownItem.swift
//  Enai
//
//  Created by Patrick Lukas on 13/11/24.
//

import Cocoa

class NiMarkDownItem: NSViewController, CFContentItem {
	
	func setActive() {
		return
	}
	
	func setInactive() -> FollowOnAction {
		return .nothing
	}
	
	func spaceClosed() {
		return
	}
	
	func spaceRemovedFromMemory() {
		return
	}
	
	func printView(_ sender: Any?) {
		return
	}
	
	
//	private var overlay: NSView?
	var owner: ContentFrameController?
//	var parentView: CFFramelessView? {return scrollView.superview as? CFFramelessView }
	var viewIsActive: Bool {return true}
//
//	var scrollView: NSScrollView
//	private var txtDocView: NiNoteView
	private var viewFrame: NSRect
//	
	required init(frame: NSRect, initText: String?) {
//		scrollView = NSScrollView(frame: frame)
//		let noteView = NiNoteView(frame: frame)
//		self.txtDocView = noteView
//		
//		scrollView.documentView = noteView
//		
//		let txtStorage = if(initText == nil){
//			NSTextStorage(string: "")
//		}else{
//			NSTextStorage(string: initText!)
//		}
//		txtStorage.addLayoutManager(txtDocView.layoutManager!)
		
		viewFrame = frame
		
		super.init(nibName: nil, bundle: nil)
		
//		noteView.myController = self
//		view = scrollView
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		
	}
}


