//
//  WebAppItemModel.swift
//  ni
//
//  Created by Patrick Lukas on 9/8/24.
//

import Cocoa


struct PinnedWebsiteItemModel: Codable, Equatable{
	let name: String
	let url: URL
	let frameColor: String?
	let darkFrameColor: String?
	
	var frameNSColor: NSColor? {
	   guard let frameColor = frameColor else { return nil }
	   return NSColor(hex: frameColor)
	}
	
	var darkframeNSColor: NSColor?{
		guard let darkFrameColor = darkFrameColor else { return nil }
		return NSColor(hex: darkFrameColor)
	}
	
	enum CodingKeys: String, CodingKey {
		case name
		case url
		case frameColor
		case darkFrameColor
	}
	
	init(name: String, url: URL){
		self.name = name
		self.url = url
		self.frameColor = PinnedWebsiteItemModel.getColor(for: url).hex
		self.darkFrameColor = PinnedWebsiteItemModel.getDarkColor(for: url).hex
	}
	
	init(name: String, url: URL, frameColor: NSColor, darkFrameColor: NSColor) {
		self.name = name
		self.url = url
		self.frameColor = frameColor.hex
		self.darkFrameColor = darkFrameColor.hex
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		url = try container.decode(URL.self, forKey: .url)
		frameColor = try container.decodeIfPresent(String.self, forKey: .frameColor)
		darkFrameColor = try container.decodeIfPresent(String.self, forKey: .darkFrameColor)
	}

	static func == (lhs: PinnedWebsiteItemModel, rhs: PinnedWebsiteItemModel) -> Bool {
		return lhs.url == rhs.url && lhs.name == rhs.name
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
					return NSColor(r: 236.0, g: 236.0, b: 236.0, alpha: 1.0)	//9.9.9
				case _ where baseURL.contains("mail.google.com"):
					return NSColor(r: 235.0, g: 241.0, b: 250.0, alpha: 1.0) 	//17.17.17
				case _ where baseURL.contains("posthog.com"):
					return NSColor(r: 238.0, g: 239.0, b: 234.0, alpha: 1.0)	//34.36.42
				case _ where baseURL.contains("calendar.notion.so"):
					return NSColor(r: 247.0, g: 247.0, b: 247.0, alpha: 1.0)	//26.26.26
				case _ where baseURL.contains("slack.com"):
					return NSColor(r: 76.0, g: 41.0, b: 82.0, alpha: 1.0)		//56.19.64
				case _ where baseURL.contains("figma.com"):
					return NSColor(r: 255.0, g: 255.0, b: 255.0, alpha: 1.0)	//44.44.44
				case _ where baseURL.contains("web.whatsapp.com"):
					return NSColor(r: 240.0, g: 242.0, b: 245.0, alpha: 1.0)	//13.19.23
				case _ where baseURL.contains("perplexity.ai"):
					return NSColor(r: 243.0, g: 243.0, b: 238.0, alpha: 1.0)	//32.34.34
				default:
					return NSColor.sand4
			}
		}
		return NSColor.sand4
	}
	
	private static func getDarkColor(for url: URL) -> NSColor{
		if let baseURL = url.host(){
			switch baseURL{
				case _ where baseURL.contains("linear.app"):
					return NSColor(r: 9.0, g: 9.0, b: 9.0, alpha: 1.0)
				case _ where baseURL.contains("mail.google.com"):
					return NSColor(r: 17.0, g: 17.0, b: 17.0, alpha: 1.0)
				case _ where baseURL.contains("posthog.com"):
					return NSColor(r: 34.0, g: 36.0, b: 42.0, alpha: 1.0)
				case _ where baseURL.contains("calendar.notion.so"):
					return NSColor(r: 26.0, g: 26.0, b: 26.0, alpha: 1.0)
				case _ where baseURL.contains("slack.com"):
					return NSColor(r: 56.0, g: 19.0, b: 64.0, alpha: 1.0)
				case _ where baseURL.contains("figma.com"):
					return NSColor(r: 44.0, g: 44.0, b: 44.0, alpha: 1.0)
				case _ where baseURL.contains("web.whatsapp.com"):
					return NSColor(r: 13.0, g: 19.0, b: 23.0, alpha: 1.0)
				case _ where baseURL.contains("perplexity.ai"):
					return NSColor(r: 32.0, g: 34.0, b: 34.0, alpha: 1.0)
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
//		let scanner = Scanner(string: hex)
//		scanner.scanString("#")
//
//		var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 0
//
//		scanner.scanHexInt64(&r)
//		scanner.scanHexInt64(&g)
//		scanner.scanHexInt64(&b)
//		scanner.scanHexInt64(&a)
//
//		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
		let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
		let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
		let ui64 = UInt64(hexString, radix: 16)
		let value = ui64 != nil ? Int(ui64!) : 0
		// #RRGGBB
		var components = (
			R: CGFloat((value >> 16) & 0xff) / 255,
			G: CGFloat((value >> 08) & 0xff) / 255,
			B: CGFloat((value >> 00) & 0xff) / 255,
			a: CGFloat(1)
		)
		if String(hexString).count == 8 {
			// #RRGGBBAA
			components = (
				R: CGFloat((value >> 24) & 0xff) / 255,
				G: CGFloat((value >> 16) & 0xff) / 255,
				B: CGFloat((value >> 08) & 0xff) / 255,
				a: CGFloat((value >> 00) & 0xff) / 255
			)
		}
		self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
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
