//
//  CFProtocol.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa

class CFProtocol: NSViewController{
	
	var groupId: UUID?
	var groupName: String?
	
	var viewState: NiContentFrameState = .expanded
	var myView: CFBaseView {return (view as! CFBaseView)}
	var tabs: [TabViewModel] = []
	
	private var closeCancelled = false
	private(set) var closeTriggered = false
	
	func selectNextTab(goFwd: Bool = true){}
	func openAndEditEmptyWebTab(createInfoText: Bool = true){}
	func toggleEditSelectedTab(){}
	func maximizeSelf(){}
	func minimizeSelf(){}
	func minimizedToExpanded(_ shallSelectTabAt: Int = -1){}
	func minimizedToFullscreen(){}
	func minimizeToCollapsed(to origin: NSPoint? = nil){}
	func updateGroupName(_ n: String?){}
	func expandedToFullscreen(){}
	func closeSelectedTab(){}
	func reloadSelectedTab(){}
	func pauseMediaPlayback(){}
	func tryPrintContent(_ sender: Any?){}
	func deinitSelf(){}
		
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiContentFrameState?){
		fatalError("function not implemented")
	}
	
	func persistContent(spaceId: UUID){
		assertionFailure("function not implemented")
	}
	
	func purgePersistetContent(){
		assertionFailure("function not implemented")
	}
	
	/** Call this function ONLY from `setTopNiFrame` in `NiSpaceDocumentView`. Otherwise you will screw up the hierarchy on the canvas!
	 */
	func toggleActive(){
		myView.toggleActive()
	}
	
	/*
	 * MARK: close process
	 */
	
	/** triggers close animation and displays undo button
	 
	runs following steps:
	1. fade out current view
	2. display undo button
	   * if clicked "undo button": cancel deletion
	   * if "undo" ignored: clean up and remove this controller plus view from hierarchy
	 */
	func triggerCloseProcess(with event: NSEvent){
		//stops double click, as it will have unwanted side effects
		if(closeTriggered){
			return
		}
		fadeout()
		loadAndDisplaySoftDeletedView(topRightCorner: CGPoint(x: view.frame.maxX, y: view.frame.minY))
		closeTriggered = true
	}
	
	private func loadAndDisplaySoftDeletedView(topRightCorner: CGPoint) {
		let softDeletedView = (NSView.loadFromNib(nibName: "CFSoftDeletedView", owner: self) as! CFSoftDeletedView)
		
		if(1 == tabs.count){
			softDeletedView.initAfterViewLoad(tabs[0].type.toDescriptiveName(), parentController: self)
		}else if(viewState == .sectionTitle){
			softDeletedView.initAfterViewLoad("section title", parentController: self)
		}else{
			softDeletedView.initAfterViewLoad(parentController: self)
		}
		
		var undoOrigin = topRightCorner
		undoOrigin.x = undoOrigin.x - softDeletedView.frame.width
		softDeletedView.frame.origin = undoOrigin
		softDeletedView.layer?.zPosition = self.view.layer!.zPosition
		self.view.superview?.addSubview(softDeletedView)
	}
	
	private func fadeout(){
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.5
			self.view.animator().alphaValue = 0.0
		}, completionHandler: {
			if(self.closeCancelled || !self.closeTriggered){
				return
			}
			self.view.isHidden = true
			self.view.alphaValue = 1.0
		})
	}
	
	func cancelCloseProcess(){
		self.closeCancelled = true
		self.closeTriggered = false
		fadeIn()
	}
	
	private func fadeIn(){
		self.view.isHidden = false
		self.view.alphaValue = 1.0
	}
	
	func confirmClose(){
		if(self.closeCancelled){
			self.closeCancelled = false
			self.closeTriggered = false
			return
		}
		myView.closedContentFrameCleanUp()
		removeFromParent()
		if(viewState == .fullscreen){
			if let spaceController = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController(){
				spaceController.showHeader()
			}
		}
	}
}
