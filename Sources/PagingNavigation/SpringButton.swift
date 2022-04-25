// Copyright Kyle Zaragoza. All Rights Reserved.

import UIKit

@objc(APFSpringButton)
@IBDesignable public class SpringButton: UIView {
  
  public var didTouchUpInside: ((_ sender: SpringButton) -> Void)?
  /// Adjusts the bounds of the button's hit rect, negative values will create a larger hit rect.
  public var hitTestEdgeInsets = UIEdgeInsets.zero
  private var textAttributes = [NSAttributedString.Key: Any]()
  /// Specify custom layer corner radius to override default rounding behavior.
  @IBInspectable
  public var customCornerRadius: CGFloat = -1 {
    didSet {
      button.layer.cornerRadius = customCornerRadius
    }
  }
  
  // If intrinsicContentSize is used, minimumWidth will be respected.
  public var minimumWidth: CGFloat? = nil {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }
  
  /// UIButton used for layout.
  @objc
  public let button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isUserInteractionEnabled = false
    return button
  }()
  
  /// Convenience setter for settings all edges of hitTestEdgeInsets at once.
  @IBInspectable
  @objc
  public var hitTestPadding: CGFloat = 0 {
    didSet {
      hitTestEdgeInsets = UIEdgeInsets(top: hitTestPadding,
                                       left: hitTestPadding,
                                       bottom: hitTestPadding,
                                       right: hitTestPadding)
    }
  }
  
  @IBInspectable
  public var imageToTextPadding: CGFloat {
    set {
      button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -newValue, bottom: 0, right: newValue)
    }
    get {
      return button.imageEdgeInsets.right
    }
  }
  
  @IBInspectable
  public var isImageTextPositionInverted: Bool = false {
    didSet {
      if isImageTextPositionInverted {
        button.transform = CGAffineTransform(scaleX: -1, y: 1)
        button.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
      } else {
        button.transform = .identity
        button.imageView?.transform = .identity
        button.titleLabel?.transform = .identity
      }
    }
  }
  
  @IBInspectable
  public var leftAndRightPadding: CGFloat = 0 {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }
  
  @IBInspectable
  @objc
  public var buttonBackgroundColor: UIColor? {
    set {
      button.backgroundColor = newValue
    }
    get {
      return button.backgroundColor
    }
  }
  
  @IBInspectable
  @objc
  public var textColor: UIColor {
    set {
      textAttributes[.foregroundColor] = newValue
      resetTextForUpdatedAttributes()
    }
    get {
      return textAttributes[.foregroundColor] as? UIColor
        ?? UIColor.black
    }
  }
  
  @IBInspectable
  @objc
  public var text: String? = "" {
    didSet {
      resetTextForUpdatedAttributes()
    }
  }
  
  @IBInspectable
  public var imageName: String? {
    didSet {
      if let imageName = imageName {
        let image = UIImage(named: imageName)
        button.setImage(image, for: .normal)
      }
      else {
        button.setImage(nil, for: .normal)
      }
    }
  }
  
  @IBInspectable
  public var disabledAlpha: CGFloat = 0.5
  
  public override var isUserInteractionEnabled: Bool {
    didSet {
      self.alpha = isUserInteractionEnabled
        ? 1
        : disabledAlpha
    }
  }
  
  @objc
  public var font: UIFont {
    set {
      textAttributes[.font] = newValue
      resetTextForUpdatedAttributes()
    }
    get {
      return textAttributes[.font] as? UIFont
        ?? UIFont.systemFont(ofSize: 14)
    }
  }
  
  public var attributedTitle: NSAttributedString? {
    if let labelText = self.text {
      let string = NSAttributedString(string: labelText, attributes: textAttributes)
      return string
    } else {
      return nil
    }
  }
  
  private func resetTextForUpdatedAttributes() {
    if let attributedTitle = self.attributedTitle {
      button.setAttributedTitle(attributedTitle, for: .normal)
    }
  }
  
  
  // MARK: - Init
  
  private func commonInit() {
    self.addSubview(button)
    button.pinEdgesToSuperview()
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
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    // Default to half-height if customCornerRadius is -1 (default value).
    button.layer.cornerRadius = customCornerRadius == -1
      ? button.bounds.height/2
      : customCornerRadius
  }
  
  public override var intrinsicContentSize: CGSize {
    let width: CGFloat
    let buttonWidth = button.intrinsicContentSize.width + imageToTextPadding
    
    if let minimumWidth = minimumWidth {
      width = max(buttonWidth + 2 * leftAndRightPadding, minimumWidth)
    } else {
      width = buttonWidth + 2 * leftAndRightPadding
    }
    
    return CGSize(width: width,
                  height: button.intrinsicContentSize.height)
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return self.intrinsicContentSize
  }
  
  
  // MARK: - Gesture Handling
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    animateToPressedState()
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    animatedToDefaultState()
    // Notify listener on touch up inside.
    if let touch = touches.first, pointIsInsideModifiedHitRegion(touch.location(in: self)) {
      didTouchUpInside?(self)
    }
  }
  
  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    animatedToDefaultState()
  }
  
  
  // MARK: - Animation
  
  private func animateToPressedState() {
    UIView.animate(
      withDuration: 1,
      delay: 0,
      usingSpringWithDamping: 0.55,
      initialSpringVelocity: 12,
      options: [.beginFromCurrentState, .allowUserInteraction],
      animations: {
        let scale: CGFloat = 0.9
        self.button.transform = self.isImageTextPositionInverted
          ? CGAffineTransform(scaleX: -scale, y: scale)
          : CGAffineTransform(scaleX: scale, y: scale)
    },
      completion: { finished in})
  }
  
  private func animatedToDefaultState() {
    UIView.animate(
      withDuration: 1,
      delay: 0,
      usingSpringWithDamping: 0.55,
      initialSpringVelocity: 12,
      options: [.beginFromCurrentState, .allowUserInteraction],
      animations: {
        self.button.transform = self.isImageTextPositionInverted
          ? CGAffineTransform(scaleX: -1, y: 1)
          : .identity
    },
      completion: { finished in})
  }
  
  
  // MARK: - Hit testing
  
  private func pointIsInsideModifiedHitRegion(_ point: CGPoint) -> Bool {
    let relativeFrame = self.bounds
    let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
    return hitFrame.contains(point)
  }
  
  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if hitTestEdgeInsets == UIEdgeInsets.zero || self.isHidden {
      return super.point(inside: point, with: event)
    }
    return pointIsInsideModifiedHitRegion(point)
  }
}
