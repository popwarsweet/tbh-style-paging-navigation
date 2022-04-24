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
  }

}
