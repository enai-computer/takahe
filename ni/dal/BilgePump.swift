//
//  BilgePump.swift
//  ni
//
//  Created by Patrick Lukas on 13/9/24.
//

import Foundation
import Network
import vproc

/// https://en.wikipedia.org/wiki/Bilge_pump
/// dumping all the bilge water into the sea
class BilgePump{
	
	private let downloadFolder: URL?
	
	private var appStats = WaterAppStats()
	private var systemStats = WaterSystemStats(availableNetworks: "")
	
	init(openSpaceID: UUID){
		do {
			 downloadFolder = try FileManager.default.url(
				for: FileManager.SearchPathDirectory.downloadsDirectory,
				in: FileManager.SearchPathDomainMask.userDomainMask,
				appropriateFor: nil,
				create: true)
		} catch{
			print(error)
			downloadFolder = nil
		}
	}
	
	func collectBilgeWater(){
		appStat()
		reportSystemStats()
	}
	
	private func collectSpaceData(){
		//nr of open WebViews
		//nr of open PDFs
		//nr of content frames in total
		//complete copy of a space
	}
	
	private func appStat(){
		appStats.releaseVersionNumer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		appStats.buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
	
		reportMemory()
		reportThreadCount()
	}
	
	private func networkStats(){
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { path in
			if(path.status == .satisfied){
				for p in path.availableInterfaces{
					self.systemStats.availableNetworks += (p.name + " - ")
				}
			}
		}
	}
	
	private func reportMemory() {
		var taskInfo = mach_task_basic_info()
		var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
		let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
			$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
				task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
			}
		}

		if kerr == KERN_SUCCESS {
			appStats.memoryUsedInKBytes = "\((taskInfo.resident_size/1024))"
		}
		else {
			print("Error with task_info(): " +
				(String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
		}
	}
	
	private func reportThreadCount(){
		var threadList: thread_act_array_t?
		var threadCount: mach_msg_type_number_t = 0

		let result = task_threads(mach_task_self_, &threadList, &threadCount)

		if result == KERN_SUCCESS {
			appStats.threadCount = "\(threadCount)"
		}
	}
	
	private func reportSystemStats(){
		let totalMemory = ProcessInfo.processInfo.physicalMemory
		let totalMemoryInGB = Double(totalMemory) / 1_000_000_000.0

		systemStats.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
			
		systemStats.activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
		systemStats.processorCount = ProcessInfo.processInfo.processorCount
		systemStats.isLowerPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
		systemStats.systemUptime = "\(ProcessInfo.processInfo.systemUptime)"
	}
	
	func goPump(){
		guard let waterPath: String = waterPath() else {
			fatalError("Failed to get path for debugging report")
		}
		
		_ = downloadFolder?.startAccessingSecurityScopedResource()
		FileManager.default.createFile(
			atPath: waterPath,
			contents: getWater()
		)
		downloadFolder?.stopAccessingSecurityScopedResource()
	}
	
	private func getWater() -> Data{
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		do{
			return try jsonEncoder.encode("")
		}catch{
			print(error)
			fatalError("Failed to generate debugging report")
		}
	}
	
	private func waterPath() -> String?{
		let d = Date.now
		if let downloadPath = downloadFolder?.absoluteStringWithoutScheme{
			return downloadPath + "enai-BildgeWater-\(d.timeIntervalSince1970).json"
		}
		return nil
	}
}
