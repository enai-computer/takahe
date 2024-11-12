//
//  NiDocumentModel.swift
//  ni
//
//  Created by Patrick Lukas on 11/28/23.
//

import Foundation

struct NiCoordinate: Codable{
    let px: CGFloat
}

struct NiViewPosition: Codable{
    let posInViewStack: Int
    let x: NiCoordinate
    let y: NiCoordinate
}

struct NiOrigin: Codable {
	let x: NiCoordinate
	let y: NiCoordinate
	
	init(_ p: NSPoint){
		x = NiCoordinate(px: p.x)
		y = NiCoordinate(px: p.y)
	}
	
	func toNSPoint() -> NSPoint{
		return NSPoint(
			x: x.px,
			y: y.px
		)
	}
}

enum NiDocumentObjectTypes: String, Codable{
    case document, contentFrame
}


class NiDocumentObjectModel: Codable{

    var type: NiDocumentObjectTypes
    var data: Codable
    
    enum NiDocumentObjectModelKeys: String, CodingKey{
            case type, data
    }
    
    init(type: NiDocumentObjectTypes, data: Codable){
        self.type = type
        self.data = data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NiDocumentObjectModelKeys.self)
        self.type = try container.decode(NiDocumentObjectTypes.self, forKey: NiDocumentObjectModelKeys.type)
        switch self.type {
            case .document:
                self.data = try container.decode(NiDocumentModel.self, forKey: NiDocumentObjectModelKeys.data)
            case .contentFrame:
                self.data = try container.decode(NiContentFrameModel.self, forKey: NiDocumentObjectModelKeys.data)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NiDocumentObjectModelKeys.self)
        try container.encode(self.type, forKey: NiDocumentObjectModelKeys.type)
        try container.encode(self.data, forKey: NiDocumentObjectModelKeys.data)
    }
}

class NiDocumentModel: Codable{
    let id: UUID
    let height: NiCoordinate
    let width: NiCoordinate
	let viewPosition: NiCoordinate?
    let children: [NiDocumentObjectModel]
    
    enum NiDocumentModelKeys: String, CodingKey{
        case id, height, width, viewPosition, children
    }
    
	init(id: UUID, height: CGFloat, width: CGFloat, children: [NiDocumentObjectModel], viewPosition: CGFloat? = nil){
        self.id = id
        self.height = NiCoordinate(px: height)
        self.width = NiCoordinate(px: width)
		self.viewPosition = if(viewPosition != nil){NiCoordinate(px: viewPosition!)} else {nil}
        self.children = children
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NiDocumentModelKeys.self)
        self.id = try container.decode(UUID.self, forKey: NiDocumentModelKeys.id)
        self.height = try container.decode(NiCoordinate.self, forKey: NiDocumentModelKeys.height)
        self.width = try container.decode(NiCoordinate.self, forKey: NiDocumentModelKeys.width)
		self.viewPosition = try container.decodeIfPresent(NiCoordinate.self, forKey: NiDocumentModelKeys.viewPosition)
        self.children = try container.decode([NiDocumentObjectModel].self, forKey: NiDocumentModelKeys.children)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NiDocumentModelKeys.self)
        try container.encode(self.id, forKey: NiDocumentModelKeys.id)
        try container.encode(self.height, forKey: NiDocumentModelKeys.height)
        try container.encode(self.width, forKey: NiDocumentModelKeys.width)
		try container.encode(self.viewPosition, forKey: NiDocumentModelKeys.viewPosition)
        try container.encode(self.children, forKey: NiDocumentModelKeys.children)
    }
}

// MARK: - Content Frame _Tab_ Model:

enum TabContentType: String, Codable{
    case web, note, img, pdf, webApp, eveChat    //to come: other file types...
	
	func toDescriptiveName()->String{
		switch (self){
			case .web:
				return "website"
			case .note:
				return "note"
			case .img:
				return "image"
			case .pdf:
				return "pdf"
			case .webApp:
				return "app"
			case .eveChat:
				return "Enai chat"
		}
	}
}

struct NiCFTabModel: Codable{
    var id: UUID
    var contentType: TabContentType
	var contentState: String	//can have vastly different values depending on the type. To be decoded by the ViewModels
    var active: Bool    // if this is the currently active tab
    var position: Int   // position in window, starting from left
	var scrollPosition: Int? 
}


// MARK: -  Content Frame Model:

enum NiContentFrameState: String, Codable {
    case collapsedMinimised, minimised, expanded, frameless, simpleFrame, simpleMinimised, fullscreen
	
	func isMinimized() -> Bool{
		if(self == .minimised || self == .simpleMinimised || self == .collapsedMinimised){
			return true
		}
		return false
	}

	func isDefaultViewState() -> Bool{
		return switch self{
			case .expanded, .simpleFrame, .frameless: true
			default: false
		}
	}
	
	var canBecomeFullscreen: Bool {
		return switch self {
		case .collapsedMinimised, .minimised, .expanded: true
		case .frameless, .simpleFrame, .simpleMinimised, .fullscreen: false
		}
	}
}

enum NiCFCollapseDirection: String, Codable{
	case leftToRight, rightToLeft
}

struct NiPreviousDisplayState: Codable{
	var state: NiContentFrameState
	var expandCollapseDirection: NiCFCollapseDirection
	var minimisedOrigin: NiOrigin?
	var defaultWindowOrigin: NiOrigin?
}

struct NiContentFrameModel: Codable{
    var state: NiContentFrameState
	var previousDisplayState: NiPreviousDisplayState?
    var height: NiCoordinate
    var width: NiCoordinate
    var position: NiViewPosition
    var children: [NiCFTabModel]
	var name: String?
	var id: UUID?
}

