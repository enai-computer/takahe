//
//  BilgePump.swift
//  ni
//
//  Created by Patrick Lukas on 13/9/24.
//

import Foundation
import Network

class BilgePump{
	
	init(openSpaceID: UUID){
		
	}
	
	func collectSpaceData(){
		//nr of open WebViews
		//nr of open PDFs
		//nr of content frames in total
		//complete copy of a space
	}
	
	func appStat(){
		let releaseVersionNumber: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let buildVersionNumber: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
		
	}
	
	func netWorkStats(){
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { path in
			if(path.status == .satisfied){
				for p in path.availableInterfaces{
					p.name
				}
			}else{
				
			}
		}
	}
	
	func reportMemory() {
		var taskInfo = mach_task_basic_info()
		var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
		let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
			$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
				task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
			}
		}

		if kerr == KERN_SUCCESS {
			print("Memory used in bytes: \(taskInfo.resident_size)")
		}
		else {
			print("Error with task_info(): " +
				(String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
		}
	}
	
	func reportThreadCount(){
		var threadList: thread_act_array_t?
		var threadCount: mach_msg_type_number_t = 0

		let result = task_threads(mach_task_self_, &threadList, &threadCount)

		if result == KERN_SUCCESS {
			print("Number of threads: \(threadCount)")
		}
	}
}
