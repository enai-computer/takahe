//
//  DocumentDal.swift
//  ni
//
//  Created by Patrick Lukas on 24/9/24.
//
import Foundation


class DocumentDal{
	
	static func persistDocument(spaceId: UUID, document tab: TabViewModel){
		if(tab.type == .web){
			let url = getTabUrl(for: tab)
			CachedWebTable.upsert(documentId: spaceId, id: tab.contentId, title: tab.title, url: url)
		}
		if(tab.type == .note){
			let txt = tab.noteView?.getText()
			let title = tab.noteView?.getTitle()
			if(txt != nil){
				NoteTable.upsert(documentId: spaceId, id: tab.contentId, title: title, rawText: txt!)
			}
		}
		if(tab.type == .img){
			if let img = tab.imgView?.image{
				ImgDal.insert(documentId: spaceId, id: tab.contentId, title: tab.title, img: img, source: tab.source)
			}
		}
		if(tab.type == .pdf){
			if let pdfDoc = tab.pdfView?.document{
				PdfDal.insert(documentId: spaceId, id: tab.contentId, title: tab.title, pdf: pdfDoc, source: tab.source)
			}
		}
	}
	
	private static func getTabUrl(for tab: TabViewModel) -> String{
		if(tab.state == .loaded){
			return tab.webView?.getCurrentURL() ?? tab.content
		}
		return tab.content
	}
}
