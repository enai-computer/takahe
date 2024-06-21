//
//  NiStringUtils.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation


func urlOrSearchUrl(from dirtyInput: String) throws -> URL{
	let greyInput = dirtyInput.trimmingCharacters(in: .whitespaces)
	if(isValidWebUrl(url: greyInput)){
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

//TODO: this needs to be checked against official specifications: https://url.spec.whatwg.org/
func isValidWebUrl(url: String) -> Bool {
	let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
	let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
	let result = urlTest.evaluate(with: url)
	return result
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
}

func hasImgExtension(_ path: String) -> Bool {
	let cleanPath = path.lowercased()
	let suffixes: [String] = [".tiff", ".png", ".jpeg", "jpg"]
	
	if(suffixes.contains(where: cleanPath.hasSuffix)){
		return true
	}
	return false
}
