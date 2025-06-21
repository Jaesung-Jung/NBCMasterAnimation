//
//  AlertTransition.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

final class AlertTransition: NSObject, UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting)
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    PresentationAnimator()
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    DismissalAniamtor()
  }
}

// MARK: - AlertTransition.PresentationController

extension AlertTransition {
  private class PresentationController: UIPresentationController {
    let backgroundView = UIView().then {
      $0.backgroundColor = .black.withAlphaComponent(0.5)
      $0.alpha = 0
    }

    override func presentationTransitionWillBegin() {
      super.presentationTransitionWillBegin()
      containerView?.addSubview(backgroundView)
      let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: .smooth(duration: 0.3))
      animator.addAnimations {
        self.backgroundView.alpha = 1
      }
      animator.startAnimation()
    }

    override func dismissalTransitionWillBegin() {
      super.dismissalTransitionWillBegin()
      let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: .smooth(duration: 0.3))
      animator.addAnimations {
        self.backgroundView.alpha = 0
      }
      animator.startAnimation()
    }

    override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      backgroundView.frame = containerView?.bounds ?? .zero
    }
  }
}

// MARK: - AlertTransition.PresentationAnimator

extension AlertTransition {
  private class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard let toViewController = transitionContext.viewController(forKey: .to) else {
        transitionContext.completeTransition(true)
        return
      }
      transitionContext.containerView.addSubview(toViewController.view)
      toViewController.view.frame = transitionContext.finalFrame(for: toViewController)

      toViewController.view.alpha = 0
      toViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        .concatenating(CGAffineTransform(translationX: 0, y: 40))

      let duration = transitionDuration(using: transitionContext)
      let animator = UIViewPropertyAnimator(duration: duration, timingParameters: .bouncy(duration: duration))
      animator.addAnimations {
        toViewController.view.alpha = 1
        toViewController.view.transform = .identity
      }
      animator.addCompletion {
        transitionContext.completeTransition($0 == .end)
      }
      animator.startAnimation()
    }
  }
}

// MARK: - AlertTransition.DismissalAniamtor

extension AlertTransition {
  private class DismissalAniamtor: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard let fromViewController = transitionContext.viewController(forKey: .from) else {
        transitionContext.completeTransition(true)
        return
      }

      let duration = transitionDuration(using: transitionContext)
      let animator = UIViewPropertyAnimator(duration: duration, timingParameters: .bouncy(duration: duration))
      animator.addAnimations {
        fromViewController.view.alpha = 0
        fromViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
          .concatenating(CGAffineTransform(translationX: 0, y: 40))
      }
      animator.addCompletion {
        transitionContext.completeTransition($0 == .end)
      }
      animator.startAnimation()
    }
  }
}
