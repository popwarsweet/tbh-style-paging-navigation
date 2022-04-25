// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

@objc(APFPagingCarouselContainerView)
public class PagingCarouselContainerViewController: UIViewController {
  
  /// Scroll view managing scroll behavior of child view controllers and navigation items.
  public let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.isPagingEnabled = true
    sv.showsHorizontalScrollIndicator = false
    sv.showsVerticalScrollIndicator = false
    sv.bounces = false
    return sv
  }()
  /// The navigation view hosting badged spring buttons
  public let navigationView: PagingCarouselNavigationView = {
    let view = PagingCarouselNavigationView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  /// The view containing all of the child view controllers, only here to make layout a tad easier.
  public let contentView: UIView = {
    let view = UIView();
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  /// Adjusted for easy layout of child view controllers, use safeAreaInset.top if you want to keep content below the navigation view.
  public override var additionalSafeAreaInsets: UIEdgeInsets {
    set { super.additionalSafeAreaInsets = newValue }
    get { UIEdgeInsets(top: navigationView.frame.height, left: 0, bottom: 0, right: 0) }
  }
  
  public init(childViewControllers: [UIViewController], items: [PagingCarouselNavigationView.Item]) {
    super.init(nibName: nil, bundle: nil)
    
    guard childViewControllers.count == items.count else {
      preconditionFailure("childViewControllers.count != items.count")
    }
    
    // Configure subviews
    self.view.addSubview(scrollView)
    scrollView.pinEdgesToSuperview()
    scrollView.addSubview(contentView)
    
    self.view.addSubview(navigationView)
    navigationView.setNavigationItems(items)
    navigationView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    navigationView.pinEdgesToSuperview(edges: [.left, .right], padding: .zero, priority: .required)
    
    // Layout
    NSLayoutConstraint.activate([
      contentView.widthAnchor.constraint(equalToConstant: CGFloat(childViewControllers.count) * UIScreen.main.bounds.width),
      contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
      
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
    ])
    
    // Set horizontal constraints relative to scroll view contentLayoutGuide
    if let first = childViewControllers.first?.view, let last = childViewControllers.last?.view {
      var previousPageView = first
      for controller in childViewControllers {
        let pageView = controller.view!
        pageView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(controller)
        contentView.addSubview(pageView)
        controller.didMove(toParent: self)
        
        if pageView === first {
          pageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        } else if view === last {
          pageView.leadingAnchor.constraint(equalTo: previousPageView.trailingAnchor).isActive = true
          pageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        } else {
          pageView.leadingAnchor.constraint(equalTo: previousPageView.trailingAnchor).isActive = true
        }
        previousPageView = pageView

        NSLayoutConstraint.activate([
          // Set vertical constraints to scroll view contentLayoutGuide
          pageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
          pageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

          // Set width and height of subviews relative to scroll view's frame
          pageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
          pageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])
      }
    }
    
    registerNavigationTouchEvents(scrollView: scrollView,
                                  navigationView: navigationView)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func registerNavigationTouchEvents(scrollView: UIScrollView, navigationView: PagingCarouselNavigationView) {
    scrollView.delegate = self
    for pageCounter in 0..<navigationView.items.count {
      let pageOffset = CGFloat(pageCounter) * UIScreen.main.bounds.width
      let item = navigationView.items[pageCounter]
      item.didTouchUpInside = { [weak scrollView] _ in
        scrollView?.setContentOffset(CGPoint(x: pageOffset, y: 0), animated: true)
      }
    }
  }
}

extension PagingCarouselContainerViewController: UIScrollViewDelegate {
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    navigationView.scrollViewBoundsDidChange(scrollView: scrollView)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    navigationView.containerDidBeginScrolling(scrollView: scrollView)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    navigationView.containerDidScroll(scrollView: scrollView)
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    navigationView.containerDidEndScrolling(scrollView: scrollView)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    navigationView.containerDidEndScrolling(scrollView: scrollView)
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if decelerate == false {
      navigationView.containerDidEndScrolling(scrollView: scrollView)
    }
  }
}

