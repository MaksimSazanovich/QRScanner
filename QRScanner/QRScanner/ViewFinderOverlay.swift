// ViewFinderOverlay.swift

import Foundation
import SwiftUI

struct ViewFinderOverlay: View {
    var size: CGFloat
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: size, height: size)
                                .blendMode(.destinationOut)
                        )
                        .compositingGroup()
                )
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.15), lineWidth: 1)
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    ViewFinderOverlay(size: 200)
}
