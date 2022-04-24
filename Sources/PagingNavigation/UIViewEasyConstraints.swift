// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

struct ViewEdges: OptionSet {
  let rawValue: Int
  
  static let top    = ViewEdges(rawValue: 1 << 0)
  static let right  = ViewEdges(rawValue: 1 << 1)
  static let bottom = ViewEdges(rawValue: 1 << 2)
  static let left   = ViewEdges(rawValue: 1 << 3)
  
  static let all: ViewEdges = [.top, .right, .bottom, .left]
}

extension UIView {
  
  @discardableResult
  func matchHeight(to view: UIView, difference: CGFloat = 0, multiplier: CGFloat = 1) -> NSLayoutConstraint {
    let heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .height,
                                              multiplier: multiplier,
                                              constant: difference)
    self.superview?.addConstraint(heightConstraint)
    return heightConstraint
  }
  
  @discardableResult
  func matchWidth(to view: UIView, difference: CGFloat = 0, multiplier: CGFloat = 1) -> NSLayoutConstraint {
    let widthConstraint = NSLayoutConstraint(item: self,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: view,
                                             attribute: .width,
                                             multiplier: multiplier,
                                             constant: difference)
    self.superview?.addConstraint(widthConstraint)
    return widthConstraint
  }
  
  @discardableResult
  func addHorizontallyCenteredConstraint(toView view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerX,
      multiplier: 1,
      constant: offset)
    self.superview?.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addVerticallyCenteredConstraint(toView view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: view,
      attribute: .centerY,
      multiplier: 1,
      constant: offset)
    self.superview?.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addHorizontallyCenteredConstraint(_ offset: CGFloat = 0) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self.superview,
      attribute: .centerX,
      multiplier: 1,
      constant: offset)
    self.superview?.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addVerticallyCenteredConstraint(_ offset: CGFloat = 0) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: self.superview,
      attribute: .centerY,
      multiplier: 1,
      constant: offset)
    self.superview?.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addHorizontallyAndVerticallyCenteredConstraints(_ offset: CGSize = CGSize.zero) -> [NSLayoutConstraint] {
    let c1 = self.addHorizontallyCenteredConstraint(offset.width)
    let c2 = self.addVerticallyCenteredConstraint(offset.height)
    return [c1, c2]
  }
  
  @discardableResult
  func addMaximumWidthConstraint(_ width: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .width,
      relatedBy: .lessThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: width)
    c.priority = priority
    self.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addFixedWidthConstraint(_ width: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: width)
    c.priority = priority
    self.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addFixedHeightConstraint(_ height: CGFloat) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
      item: self,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: height)
    self.addConstraint(c)
    
    return c
  }
  
  @discardableResult
  func addFixedSizeConstraint(_ size: CGSize) -> [NSLayoutConstraint] {
    let w = addFixedWidthConstraint(size.width)
    let h = addFixedHeightConstraint(size.height)
    return [w, h]
  }
  
  @discardableResult
  func pinEdgesToSuperview(edges: ViewEdges = .all, padding: UIEdgeInsets = UIEdgeInsets.zero, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
    var contraints = [NSLayoutConstraint]()
    if edges.contains(.top) {
      contraints.append(self.pinTopToSuperview(padding.top, priority: priority))
    }
    if edges.contains(.right) {
      contraints.append(self.pinRightToSuperview(padding.right, priority: priority))
    }
    if edges.contains(.bottom) {
      contraints.append(self.pinBottomToSuperview(padding.bottom, priority: priority))
    }
    if edges.contains(.left) {
      contraints.append(self.pinLeftToSuperview(padding.left, priority: priority))
    }
    return constraints
  }
  
  @discardableResult
  func pinTopToLayoutGuide(of controller: UIViewController,
                           padding: CGFloat = 0,
                           priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let top = NSLayoutConstraint(
      item: self,
      attribute: .top,
      relatedBy: .equal,
      toItem: controller.topLayoutGuide,
      attribute: .bottom,
      multiplier: 1,
      constant: padding)
    top.priority = priority
    self.superview?.addConstraint(top)
    
    return top
  }
  
  @discardableResult
  func pinBottomToLayoutGuide(of controller: UIViewController,
                              padding: CGFloat = 0,
                              priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if #available(iOS 11, *) {
      constraint = NSLayoutConstraint(
        item: self,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: controller.view.safeAreaLayoutGuide,
        attribute: .bottom,
        multiplier: 1,
        constant: padding)
    } else {
      constraint = NSLayoutConstraint(
        item: self,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: controller.bottomLayoutGuide,
        attribute: .bottom,
        multiplier: 1,
        constant: padding)
    }
    constraint.priority = priority
    self.superview?.addConstraint(constraint)
    
    return constraint
  }
  
  @discardableResult
  func pinTopToSuperview(_ padding: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let top = NSLayoutConstraint(
      item: self,
      attribute: .top,
      relatedBy: relation,
      toItem: self.superview,
      attribute: .top,
      multiplier: 1,
      constant: padding)
    top.priority = priority
    self.superview?.addConstraint(top)
    
    return top
  }
  
  @discardableResult
  func pinLeftToSuperview(_ padding: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let left = NSLayoutConstraint(
      item: self,
      attribute: .left,
      relatedBy: relation,
      toItem: self.superview,
      attribute: .left,
      multiplier: 1,
      constant: padding)
    left.priority = priority
    self.superview?.addConstraint(left)
    
    return left
  }
  
  @discardableResult
  func pinBottomToSuperview(_ padding: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let bottom = NSLayoutConstraint(
      item: self,
      attribute: .bottom,
      relatedBy: relation,
      toItem: self.superview,
      attribute: .bottom,
      multiplier: 1,
      constant: -padding)
    self.superview?.addConstraint(bottom)
    
    return bottom
  }
  
  @discardableResult
  func pinRightToSuperview(_ padding: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let right = NSLayoutConstraint(
      item: self,
      attribute: .right,
      relatedBy: relation,
      toItem: self.superview,
      attribute: .right,
      multiplier: 1,
      constant: -padding)
    right.priority = priority
    self.superview?.addConstraint(right)
    
    return right
  }
  
  @discardableResult
  func pinRightToViewsLeft(_ view: UIView, padding: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let right = NSLayoutConstraint(
      item: self,
      attribute: .right,
      relatedBy: .equal,
      toItem: view,
      attribute: .left,
      multiplier: 1,
      constant: padding)
    right.priority = priority
    self.superview?.addConstraint(right)
    return right
  }
  
  @discardableResult
  func pinTopToViewsBottom(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
    let top = NSLayoutConstraint(
      item: self,
      attribute: .top,
      relatedBy: .equal,
      toItem: view,
      attribute: .bottom,
      multiplier: 1,
      constant: padding)
    self.superview?.addConstraint(top)
    return top
  }
  
  @discardableResult
  func pinTopToViewsTop(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
    let top = NSLayoutConstraint(
      item: self,
      attribute: .top,
      relatedBy: .equal,
      toItem: view,
      attribute: .top,
      multiplier: 1,
      constant: padding)
    self.superview?.addConstraint(top)
    return top
  }
  
  @discardableResult
  func pinBottomToViewsTop(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
    let bottom = NSLayoutConstraint(
      item: self,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: view,
      attribute: .top,
      multiplier: 1,
      constant: padding)
    self.superview?.addConstraint(bottom)
    return bottom
  }
  
  @discardableResult
  func pinBottomToViewsBottom(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
    let bottom = NSLayoutConstraint(
      item: self,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: view,
      attribute: .bottom,
      multiplier: 1,
      constant: padding)
    self.superview?.addConstraint(bottom)
    return bottom
  }
  
  @discardableResult
  func pinLeftToViewsRight(_ view: UIView, padding: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
    let left = NSLayoutConstraint(
      item: self,
      attribute: .left,
      relatedBy: .equal,
      toItem: view,
      attribute: .right,
      multiplier: 1,
      constant: padding)
    self.superview?.addConstraint(left)
    return left
  }
  
}
