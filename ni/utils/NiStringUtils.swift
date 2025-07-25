//
//  NiStringUtils.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation


func urlOrSearchUrl(from dirtyInput: String) throws -> URL{
	let greyInput = dirtyInput.trimmingCharacters(in: .whitespaces)
	if(greyInput.isValidURL){
		return try createWebUrl(from: greyInput)
	}
	
	let urlSearch = searchUrl(from: greyInput)
	guard let url = URL(string: urlSearch) else {throw NiUserInputError.invalidSearch(url: urlSearch)}
	return url
}

func searchUrl(from query: String) -> String{
	let encodedSearchTerm = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
	let urlSearch = "https://www.google.com/search?q=" + encodedSearchTerm!
	return urlSearch
}

func createWebUrl(from urlDirty: String) throws -> URL{
	let urlClean: String
	if(urlDirty.hasPrefix("http")){
		urlClean = urlDirty
	}else{
		urlClean = "https://".appending(urlDirty)
	}
	
	guard let url = URL(string: urlClean) else {throw NiUserInputError.invalidURL(url: urlClean)}

	return url
}

func sanitizeForJavaScript(_ str: String) -> String {
	return str.replacingOccurrences(of: "\\", with: "\\\\")
		   .replacingOccurrences(of: "'", with: "\\'")
		   .replacingOccurrences(of: "\"", with: "\\\"")
		   .replacingOccurrences(of: "\n", with: "\\n")
		   .replacingOccurrences(of: "\r", with: "\\r")
		   .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
		   .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
}

extension String {
  /*
   Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
   - Parameter length: Desired maximum lengths of a string
   - Parameter trailing: A 'String' that will be appended after the truncation.
    
   - Returns: 'String' object.
  */
	func truncate(_ maxLength: Int, trailing: String = "…") -> String {
		return (self.count > maxLength) ? self.prefix(maxLength) + trailing : self
	}
	
	//from: https://stackoverflow.com/a/49072718
	var isValidURL: Bool {
		let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
		if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
			// it is a link, if the match covers the whole string
			return match.range.length == self.utf16.count
		} else {
			//the other ceck alone is not engough :/ 
			let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
			let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
			let result = urlTest.evaluate(with: self)
			return result
		}
	}
	
	func dropping(prefix: String) -> String {
		return hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
	}
	
	func escapedJavaScriptString() -> String {
		self.replacingOccurrences(of: "\\", with: "\\\\")
			.replacingOccurrences(of: "\"", with: "\\\"")
			.replacingOccurrences(of: "'", with: "\\'")
			.replacingOccurrences(of: "\n", with: "\\n")
	}
}

func hasImgExtension(_ path: String) -> Bool {
	let cleanPath = path.lowercased()
	let suffixes: [String] = [".tiff", ".png", ".jpeg", "jpg"]
	
	if(suffixes.contains(where: cleanPath.hasSuffix)){
		return true
	}
	return false
}

func hasPdfExtension(_ path: String) -> Bool {
	let cleanPath = path.lowercased()
	let suffix = ".pdf"
	
	return cleanPath.hasSuffix(suffix)
}
