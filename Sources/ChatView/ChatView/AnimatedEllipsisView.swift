//
//  SwiftUIView.swift
//  
//
//  Created by Jim Conroy on 16/10/2023.
//

import SwiftUI

class AnimatedEllipsisViewModel: ObservableObject {
    @Published var visibleDots = 0
    var timer: Timer?

    func startAnimating() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.visibleDots = (self.visibleDots + 1) % 4
        }
    }

    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopAnimating()
    }
}

public struct AnimatedEllipsisView: View {
    var color: Color
    var size: CGFloat
    @StateObject private var viewModel = AnimatedEllipsisViewModel()
    
    public init(color: Color, size: CGFloat) {
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        HStack(spacing: size / 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(color)
                    .opacity(viewModel.visibleDots > index ? 1 : 0.3)
            }
        }
        .onAppear {
            viewModel.startAnimating()
        }
        .onDisappear {
            viewModel.stopAnimating()
        }
    }
}


#Preview {
    AnimatedEllipsisView(color: .red, size: 5)
}
