// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

public class BadgedSpringButton: SpringButton {
  // Appearance
  var badgeHeight: CGFloat = 18 {
    didSet {
      badgeHeightConstraint.constant = badgeHeight
      badgeView.layer.cornerRadius = badgeHeight/2
      self.layoutIfNeeded()
    }
  }
  var topOffset: CGFloat = -9 {
    didSet {
      topConstraint.constant = topOffset
      self.layoutIfNeeded()
    }
  }
  var rightOffset: CGFloat = -8 {
    didSet {
      rightConstraint.constant = rightOffset
      self.layoutIfNeeded()
    }
  }
  var leftOffset: CGFloat = 8 {
    didSet {
      leftConstraint.constant = leftOffset
      self.layoutIfNeeded()
    }
  }
  var minimumBadgeWidth: CGFloat = 20
  
  // Constraints
  var badgeHeightConstraint: NSLayoutConstraint!
  var badgeWidthConstraint: NSLayoutConstraint!
  var topConstraint: NSLayoutConstraint!
  var rightConstraint: NSLayoutConstraint!
  var leftConstraint: NSLayoutConstraint!
  
  private(set) lazy var badgeViewContainer: UIView = { [unowned self] in
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.frame = CGRect(x: 0, y: 0, width: 0, height: self.badgeHeight)
    view.layer.cornerRadius = self.badgeHeight/2
    return view
    }()
  
  private(set) lazy var badgeView: UIView = { [unowned self] in
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .red
    view.layer.cornerRadius = (self.badgeHeight - 4)/2
    return view
    }()
  
  private(set) lazy var badgeLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 11.2, weight: .bold)
    label.textAlignment = .center
    label.textColor = .white
    return label
    }()
  
  var badgeCount: Int = 0 {
    didSet {
      if badgeCount > 99 {
        badgeLabel.text = "99+"
      } else {
        badgeLabel.text = String(badgeCount)
      }
      
      let constrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: badgeHeight)
      
      badgeWidthConstraint.constant = max(
        badgeLabel.sizeThatFits(constrainedSize).width + 8,
        minimumBadgeWidth)
      updateMask(isShowingBadge: badgeCount > 0)
      
      self.layoutIfNeeded()
    }
  }
  
  // Experimental, will mask underlying label
  var masksImageViewBorder: Bool = false
  
  
  // MARK: - Init
  
  private func commonInit() {
    self.button.addSubview(badgeViewContainer)
    badgeViewContainer.addSubview(badgeView)
    badgeView.addSubview(badgeLabel)
    badgeView.pinEdgesToSuperview(edges: [.all], padding: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    badgeLabel.pinEdgesToSuperview()
    badgeWidthConstraint = badgeViewContainer.addFixedWidthConstraint(22)
    badgeHeightConstraint = badgeViewContainer.addFixedHeightConstraint(badgeHeight)
    topConstraint = badgeViewContainer.pinTopToSuperview(topOffset)
    rightConstraint = badgeViewContainer.pinLeftToViewsRight(self.button)
    leftConstraint = badgeViewContainer.pinRightToViewsLeft(self.button)
    leftConstraint.isActive = false
    hideBadge(animated: false)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  
  // MARK: - View setup
  
  enum Alignment {
    case left, right
  }
  func setAlignment(_ alignment: Alignment) {
    switch alignment {
    case .left:
      leftConstraint.isActive = true
      rightConstraint.isActive = false
    case .right:
      leftConstraint.isActive = false
      rightConstraint.isActive = true
    }
  }
  
  
  // MARK: - Mask
  
  private func updateMask(isShowingBadge: Bool) {
    guard isShowingBadge, masksImageViewBorder  else {
      self.button.imageView?.layer.mask = nil
      return
    }
    let path = UIBezierPath(roundedRect: self.bounds,
                            cornerRadius: 0)
    let circlePath = UIBezierPath(roundedRect: CGRect(x: self.button.bounds.width - badgeWidthConstraint.constant - rightOffset,
                                                      y: topOffset,
                                                      width: badgeWidthConstraint.constant,
                                                      height: badgeHeightConstraint.constant),
                                  cornerRadius: badgeHeightConstraint.constant/2)
    path.append(circlePath)
    path.usesEvenOddFillRule = true
    
    let fillLayer = CAShapeLayer()
    fillLayer.path = path.cgPath
    fillLayer.fillRule = .evenOdd
    self.button.imageView?.layer.mask = fillLayer
  }
  
  
  // Show/hide badge
  
  func showBadge(animated: Bool = true) {
    self.button.bringSubviewToFront(badgeViewContainer)
    badgeViewContainer.alpha = 1
    if animated {
      UIView.animate(
        withDuration: 0.25,
        delay: 0,
        options: [.curveEaseIn],
        animations: {
          self.updateMask(isShowingBadge: true)
          self.badgeView.alpha = 1
          self.badgeView.transform = .identity
      }, completion: nil)
    } else {
      self.updateMask(isShowingBadge: true)
      self.badgeView.alpha = 1
      self.badgeView.transform = .identity
    }
  }
  
  func hideBadge(animated: Bool = true) {
    if animated {
      UIView.animate(
        withDuration: 0.25,
        delay: 0,
        options: [.curveEaseOut],
        animations: {
          self.updateMask(isShowingBadge: false)
          self.badgeView.alpha = 0
          self.badgeViewContainer.alpha = 0
          self.badgeView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
      }, completion: nil)
    } else {
      self.updateMask(isShowingBadge: false)
      self.badgeView.alpha = 0
      self.badgeViewContainer.alpha = 0
      self.badgeView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
  }
}
