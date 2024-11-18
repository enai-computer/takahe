//
//  WelcomeSpaceGenerator.swift
//  ni
//
//  Created by Patrick Lukas on 15/5/24.
//

import Foundation
import AppKit

class WelcomeSpaceGenerator{
	
	static let paddingBetweenWindows: CGFloat = 20.00
	static let paddingToRightScreenEdge: CGFloat = 322.00
	static let paddingToLeftScreenEdge: CGFloat = 50.00
	static let paddingToTopScreenEdge: CGFloat = 50.00
	static let paddingToBottomScreenEdge: CGFloat = 20.00
	
	static let WELCOME_SPACE_ID =  UUID(uuidString:"00000000-0000-0000-0000-000000000001")!
	static let WELCOME_SPACE_NAME = "Enai Onboarding"
	
	static func generateSpace(_ screenSize: CGSize) -> NiSpaceDocumentController{
		let controller = NiSpaceDocumentController(
			id: WelcomeSpaceGenerator.WELCOME_SPACE_ID,
			name: WelcomeSpaceGenerator.WELCOME_SPACE_NAME,
			height: nil
		)
		
		loadWelcomeJson(screenSize, spaceView: controller.myView)
		
		return controller
	}
	
	static func loadWelcomeJson(_ screenSize: CGSize, spaceView: NiSpaceDocumentView){
		guard let model: WelcomeSpaceDocumentModel = loadWelcomeModelFromFile() else {return}
		var latestMinimizedWindowY: CGFloat = WelcomeSpaceGenerator.paddingToTopScreenEdge - WelcomeSpaceGenerator.paddingBetweenWindows
		
		for window in model.windows {
			let tabs = urlStrsToNiCFTabModel(tabs: window.tabs)
			let cfController = reopenContentFrameWithOutPositioning(
				screenWidth: screenSize.width,
				contentFrameState: window.state,
				prevState: nil,
				tabViewModels: tabs,
				groupName: window.windowName,
				groupId: nil
			)
			//position <- expanded one in the center with some room on the left: minimized CFs vertiacal with some space between each other
			cfController.view.frame = positionWindow(
				screenSize,
				latestMinimizedWindowY: latestMinimizedWindowY,
				isMinimised: (window.state == .minimised),
				frameSize: cfController.view.frame.size
			)
			
			if(window.state == .minimised){
				latestMinimizedWindowY = cfController.view.frame.maxY
			}
			spaceView.addNiFrame(cfController)
			cfController.myView.setFrameOwner(spaceView)
		}
		let pdfs = pdfTabViewModel()
		for pdfTab in pdfs{
			let cfController = reopenContentFrameWithOutPositioning(
				screenWidth: screenSize.width,
				contentFrameState: .simpleMinimised,
				prevState: nil,
				tabViewModels: [pdfTab],
				groupName: pdfTab.title,
				groupId: nil
			)
			cfController.view.frame = positionWindow(
				screenSize,
				latestMinimizedWindowY: latestMinimizedWindowY,
				isMinimised: true,
				frameSize: cfController.view.frame.size
			)
			latestMinimizedWindowY = cfController.view.frame.maxY
			
			spaceView.addNiFrame(cfController)
			cfController.myView.setFrameOwner(spaceView)
		}
	}
	
	static func pdfTabViewModel() -> [TabViewModel]{
		let licklider = fetchPDFFromMainBundle(name: "licklider")
		let toolsmith = fetchPDFFromMainBundle(name: "toolsmith")
		return [
			TabViewModel(contentId: UUID(),
						 type: .pdf,
						 title: "Man-Computer Symbiosis",
						 state: .loaded,
						 data: licklider
						),
			TabViewModel(contentId: UUID(),
						 type: .pdf,
						 title: "The Computer Scientist as Toolsmith",
						 state: .loaded,
						 data: toolsmith
						)
		]
	}
	
	static func urlStrsToNiCFTabModel(tabs: [WelcomeSpaceTabModel]) -> [TabViewModel]{
		var out: [TabViewModel] = []
		
		for (i, tab) in tabs.enumerated(){
			let active = if(i == 0){
				true
			}else{
				false
			}
			
			let tabModel = TabViewModel(
				contentId: UUID(),
				type: .web,
				title: tab.title,
				content: tab.url,
				state: .loading,
				position: i,
				isSelected: active
			)
			out.append(tabModel)
		}
		return out
	}
	
	static private func positionWindow(_ screenSize: CGSize, latestMinimizedWindowY: CGFloat, isMinimised: Bool = false, frameSize: CGSize) -> CGRect{
		
		if(isMinimised){
			return NSRect(
				x: (screenSize.width - WelcomeSpaceGenerator.paddingToRightScreenEdge),
				y: latestMinimizedWindowY + WelcomeSpaceGenerator.paddingBetweenWindows,
				width: frameSize.width,
				height: frameSize.height
			)
		}
		
		return NSRect(
			x: WelcomeSpaceGenerator.paddingToLeftScreenEdge,
			y: WelcomeSpaceGenerator.paddingToTopScreenEdge,
			width: (screenSize.width - WelcomeSpaceGenerator.paddingToLeftScreenEdge - WelcomeSpaceGenerator.paddingToRightScreenEdge - WelcomeSpaceGenerator.paddingBetweenWindows),
			height: (screenSize.height - WelcomeSpaceGenerator.paddingToTopScreenEdge - WelcomeSpaceGenerator.paddingToBottomScreenEdge)
		)
	}
	
	static private func loadWelcomeModelFromFile() -> WelcomeSpaceDocumentModel?{
		do{
//			let jsonDoc = NSDataAsset(name: "welcomeConfig", bundle: Bundle.main)!
			let path = Bundle.main.url(forResource: "welcomeConfig", withExtension: "json")
			let jsonDoc = NSData(contentsOf: path!)
			let jsonDecoder = JSONDecoder()
			let docModel = try jsonDecoder.decode(WelcomeSpaceDocumentModel.self, from: jsonDoc! as Data)
			return docModel
		}catch{
			print(error)
		}
		return nil
	}
}

struct WelcomeSpaceTabModel: Codable{
	var title: String
	var url: String
}

struct WelcomeSpaceWindowModel: Codable{
	var windowName: String?
	var state: NiContentFrameState
	var tabs: [WelcomeSpaceTabModel]
}

struct WelcomeSpaceDocumentModel: Codable{
	var windows: [WelcomeSpaceWindowModel]
}
