//
//  SwiftUIView.swift
//  
//
//  Created by Jamie Conroy on 16/10/2023.
//

import SwiftUI

/// `AnimatedEllipsisViewModel` is a class that handles the logic for the animation of the ellipsis.
/// It uses a timer to periodically update the number of visible dots, creating an animation effect.
class AnimatedEllipsisViewModel: ObservableObject {
    @Published var visibleDots = 0  // The number of currently visible dots
    var timer: Timer?  // The timer used to create the animation effect

    /// Starts the animation by scheduling a timer that updates the number of visible dots every 0.5 seconds.
    func startAnimating() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.visibleDots = (self.visibleDots + 1) % 4
        }
    }

    /// Stops the animation by invalidating and nullifying the timer.
    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    /// Deinitializer that ensures the animation stops when the instance is deallocated.
    deinit {
        stopAnimating()
    }
}

/// `AnimatedEllipsisView` is a SwiftUI view that displays an animated ellipsis.
/// The ellipsis consists of three dots that fade in and out in sequence, creating an animation effect.
public struct AnimatedEllipsisView: View {
    var color: Color  // The color of the dots
    var size: CGFloat  // The size of the dots
    @StateObject private var viewModel = AnimatedEllipsisViewModel()  // The view model that handles the animation logic
    
    /// Initializes a new AnimatedEllipsisView with the specified color and size.
    public init(color: Color, size: CGFloat) {
        self.color = color
        self.size = size
    }
    
    /// The body of the AnimatedEllipsisView.
    /// It consists of a horizontal stack of three dots, which fade in and out in sequence according to the view model's visibleDots property.
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

struct AnimatedEllipsisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnimatedEllipsisView(color: .red, size: 5)
        }
    }
}
