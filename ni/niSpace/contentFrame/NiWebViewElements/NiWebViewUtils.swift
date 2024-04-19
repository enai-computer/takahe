//
//  NiWebViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 19/4/24.
//

import Foundation

func getEmtpyWebViewURL() -> URL{
	
	return Bundle.main.url(forResource: "emptyTab", withExtension: "html")!
}

func getCouldNotLoadWebViewURL() -> URL{
	//FIXME: load correct html
	return Bundle.main.url(forResource: "emptyTab", withExtension: "html")!
}
