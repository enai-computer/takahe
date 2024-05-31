//
//  DalUtils.swift
//  ni
//
//  Created by Patrick Lukas on 31/5/24.
//

import Cocoa

/** returns false if failed
	
 */
func writeImgToDisk(fUrl: URL, img: NSImage) -> Bool{
	
	let imgRep = img.representations[0] as? NSBitmapImageRep
	//FIXME: start using png at some point. But we need to figure out compression for that
	if let rawImg = imgRep?.representation(using: .jpeg, properties:[:]){
		do{
			try rawImg.write(to: fUrl, options: .withoutOverwriting)
			return true
		}catch{
			print(error)
		}
	}
	return false
}

func fetchImgFromDisk(_ fUrl: URL) -> NSImage? {
	if(fUrl.isFileURL){
		if let img = NSImage(contentsOf: fUrl){
			//callback(img)
			return img
		}
	}
	return nil
}
