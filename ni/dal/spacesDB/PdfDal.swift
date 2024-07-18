//
//  PdfDal.swift
//  ni
//
//  Created by Patrick Lukas on 2/7/24.
//

import Foundation
import PDFKit
import SQLite

class PdfDal{
	
	static func insert(documentId: UUID, id: UUID, title: String?, pdf: PDFDocument, source: String?) {
		if(ContentTable.contains(id: id)){
			ContentTable.updateTitle(id: id, title: title)
			return
		}
		
		Storage.instance.startedWrite()
		Task{
			let fUrl: URL = Storage.instance.genFileUrl(for: id, ofType: .spacePdf)
			if(pdf.write(to: fUrl)){
				ContentTable.upsert(id: id, type: "pdf", title: title, fileUrl: fUrl.absoluteString, source: source)
				
				DocumentIdContentIdTable.insert(documentId: documentId, contentId: id)
			}else{
				print("Failed to write pdf to disk with Title: \(title ?? "")")
			}
			Storage.instance.finishedWrite()
		}
	}
	
	static func fetchPdfWMetaData(id: UUID) -> (String?, PDFDocument?, String?)?{
		let (urlString, title, sourceUrl) = ContentTable.fetchURLTitleSource(for: id) ?? (nil, nil, nil)
		if(urlString == nil){return nil}
		
		if let fUrl = URL(string: urlString!){
			return (title, fetchPdfFromDisk(fUrl), sourceUrl)
		}
		
		return nil
	}
	
	static func deletePdf(id: UUID){
		let (urlString, _, _) = ContentTable.fetchURLTitleSource(for: id) ?? (nil, nil, nil)
		if(urlString == nil){return}
		
		do{
			try FileManager.default.removeItem(atPath: urlString!)
			ContentTable.delete(id: id)
		}catch{
			print("failed to delete file")
		}
	}
}
