//
//  Step2ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step2ViewLeft: View {
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .center, spacing: 20.0){
				Spacer()
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)

					Text("Computers are getting busier.")
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
	Step2ViewLeft()
		.frame(width: 600, height: 700)
}
