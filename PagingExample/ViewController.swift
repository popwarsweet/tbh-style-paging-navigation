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
    let pages: [(UIViewController, PagingCarouselNavigationView.Item)] = (0..<5).map { index in
      let vc = UIViewController()
      vc.view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255))/255.0,
                                        green: CGFloat(arc4random_uniform(255))/255.0,
                                        blue: CGFloat(arc4random_uniform(255))/255.0,
                                        alpha: 1)
      let item = PagingCarouselNavigationView.Item(title: titles[index],
                                                   titleColor: .white,
                                                   badgeOffsetFromEdge: 0,
                                                   badgeBackgroundColor: .red,
                                                   badgeTextColor: .white,
                                                   isHidden: false,
                                                   badgeCount: index % 2 == 0 ? Int(arc4random_uniform(10)) : 0)
      return (vc, item)
    }
    
    let container = PagingCarouselContainerViewController(childViewControllers: pages.map({ $0.0 }),
                                                          items: pages.map({ $0.1 }))
    self.addChild(container)
    self.view.addSubview(container.view)
    container.didMove(toParent: self)
    
    // fake update badge counts
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      container
        .navigationView
        .setNavigationItems(
          pages.map({ $0.1 }).map({
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
