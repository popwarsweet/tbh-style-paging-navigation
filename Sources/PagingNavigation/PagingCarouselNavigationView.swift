// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

@objc(APFPagingCarouselNavigationView)
public class PagingCarouselNavigationView: UIView {
  
  // MARK: - NavigationItem

  @objc(APFNavigationItem)
  public class Item: NSObject {
    public let title: String
    public let titleColor: UIColor
    public let badgeAlignment: BadgedSpringButton.Alignment
    public let badgeOffsetFromEdge: CGFloat
    public let badgeBackgroundColor: UIColor
    public let badgeTextColor: UIColor
    public let isHidden: Bool
    public let badgeCount: Int
    
    @objc
    public init(title: String,
                titleColor: UIColor,
                badgeOffsetFromEdge: CGFloat,
                badgeBackgroundColor: UIColor,
                badgeTextColor: UIColor,
                isHidden: Bool,
                badgeCount: Int) {
      self.title = title
      self.titleColor = titleColor
      self.badgeAlignment = .right
      self.badgeOffsetFromEdge = badgeOffsetFromEdge
      self.badgeBackgroundColor = badgeBackgroundColor
      self.badgeTextColor = badgeTextColor
      self.isHidden = isHidden
      self.badgeCount = badgeCount
    }
  }
  
