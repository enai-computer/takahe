//
//  CFFullscreenView.swift
//  ni
//
//  Created by Patrick Lukas on 12/8/24.
//

import Cocoa

class CFFullscreenView: CFBaseView{

	@IBOutlet var niContentTabView: NSTabView!
	
	@IBOutlet var minimizedIcon: NiActionImage!
	@IBOutlet var pinnedAppIcon: NiActionImage!
	@IBOutlet var searchIcon: NiActionImage!
	@IBOutlet var time: NSTextField!
	@IBOutlet var cfTabHeadCollection: NSCollectionView!
	@IBOutlet var addButton: NiActionImage!
	@IBOutlet var fwdButton: NiActionImage!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var spaceName: NiTextField!
	@IBOutlet var groupName: NiTextField!
	
	override func repositionView(_ xDiff: Double, _ yDiff: Double) {
		return
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		return .no
	}
	
	override func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false) {
		return
	}
	
	override func fillView(with event: NSEvent?) {
		let visibleView = self.niParentDoc!.visibleRect
		
		self.setFrameSize(visibleView.size)
		self.setFrameOrigin(NSPoint(x: 0.0, y: 0.0))
	}
	
	override func toggleActive() {
		
	}
	
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int {
		let tabViewPos: Int
		let tabViewItem = NSTabViewItem()
		tabViewItem.view = tabView
		
		//check that open nextTo is set and within bounds (e.g. not the last element)
		if(openNextTo < 0 || (myController!.tabs.count - 1) <= openNextTo){
			tabViewPos = niContentTabView.numberOfTabViewItems
			niContentTabView.addTabViewItem(tabViewItem)
		}else{
			tabViewPos = openNextTo + 1
			niContentTabView.insertTabViewItem(tabViewItem, at: tabViewPos)
		}
		
		//TODO: set guard to call only on webViews
		setWebViewObservers(tabView: tabView)
		return tabViewPos
	}
	
	private func setWebViewObservers(tabView: NSView){
		tabView.addObserver(self, forKeyPath: "canGoBack", options: [.initial, .new], context: nil)
		tabView.addObserver(self, forKeyPath: "canGoForward", options: [.initial, .new], context: nil)
	}
}
