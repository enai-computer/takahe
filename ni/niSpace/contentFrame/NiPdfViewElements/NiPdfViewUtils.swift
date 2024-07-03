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
	
	return pdfView
}
