//
//  Step4ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step4ViewRight: View {
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				VStack(alignment: .center){
					Spacer()
					HStack(alignment: .center){
//						Spacer()
//							.frame(width: 0.0)
						Image("step4RightSideImg")
							.resizable()
							.aspectRatio(nil, contentMode: .fit)
						Spacer()
							.frame(minWidth: 6.0, maxWidth: geometry.size.width * 0.14)
					}
					Spacer()
				}
			}
		}
	}
}

#Preview {
	Step4ViewRight()
		.frame(width: 900, height: 900)
}