  // Consts
  static public var instrinsicContentHeight: CGFloat {
    return 44
  }
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: Self.instrinsicContentHeight)
  }
  //
  private let itemsContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  // Subviews
  private(set) var bottomBorder: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 1, alpha: 0.25)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    return view
  }()
  private var itemContainerTopConstraint: NSLayoutConstraint?
  private var itemContainerTopPadding: CGFloat = 0 {
    didSet {
      if let constraint = itemContainerTopConstraint {
        constraint.constant = itemContainerTopPadding
        self.layoutIfNeeded()
      }
    }
  }
  private var bottomBorderHeightConstraint: NSLayoutConstraint!
  public var bottomBorderHeight: CGFloat {
    set {
      bottomBorderHeightConstraint.constant = newValue
      self.layoutIfNeeded()
    }
    get {
      return bottomBorderHeightConstraint.constant
    }
  }
  
  /// The constraints used to set origin of each view.
  private var originConstraints = [NSLayoutConstraint]()
  /// The positions of each item at each page. [buttonIndex][pageIndex]
  // TODO: Y origins are now managed by constraints, we can use [[Int]] here instead of [[CGPoint]]
  private(set) var itemPositions = [[CGPoint]]()
  /// The minimum padding allowed between each item on screen.
  public var minimumInteritemPadding: CGFloat = 12 {
    didSet {
      // TODO: Update layout.
    }
  }
  /// The padding used on the edges of the view if greater than `minimumInteritemPadding` is available between items.
  public var maximumEdgePadding: CGFloat = 14 {
    didSet {
      // TODO: Update layout.
    }
  }
  /// The minimum opacity of items when pushed from center.
  public var minimumOpacity = 0.25
  /// The maximum count of characters before a label will be truncated.
  public var maximumCountOfCharacters = 15
  /// The count of characters that the text will be truncated to if max count is reached.
  public var truncationCharacterCount = 7
  /// The items currently being managed by the navigation view.
  private(set) var items = [BadgedSpringButton]()
  /// The navigation items. Use `setNavigationItems` to update them.
  private(set) var navigationItems = [Item]()
  /// The scroll view that is adjusting layout of items.
  private weak var scrollView: UIScrollView?
  /// Called when the user taps one of the navigation items.
  public var didTapItem: ((Int) -> Void)?
  /// A view to be placed on the leftmost edge of the navigation view. It will be scroll with the navigationItems but will not be able to be centered like normal item.
  public var leftNavigationItem: UIView? {
    didSet {
      // Clean up old view.
      leftNavigationItemLeadingEdgeConstraint = nil
      if let oldValue = oldValue {
        oldValue.removeFromSuperview()
      }
      
      // Add new view.
      if let newValue = leftNavigationItem {
        itemsContainer.addSubview(newValue)
        newValue.addVerticallyCenteredConstraint()
        leftNavigationItemLeadingEdgeConstraint = newValue.pinLeftToSuperview()
      }
    }
  }
  private var leftNavigationItemLeadingEdgeConstraint: NSLayoutConstraint?
  
  public override var bounds: CGRect {
    didSet {
      // Update origin constraints if width changes.
      if oldValue.width != bounds.width {
        layoutNavigationButtons(items)
      }
    }
  }
  
  
  // MARK: - Init
  
  private func commonInit() {
    // Add subviews.
    // Add border.
    self.addSubview(bottomBorder)
    bottomBorder.pinEdgesToSuperview(edges: [.left, .bottom, .right])
    bottomBorderHeightConstraint = bottomBorder.addFixedHeightConstraint(1)
    
    // Add item container.
    self.addSubview(itemsContainer)
    itemsContainer.pinEdgesToSuperview(edges: [.left, .bottom, .right])
    itemContainerTopConstraint = itemsContainer.pinTopToSuperview(itemContainerTopPadding)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  
  // MARK: - Layout
  
  private func layoutNavigationButtons(_ items: [BadgedSpringButton]) {
    // Remove old origin constraints
    NSLayoutConstraint.deactivate(originConstraints)
    originConstraints = []
    
    // Init array of zero'd CGPoint values.
    var itemPositions = navigationItems.map { _ in
      return Array(repeating: CGPoint.zero, count: navigationItems.count)
    }
    
    // Cache layout positions at each page.
    for i in 0..<items.count {
      let currentItem = items[i]
      // Get ideal frames for the center item and the items directly surrounding it.
      let centerFrame = CGRect(x: (self.bounds.width - currentItem.bounds.width) / 2,
                               y: (self.bounds.height - currentItem.bounds.height) / 2,
                               width: currentItem.bounds.width,
                               height: currentItem.bounds.height)
      
      for k in 0..<items.count {
        let yOrigin = (self.itemsContainer.bounds.height - items[i].bounds.height) / 2
        if k < i - 1 {
          // Push all views less than i - 1 offscreen to the left.
          itemPositions[k][i] = CGPoint(x: -(items[k].bounds.width * 1.5), y: yOrigin)
        } else if k == i - 1 {
          // Push item to left of center view, ensuring that it's not passed the maximumEdgePadding.
          let leftOfCenterItem = items[k]
          let xOrigin = min(maximumEdgePadding,
                            centerFrame.origin.x - leftOfCenterItem.bounds.width - minimumInteritemPadding)
          itemPositions[k][i] = CGPoint(x: xOrigin,
                                        y: yOrigin)
        } else if k == i {
          // Center item.
          itemPositions[k][i] = CGPoint(x: centerFrame.origin.x, y: yOrigin)
        } else if k == i + 1 {
          // Push to right of the center view, ensuring that it's not passed the maximumEdgePadding.
          let rightOfCenterItem = items[k]
          let xOrigin = max(self.bounds.width - rightOfCenterItem.bounds.width - maximumEdgePadding,
                            centerFrame.maxX + minimumInteritemPadding)
          itemPositions[k][i] = CGPoint(x: xOrigin,
                                        y: yOrigin)
        } else if k > i + 1 {
          // Push all views greater than i + 1 offscreen to the right.
          itemPositions[k][i] = CGPoint(x: self.bounds.width + 1.5 * items[i].bounds.width,
                                        y: yOrigin)
        }
      }
    }
    
    // Set initial positions.
    self.itemPositions = itemPositions
    for i in 0..<items.count {
      let button = items[i]
      // Pin origin
      let firstOrigin = itemPositions[i][0].x
      originConstraints.append(button.pinLeftToSuperview(firstOrigin))
    }
    
    // Update first pass if scrollView is already set.
    if let scrollView = scrollView {
      updateVisualDisplay(forScrollPosition: scrollView.contentOffset, scrollViewBounds: scrollView.bounds)
    }
  }
  
  
  // MARK: - Updating items
  
  @objc
  public func setNavigationItems(_ navigationItems: [Item]) {
    var titles = navigationItems.map { $0.title }
    let currentTitles = self.navigationItems.map { $0.title }
    
    // If all the titles are the same, we can just update badge count and return.
    if titles == currentTitles, titles.count == items.count {
      for counter in 0..<items.count {
        let button = items[counter]
        let badgeCount = navigationItems[counter].badgeCount
        
        button.badgeCount = badgeCount
        
        // Show badge if there's a count.
        if badgeCount > 0 {
          button.showBadge(animated: false)
        } else {
          button.hideBadge(animated: false)
        }
      }
      return
    }
    
    // Size all items.
    for i in 0..<titles.count {
      // Truncate in the special case when the string within the label is too long.
      if titles[i].count > maximumCountOfCharacters {
        titles[i] = (titles[i] as NSString).substring(to: truncationCharacterCount) + "\u{2026}"
      }
    }
    
    // Clean up old state.
    items.forEach { $0.removeFromSuperview() }
    items = []
    self.navigationItems = navigationItems
    
    for i in 0..<navigationItems.count {
      // Create badged button for each navigation item and add it to the view hierarchy.
      let currentItem = navigationItems[i]
      let button = BadgedSpringButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      button.font = UIFont.systemFont(ofSize: 17, weight: .bold)
      button.text = titles[i]
      button.textColor = currentItem.titleColor
      button.buttonBackgroundColor = .clear
      button.hitTestEdgeInsets = UIEdgeInsets(top: -20,
                                              left: -minimumInteritemPadding / 2,
                                              bottom: -20,
                                              right: -minimumInteritemPadding / 2)
      button.didTouchUpInside = { [unowned self] btn in
        guard let buttonIndex = self.items.firstIndex(of: (btn as! BadgedSpringButton)) else { return }
        self.didTapItem?(buttonIndex)
      }
      button.sizeToFit()
      
      // Setup badge.
      button.badgeView.backgroundColor = currentItem.badgeBackgroundColor
      button.badgeLabel.textColor = currentItem.badgeTextColor
      button.badgeView.layer.cornerRadius = 3.5
      button.leftOffset = currentItem.badgeOffsetFromEdge
      button.rightOffset = currentItem.badgeOffsetFromEdge
      button.topOffset = 6.5
      button.setAlignment(currentItem.badgeAlignment)
      button.isHidden = currentItem.isHidden
      button.badgeCount = currentItem.badgeCount
      
      // Show badge if there's a count.
      if currentItem.badgeCount > 0 {
        button.showBadge(animated: false)
      } else {
        button.hideBadge(animated: false)
      }
      
      itemsContainer.addSubview(button)
      items.append(button)
      
      // Pin to center if this is the first item, all others will be aligned to this first view's baseline.
      if i == 0 {
        button.addVerticallyCenteredConstraint()
      } else {
        let constraint = NSLayoutConstraint(item: button,
                                            attribute: .firstBaseline,
                                            relatedBy: .equal,
                                            toItem: self.items[0],
                                            attribute: .firstBaseline,
                                            multiplier: 1,
                                            constant: 0)
        self.itemsContainer.addConstraint(constraint)
      }
    }
    
    // Layout for initial bounds.
    layoutNavigationButtons(items)
  }
  
  
  // MARK: - Hit test
  
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    var navigationButtons: [UIView] = items
    if let leftNavigationItem = leftNavigationItem {
      navigationButtons.append(leftNavigationItem)
    }
    
    for button in navigationButtons {
      let convertedPoint = button.convert(point, from: self)
      if let view = button.hitTest(convertedPoint, with: event) {
        return view
      }
    }
    
    return nil
  }
}


