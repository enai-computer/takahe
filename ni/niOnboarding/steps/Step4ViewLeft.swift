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
					
					Text("Switch context effortlessly")
						.font(.custom("Sohne-Buch", size: 30))
						.foregroundColor(.sand12)
					
					Text("And less frequently. Keeping \neverything related to each project in \nits own space minimizes your risk of distractions \nto support your attention.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand115)

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
