//
//  SystemFilePicker.swift
//  Enai
//
//  Created by Patrick Lukas on 9/12/24.
//

import AppKit

func genSystemFilePicker() -> NSOpenPanel{
	let folderChooserPoint = CGPoint(x: 0, y: 0)
	let folderChooserSize = CGSize(width: 500, height: 600)
	let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
	
	let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
	folderPicker.canChooseDirectories = true
	folderPicker.canChooseFiles = true
	folderPicker.allowsMultipleSelection = true
	folderPicker.canDownloadUbiquitousContents = true
	folderPicker.canResolveUbiquitousConflicts = true
	
	return folderPicker
}
