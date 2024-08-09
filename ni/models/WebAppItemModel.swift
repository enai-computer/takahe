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
	
	init(name: String, url: URL){
		self.name = name
		self.url = url
		self.frameColor = WebAppItemModel.getColor(for: url).hex
	}
	
	init(name: String, url: URL, frameColor: NSColor) {
		self.name = name
		self.url = url
		self.frameColor = frameColor.hex
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
	
	private static func getColor(for url: URL) -> NSColor{
		if let baseURL = url.host(){
			switch baseURL{
				case _ where baseURL.contains("linear.app"):
					return NSColor(r: 236.0, g: 236.0, b: 236.0, alpha: 1.0)
				case _ where baseURL.contains("mail.google.com"):
					return NSColor(r: 235.0, g: 241.0, b: 250.0, alpha: 1.0)
				case _ where baseURL.contains("posthog.com"):
					return NSColor(r: 238.0, g: 239.0, b: 234.0, alpha: 1.0)
				case _ where baseURL.contains("calendar.notion.so"):
					return NSColor(r: 247.0, g: 247.0, b: 247.0, alpha: 1.0)
				case _ where baseURL.contains("slack.com"):
					return NSColor(r: 76.0, g: 41.0, b: 82.0, alpha: 1.0)
				case _ where baseURL.contains("figma.com"):
					return NSColor(r: 255.0, g: 255.0, b: 255.0, alpha: 1.0)
				case _ where baseURL.contains("web.whatsapp.com"):
					return NSColor(r: 240.0, g: 242.0, b: 245.0, alpha: 1.0)
				case _ where baseURL.contains("perplexity.ai"):
					return NSColor(r: 243.0, g: 243.0, b: 238.0, alpha: 1.0)
				default:
					return NSColor.sand4
			}
		}
		return NSColor.sand4
	}
}

extension NSColor {
	
	convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat){
		self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
	}
	
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
		guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
			return "#FFFFFF"
		}
		let red = Int(round(rgbColor.redComponent * 0xFF))
		let green = Int(round(rgbColor.greenComponent * 0xFF))
		let blue = Int(round(rgbColor.blueComponent * 0xFF))
		let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
		return hexString as String
	}
}
