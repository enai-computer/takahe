//
//  DalUtils.swift
//  ni
//
//  Created by Patrick Lukas on 31/5/24.
//

import Cocoa
import PDFKit
import SQLite

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

func writePngToDisk(fUrl: URL, img: NSImage) -> Bool{
	let imgRep = img.representations[0] as? NSBitmapImageRep
	if let rawImg = imgRep?.representation(using: .png, properties:[:]){
		do{
			try rawImg.write(to: fUrl, options: .withoutOverwriting)
			return true
		}catch{
			print(error)
		}
	}
	return false
}

func fetchPdfFromDisk(_ fUrl: URL) -> PDFDocument? {
	if(fUrl.isFileURL){
		if let pdf = PDFDocument(url: fUrl){
			return pdf
		}
	}
	return nil
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

func fetchImgFromMainBundle(id: UUID) -> NSImage? {
	let urlString = "file://" + Bundle.main.resourcePath! + "/\(id).jpg"
	
	if let fUrl = URL(string: urlString){
		return fetchImgFromDisk(fUrl)
	}
	return nil
}

func fetchPDFFromMainBundle(name: String) -> PDFDocument? {
	let urlString = "file://" + Bundle.main.resourcePath! + "/\(name).pdf"
	
	if let fUrl = URL(string: urlString){
		return fetchPdfFromDisk(fUrl)
	}
	return nil
}

/* returning Insert example: https://github.com/stephencelis/SQLite.swift/issues/1221#issuecomment-1732594273
 extension Insert {
	 func returning(_ columns: [Expression<Int64>]) -> Insert {
		 var template = self.template
		 let bindings = self.bindings
		 
		 template.append(" RETURNING ")
		 template.append(columns.map { column in column.expression.template }.joined(separator: ", "))
		 
		 let insert = Insert(template, bindings)
		 
		 return insert
	 }
 }
 
 ...
 
 let insert = table1.insert(...).returning([col1, col2])

 if let results = try? db().prepareRowIterator(insert.template, bindings: insert.bindings) {
	// handle results as usual
 }
 */
