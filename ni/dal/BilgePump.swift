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
	private let spaceID: UUID
	
	private var report = BilgeWater(
		appStats: WaterAppStats(),
		systemStats: WaterSystemStats(availableNetworks: "")
	)
	
	init(openSpaceID: UUID){
		self.spaceID = openSpaceID
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
	
	func collectBilgeWater(currentSpace: (NiDocumentObjectModel, [String: Any])?){
		appStat()
		reportSystemStats()
		
		report.openSpaceAsPersistedOnDisk = NiSpaceViewController.loadStoredSpace(niSpaceID: spaceID)
		report.openSpaceAsOnScreen = currentSpace?.0
		report.spaceAsOnScreenStats = cleanSpaceStats(currentSpace?.1)
	}
	
	private func cleanSpaceStats(_ optStats: [String: Any]?) -> [String: String]{
		guard let stats = optStats else {return [:]}
		
		var res: [String: String] = [:]
		for s in stats{
			if let intVal = s.value as? Int{
				res[s.key] = String(intVal)
			}
			if let doubleVal = s.value as? Double{
				res[s.key] = String(doubleVal)
			}
			if let floatVal = s.value as? CGFloat{
				res[s.key] = String(Double(floatLiteral: floatVal))
			}
			if let strVal = s.value as? String{
				res[s.key] = strVal
			}
		}
		return res
	}
	
	private func appStat(){
		report.appStats.releaseVersionNumer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		report.appStats.buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
	
		reportMemory()
		reportThreadCount()
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
			report.appStats.memoryUsedInKBytes = "\((taskInfo.resident_size/1024))"
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
			report.appStats.threadCount = "\(threadCount)"
		}
	}
	
	private func reportSystemStats(){
		let totalMemory = ProcessInfo.processInfo.physicalMemory
		report.systemStats.totalMemoryInGB = "\(Double(totalMemory) / 1_000_000_000.0)"

		report.systemStats.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
			
		report.systemStats.activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
		report.systemStats.processorCount = ProcessInfo.processInfo.processorCount
		report.systemStats.isLowerPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
		report.systemStats.systemUptime = "\(ProcessInfo.processInfo.systemUptime)"
	}
	
	private func reportNetworkStats(){
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { path in
			if(path.status == .satisfied){
				for p in path.availableInterfaces{
					self.report.systemStats.availableNetworks += (p.name + " - ")
				}
			}
			//todo: send signal, that report is ready for export
		}
		let queue = DispatchQueue(label: "NetworkMonitor")
		monitor.start(queue: queue)
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
			return try jsonEncoder.encode(report)
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
