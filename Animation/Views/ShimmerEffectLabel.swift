//
//  BouncingLabel.swift
//  Animation
//
//  Created by 정재성 on 1/28/26.
//

import SwiftUI
import HostingView
import Then

final class ShimmerEffectLabel: UIView {
  private let contentView: StatefulHostingView<Configuration>

  var text: String {
    get { contentView.state.text }
    set { contentView.state.text = newValue }
  }

  var font: UIFont {
    get { contentView.state.font }
    set { contentView.state.font = newValue }
  }

  override var intrinsicContentSize: CGSize {
    contentView.intrinsicContentSize
  }

  init(text: String) {
    let configuration = Configuration(
      text: text,
      font: .systemFont(ofSize: 17, weight: .regular)
    )
    self.contentView = StatefulHostingView(state: configuration) {
      AnimatedText(text: $0.text, font: $0.font)
    }
    super.init(frame: .zero)
    addSubview(contentView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }
}

// MARK: - ShimmerEffectLabel.Configuration

extension ShimmerEffectLabel {
  private struct Configuration: Hashable {
    var text: String
    var font: UIFont
  }
}

// MARK: - ShimmerEffectLabel.AnimatedText

extension ShimmerEffectLabel {
  private struct AnimatedText: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme

    let text: String
    let font: UIFont

    var body: some View {
      Text(text)
        .font(Font(font))
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .overlay {
          LinearGradient(
            colors: [.clear, colorScheme == .light ? .white.opacity(0.75) : .black.opacity(0.75), .clear],
            startPoint: UnitPoint(x: isAnimating ? 1 : -1, y: 0.5),
            endPoint: UnitPoint(x: isAnimating ? 2 : 0, y: 0.5)
          )
          .mask {
            Text(text)
              .font(Font(font))
              .multilineTextAlignment(.center)
          }
        }
        .onAppear {
          withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            isAnimating.toggle()
          }
        }
    }
  }
}

// MARK: - ShimmerEffectLabel Preview

#Preview {
  ShimmerEffectLabel(text: "Shimmer Effect Text").then {
    $0.font = .systemFont(ofSize: 30, weight: .black)
  }
}
