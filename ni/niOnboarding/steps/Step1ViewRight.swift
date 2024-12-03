//
//  Step1ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step1ViewRight: View {
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				Image("NZMilfordSound")
					.resizable()
					.aspectRatio(nil, contentMode: .fill)
				VStack(alignment: .center){
					Spacer()
						.frame(height: geometry.size.height * 0.2)
					Image("EnaiI")
						.resizable()
						.aspectRatio(0.43, contentMode: .fit)
						.opacity(0.6)
						.position(x: geometry.size.width / 2, y: geometry.size.height / 3)
					Spacer()
						.frame(height: geometry.size.height * 0.2)
				}
			}
		}
	}
}

#Preview {
	Step1ViewRight()
		.frame(width: 900, height: 700)
}
