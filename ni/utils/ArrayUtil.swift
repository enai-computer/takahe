//
//  ArrayUtil.swift
//  ni
//
//  Created by Patrick Lukas on 9/8/24.
//

import Foundation

extension Array where Element: AnyObject {
	mutating func removeFirst(object: AnyObject) {
		guard let index = firstIndex(where: {$0 === object}) else { return }
		remove(at: index)
	}
}
