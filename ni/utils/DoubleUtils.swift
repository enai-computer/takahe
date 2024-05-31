//
//  DoubleUtils.swift
//  ni
//
//  Created by Patrick Lukas on 31/5/24.
//

import Foundation

extension Double{
	func negateIfNegative() -> Double{
		if(self.isLess(than: 0.0)){
			return self * -1.0
		}
		return self
	}
}
