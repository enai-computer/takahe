//
//  NiPdfViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 2/7/24.
//

import Foundation
import PDFKit

func getNewPdfView(owner: ContentFrameController, frame: NSRect, document doc: PDFDocument) -> NiPdfView{
	let pdfView = NiPdfView(owner: owner, frame: frame, document: doc)
	pdfView.autoScales = true
	return pdfView
}

func getIntrinsicDocSize(for document: PDFDocument) -> CGSize{
	let page = document.getPageSafely(at: 0)
	let rect = page?.bounds(for: .mediaBox)
	
	return rect?.size ?? CGSize(width: 248.0, height: 350.8)	//default is DinA4
}


extension PDFDocument{
	
	func tryGetTitle() -> String?{
		if let title: String = documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String{
			return title
		}
		return nil
	}
	
	func getPageSafely(at index: Int) -> PDFPage?{
		if(index < pageCount){
			return page(at: index)
		}
		return nil
	}
}
