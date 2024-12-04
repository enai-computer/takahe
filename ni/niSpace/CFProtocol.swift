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
	
	func triggerCloseProcess(with event: NSEvent){
		assertionFailure("function not implemented")
	}
	
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
}
