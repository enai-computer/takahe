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
				Image("step1RightSideImg")
					.resizable()
					.aspectRatio(nil, contentMode: .fill)
//					.position(x: geometry.size.width)
				VStack(alignment: .center){
					Spacer()
						.frame(height: geometry.size.height * 0.2)
					Image("step1RightSideMark")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.opacity(1.0)
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
		.frame(width: 900, height:900)
}
