//
//  WebAppItemModel.swift
//  ni
//
//  Created by Patrick Lukas on 9/8/24.
//

import Cocoa


struct WebAppItemModel: Codable{
	let name: String
	let url: URL
	let frameColor: String?
	
	var frameNSColor: NSColor? {
	   guard let frameColor = frameColor else { return nil }
	   return NSColor(hex: frameColor)
   }
	
	enum CodingKeys: String, CodingKey {
		   case name
		   case url
		   case frameColor
	   }
	
	init(name: String, url: URL, frameColor: NSColor? = nil) {
		self.name = name
		self.url = url
		self.frameColor = frameColor?.hex
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		url = try container.decode(URL.self, forKey: .url)
		frameColor = try container.decodeIfPresent(String.self, forKey: .frameColor)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encode(url, forKey: .url)
		try container.encodeIfPresent(frameColor, forKey: .frameColor)
	}
}

/*
 WebAppItem(name: "Linear",
			url: URL(string: "https://linear.app/")!,
			frameColor: NSColor(r: 236.0, g: 236.0, b: 236.0, alpha: 1.0)
		   ),
 WebAppItem(name: "Gmail",
			url: URL(string: "https://mail.google.com/mail/u/0/#inbox")!,
			frameColor: NSColor(r: 235.0, g: 241.0, b: 250.0, alpha: 1.0)
		   ),
 WebAppItem(name: "PostHog",
			url: URL(string: "https://eu.posthog.com/")!,
			frameColor: NSColor(r: 238.0, g: 239.0, b: 234.0, alpha: 1.0)
		   ),
 WebAppItem(name: "Notion Calendar",
			url: URL(string: "https://calendar.notion.so")!,
			frameColor: NSColor(r: 247.0, g: 247.0, b: 247.0, alpha: 1.0)
 ),
 WebAppItem(name: "Slack",
			url: URL(string: "https://slack.com")!,
			frameColor: NSColor(r: 76.0, g: 41.0, b: 82.0, alpha: 1.0)
		   ),
 WebAppItem(name: "Figma",
			url: URL(string: "https://www.figma.com")!,
			frameColor: NSColor(r: 255.0, g: 255.0, b: 255.0, alpha: 1.0)
		   )
 
 extension NSColor{
	 
	 convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat){
		 self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
	 }
 }

 */
extension NSColor {
	convenience init(hex: String) {
		let scanner = Scanner(string: hex)
		scanner.scanString("#")

		var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 0

		scanner.scanHexInt64(&r)
		scanner.scanHexInt64(&g)
		scanner.scanHexInt64(&b)
		scanner.scanHexInt64(&a)

		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}

	var hex: String {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		getRed(&r, green: &g, blue: &b, alpha: &a)

		return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
	}
}
