//
//  Step5ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 29/11/24.
//

import SwiftUI

struct Step5ViewLeft: View {
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 20.0){
				Spacer()
					.frame(width: 120.0)
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)
					
					Text("Switch context effortlessly")
						.font(.custom("Sohne-Buch", size: 30))
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 0.8, x: 0, y: 0)
							)
						)
					
					Spacer()
						.frame(height: 15.0)
					
					Text("And less frequently. Keeping \neverything related to each project in \nits own space minimizes your risk of \ndistractions to support your attention.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundStyle(
							Color.sand115.shadow(
								.inner(color: .white, radius: 0.4, x: 0, y: 0)
							)
						)
						.lineSpacing(3.5)

					Spacer()
				}
				Spacer()
			}
		}
	}
}

#Preview {
	Step5ViewLeft()
		.frame(width: 600, height: 700)
}
