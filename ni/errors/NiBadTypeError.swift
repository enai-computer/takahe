//
//  niBadTypeError.swift
//  ni
//
//  Created by Patrick Lukas on 8/4/24.
//

enum NiBadTypeError: Error{
	case badParentType(className: String, classExpected: String)
}
