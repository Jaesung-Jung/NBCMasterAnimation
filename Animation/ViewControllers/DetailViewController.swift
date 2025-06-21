//
//  DetailViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

class DetailViewController: UIViewController {
  var menu: Menu? { nil }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = menu.map(\.description)
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
  }
}
