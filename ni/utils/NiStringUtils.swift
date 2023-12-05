//
//  NiStringUtils.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation


extension String {
  /*
   Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
   - Parameter length: Desired maximum lengths of a string
   - Parameter trailing: A 'String' that will be appended after the truncation.
    
   - Returns: 'String' object.
  */
  func truncate(_ maxLength: Int, trailing: String = "…") -> String {
    return (self.count > maxLength) ? self.prefix(maxLength) + trailing : self
  }
}
