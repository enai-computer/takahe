//
//  NiCollectionViewUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 21/11/24.
//

import Foundation

struct ListDiffResult {
	let removals: Set<IndexPath>
	let moves: [(fromIndex: IndexPath, toIndex: IndexPath)]
	let insertions: Set<IndexPath>
	
}

class ListDiffHelper {
	static func diff<T: Equatable>(_ oldList: [T], _ newList: [T]) -> ListDiffResult {
		var removals: Set<IndexPath> = []
		var moves: [(fromIndex: IndexPath, toIndex: IndexPath)] = []
		var insertions: Set<IndexPath> = []

		
		// Find removals
		for (oldIndex, item) in oldList.enumerated() {
			if !newList.contains(item) {
				removals.insert(IndexPath(item: oldIndex, section: 0))
			} else if let newIndex = newList.firstIndex(of: item), newIndex != oldIndex {
				moves.append((fromIndex: IndexPath(item: oldIndex, section: 0), toIndex: IndexPath(item: newIndex, section: 0)))
			}
		}
		
		// Find insertions
		for (newIndex, item) in newList.enumerated() {
			if !oldList.contains(item) {
				insertions.insert(IndexPath(item: newIndex, section: 0))
			}
		}
		
		return ListDiffResult(
			removals: removals,
			moves: moves,
			insertions: insertions
		)
	}
}