// MARK: - Layout updates

extension PagingCarouselNavigationView {
  private func updateVisualDisplay(forScrollPosition position: CGPoint, scrollViewBounds: CGRect) {
    guard items.count > 0 else { return }
    guard scrollViewBounds.size.equalTo(.zero) == false else { return }
    
    // Get current page of scroll view.
    let xOffset = position.x
    let currentPage = Int(xOffset / scrollViewBounds.width)
    let currentPageFloat = min(max(0, xOffset / scrollViewBounds.width), CGFloat(items.count - 1))
    var currentItemPositions = itemPositions
    
    // Update left view if we have one.
    if let _ = leftNavigationItem {
      leftNavigationItemLeadingEdgeConstraint?.constant = -max(0, xOffset)
    }
    
    // Get the indices of the two visible pages.
    let leftPage = Int(floor(currentPageFloat))
    let rightPage = Int(ceil(currentPageFloat))
    
    // Get the percent of the page that has been scroll offscreen, we'll use this to interpolate between the two positions of the title items.
    let pointsOverPage = xOffset - (CGFloat(currentPage) * scrollViewBounds.width)
    let percentageOverLeftPage = pointsOverPage / scrollViewBounds.width
    
    // Interpolate position, we really only need to do this for the onscreen items but it's not intensive since we typically have so few items..
    for i in 0..<currentItemPositions.count {
      let totalPageMovement = currentItemPositions[i][rightPage].x - currentItemPositions[i][leftPage].x
      currentItemPositions[i][leftPage].x =
        currentItemPositions[i][leftPage].x + percentageOverLeftPage * totalPageMovement
    }
    
    for i in 0..<items.count {
      // Update frames of all views.
      originConstraints[i].constant = currentItemPositions[i][leftPage].x
      // Get distance from center so we can apply opacity or other transformations.
      let itemCenterX = currentItemPositions[i][leftPage].x + (items[i].bounds.width / 2)
      let maxDistanceFromCenter = self.bounds.width / 2
      let distanceFromCenter = abs(itemCenterX - maxDistanceFromCenter)
      let maxOpacityDifference = 1.0 - minimumOpacity
      items[i].button.titleLabel?.alpha = 1 - CGFloat(maxOpacityDifference) * (distanceFromCenter / maxDistanceFromCenter)
    }
    self.layoutIfNeeded()
  }
}


// MARK: - PagingNavigation

extension PagingCarouselNavigationView {
  func containerDidBeginScrolling(scrollView: UIScrollView) {
    // Hang on to scroll view so we can re-layout from it later.
    self.scrollView = scrollView
  }
  func containerDidScroll(scrollView: UIScrollView) {
    updateVisualDisplay(forScrollPosition: scrollView.contentOffset, scrollViewBounds: scrollView.bounds)
  }
  func containerDidEndScrolling(scrollView: UIScrollView) {
  }
  func scrollViewBoundsDidChange(scrollView: UIScrollView) {
    updateVisualDisplay(forScrollPosition: scrollView.contentOffset, scrollViewBounds: scrollView.bounds)
  }
  func scrollViewDidManuallyScroll(scrollView: UIScrollView) {
    updateVisualDisplay(forScrollPosition: scrollView.contentOffset, scrollViewBounds: scrollView.bounds)
  }
}
