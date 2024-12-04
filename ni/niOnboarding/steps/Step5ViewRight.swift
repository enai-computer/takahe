//
//  Step5ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step5ViewRight: View {
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				VStack(alignment: .center){
					Spacer()
						.frame(height: geometry.size.height * 0.2)
					Image("step4RightSideImg")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.position(x: geometry.size.width / 2, y: geometry.size.height / 3)
					Spacer()
						.frame(height: geometry.size.height * 0.2)
				}
			}
		}
	}
}

#Preview {
	Step5ViewRight()
		.frame(width: 900, height: 700)
}
