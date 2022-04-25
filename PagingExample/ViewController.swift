// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let titles = [
      "IDK",
      "Messages",
      "Home",
      "Friends",
      "Stories"
    ]
    let viewControllers: [UIViewController] = titles.enumerated().map { _, _ in
      let vc = UIViewController()
      vc.view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255))/255.0,
                                        green: CGFloat(arc4random_uniform(255))/255.0,
                                        blue: CGFloat(arc4random_uniform(255))/255.0,
                                        alpha: 1)
      return vc
    }
    let navigationItems: [PagingCarouselNavigationView.Item] = titles.enumerated().map { index, title in
      return PagingCarouselNavigationView.Item(title: title,
                                               titleColor: .white,
                                               badgeOffsetFromEdge: 0,
                                               badgeBackgroundColor: .red,
                                               badgeTextColor: .white,
                                               isHidden: false,
                                               badgeCount: index % 2 == 0 ? Int(arc4random_uniform(10)) : 0)
    }
    
    let container = PagingCarouselContainerViewController(childViewControllers: viewControllers,
                                                          items: navigationItems)
    self.addChild(container)
    self.view.addSubview(container.view)
    container.didMove(toParent: self)
    
    // fake update badge counts
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      container
        .setNavigationItems(
          navigationItems.map({
            PagingCarouselNavigationView.Item(title: $0.title,
                                              titleColor: $0.titleColor,
                                              badgeOffsetFromEdge: $0.badgeOffsetFromEdge,
                                              badgeBackgroundColor: $0.badgeBackgroundColor,
                                              badgeTextColor: $0.badgeTextColor,
                                              isHidden: $0.isHidden,
                                              badgeCount: $0.badgeCount > 0 ? 0 : Int(arc4random_uniform(10)))
          })
        )
    }
  }

}
