//
//  Step4ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 29/11/24.
//

import SwiftUI

struct Step4ViewLeft: View {
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .center, spacing: 20.0){
				Spacer()
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)
					
					Text("A space is a canvas")
						.font(.custom("Sohne-Kraftig", size: 30))
						.foregroundColor(.sand12)
					
					Text("For all your info - websites, apps, \nnotes, documents, images...")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
					
					Text("And an AI personal assistant")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
					Spacer()
				}
				Spacer()
			}
		}
	}
}

#Preview {
	Step4ViewLeft()
		.frame(width: 600, height: 700)
}
