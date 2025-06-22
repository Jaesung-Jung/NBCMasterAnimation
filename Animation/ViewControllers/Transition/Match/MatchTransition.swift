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

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting, animationController: animationController)
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController.wantsInteractiveStart = false
    animationController.isPresenting = true
    return animationController
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    animationController.isPresenting = false
    return animationController
  }

  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return nil
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    animationController.isPresenting = false
    return animationController
  }
}

// MARK: - MatchTransitiona.AnimationController

extension MatchTransition {
  private class AnimationController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    private var presentationAnimator: UIViewPropertyAnimator?
    private var dismissAnimator: UIViewPropertyAnimator?

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
        presentationInterruptibleAnimator(using: transitionContext).startAnimation()
      } else {
        dismissInterruptibleAnimator(using: transitionContext).startAnimation()
      }
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      if isPresenting {
        presentationAnimator ?? presentationInterruptibleAnimator(using: transitionContext)
      } else {
        dismissAnimator ?? dismissInterruptibleAnimator(using: transitionContext)
      }
    }

    private func presentationInterruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      guard let toViewController = context.viewController(forKey: .to) else {
        context.completeTransition(false)
        return UIViewPropertyAnimator()
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
      animator.addCompletion { position in
        toViewController.view.mask = nil
        context.completeTransition(true)
        self.sourceView.isHidden = true
      }
      animator.addCompletion { [weak self] _ in
        self?.presentationAnimator = nil
      }
      presentationAnimator = animator
      return animator
    }

    private func dismissInterruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      guard let fromView = context.view(forKey: .from) else {
        context.completeTransition(false)
        return UIViewPropertyAnimator()
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
      animator.addCompletion { position in
        switch position {
        case .end:
          context.completeTransition(true)
          self.sourceView.isHidden = false
        default:
          context.completeTransition(false)
        }
      }
      animator.addCompletion { [weak self] _ in
        self?.dismissAnimator = nil
      }
      dismissAnimator = animator
      return animator
    }
  }
}

// MARK: - MatchTransition.PresentationController

extension MatchTransition {
  private class PresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:))).then {
      $0.maximumNumberOfTouches = 1
      $0.delegate = self
    }

    weak var animationController: AnimationController?

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, animationController: AnimationController) {
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      self.animationController = animationController
    }

    override func presentationTransitionWillBegin() {
      super.presentationTransitionWillBegin()
      presentedView?.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
      let viewController = presentedViewController
      switch gesture.state {
      case .began:
        let velocity = gesture.velocity(in: viewController.view)
        guard abs(velocity.x) < abs(velocity.y) else {
          return
        }
        animationController?.wantsInteractiveStart = true
        viewController.dismiss(animated: true)
      case .changed:
        let translation = gesture.translation(in: viewController.view)
        let progress = translation.y / viewController.view.bounds.width
        animationController?.update(progress)
      case .ended:
        if gesture.velocity(in: viewController.view).y > 20 {
          animationController?.finish()
        } else {
          animationController?.cancel()
        }
      default:
        animationController?.cancel()
      }
    }
  }
}
