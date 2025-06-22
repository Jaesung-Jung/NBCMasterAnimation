//
//  MatchTransition.swift
//  Animation
//
//  Created by 정재성 on 6/22/25.
//

import UIKit
import Then

final class MatchTransition: NSObject, UIViewControllerTransitioningDelegate {
  private let animationController: AnimationController

  init(sourceView: UIView, sourceRect: CGRect) {
    self.animationController = AnimationController(sourceView: sourceView, sourceRect: sourceRect)
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController.isPresenting = true
    return animationController
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController.isPresenting = false
    return animationController
  }
}

// MARK: - MatchTransitiona.AnimationController

extension MatchTransition {
  private class AnimationController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    let sourceView: UIView
    let sourceRect: CGRect

    var isPresenting: Bool = true

    override var duration: CGFloat { 0.3 }

    init(sourceView: UIView, sourceRect: CGRect) {
      self.sourceView = sourceView
      self.sourceRect = sourceRect
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      if isPresenting {
        animateTransitionForPresenting(using: transitionContext)
      } else {
        animateTransitionForDismissing(using: transitionContext)
      }
    }

    private func animateTransitionForPresenting(using context: UIViewControllerContextTransitioning) {
      guard let toViewController = context.viewController(forKey: .to) else {
        context.completeTransition(false)
        return
      }
      let finalFrame = context.finalFrame(for: toViewController)
      context.containerView.addSubview(toViewController.view)

      let maskRect = CGRect(
        x: finalFrame.minX,
        y: finalFrame.midY - finalFrame.width * 0.5,
        width: finalFrame.width,
        height: finalFrame.width
      )
      let maskView = UIView(frame: maskRect).then {
        $0.backgroundColor = .black
      }
      toViewController.view.mask = maskView

      let scale = sourceRect.width / finalFrame.width
      let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
      let translationTransform = CGAffineTransform(translationX: sourceRect.midX - finalFrame.midX, y: sourceRect.midY - finalFrame.midY)
      toViewController.view.transform = scaleTransform.concatenating(translationTransform)

      let animator = UIViewPropertyAnimator(duration: duration, timingParameters: .snappy(duration: duration))
      animator.addAnimations {
        maskView.frame = finalFrame
        maskView.layer.cornerRadius = 50
        toViewController.view.transform = .identity
      }
      animator.addCompletion { _ in
        toViewController.view.mask = nil
        context.completeTransition(true)
      }
      animator.startAnimation()
    }

    private func animateTransitionForDismissing(using context: UIViewControllerContextTransitioning) {
      guard let fromView = context.view(forKey: .from) else {
        context.completeTransition(false)
        return
      }
      let frame = fromView.bounds

      let maskView = UIView(frame: frame).then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 50
      }
      fromView.mask = maskView

      let finalMaskRect = CGRect(
        x: frame.minX,
        y: frame.midY - frame.width * 0.5,
        width: frame.width,
        height: frame.width
      )
      let scale = sourceRect.width / frame.width
      let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
      let translationTransform = CGAffineTransform(translationX: sourceRect.midX - frame.midX, y: sourceRect.midY - frame.midY)

      let animator = UIViewPropertyAnimator(duration: duration, timingParameters: .snappy(duration: duration))
      animator.addAnimations {
        maskView.frame = finalMaskRect
        maskView.layer.cornerRadius = 0
        fromView.transform = scaleTransform.concatenating(translationTransform)
      }
      animator.addCompletion { _ in
        context.completeTransition(true)
      }
      animator.startAnimation()
    }
  }
}
