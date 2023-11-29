//
//  ContentFrameTabView.swift
//  ni
//
//  Created by Patrick Lukas on 11/20/23.
//

import Cocoa


class ContentFrameTabView: NSTabView, Codable{
    
//    private let contentId: UUID
    
    enum ContentFrameTabKeys: String, CodingKey{
            case type, contentType, id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContentFrameTabKeys.self)
        try container.encode("CFTab", forKey: ContentFrameTabKeys.type)
        try container.encode("web", forKey: ContentFrameTabKeys.contentType)
//        try container.encode(contentId, forKey: ContentFrameTabKeys.id)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContentFrameTabKeys.self)
//        self.contentId = try container.decode(UUID.self, forKey: ContentFrameTabKeys.id)
        
        //TODO: load content based on content ID here
        
        super.init(frame: NSRect())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        self.contentId = UUID()
    }
}
