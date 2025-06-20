//
//  SceneDelegate.swift
//  Animation
//
//  Created by 정재성 on 6/18/25.
//

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    let newWindow = UIWindow(windowScene: windowScene)
    newWindow.rootViewController = NavigationController(rootViewController: HomeViewController())
    newWindow.makeKeyAndVisible()
    window = newWindow
  }
}
