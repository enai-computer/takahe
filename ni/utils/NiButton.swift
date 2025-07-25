//
//  NiButton.swift
//  ni
//
//  Created by Patrick Lukas on 1/7/24.
//
import Cocoa
import QuartzCore

internal extension CALayer {
	func animate(color: CGColor, keyPath: String, duration: Double) {
		if value(forKey: keyPath) as! CGColor? != color {
			let animation = CABasicAnimation(keyPath: keyPath)
			animation.toValue = color
			animation.fromValue = value(forKey: keyPath)
			animation.duration = duration
			animation.isRemovedOnCompletion = false
			animation.fillMode = CAMediaTimingFillMode.forwards
			add(animation, forKey: keyPath)
			setValue(color, forKey: keyPath)
		}
	}
}

//unused for now
internal extension NSColor {
	func tintedColor() -> NSColor {
		var h = CGFloat(), s = CGFloat(), b = CGFloat(), a = CGFloat()
		let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB)
		rgbColor?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return NSColor(hue: h, saturation: s, brightness: b == 0 ? 0.2 : b * 0.8, alpha: a)
	}
}

open class NiButton: NSButton, CALayerDelegate {
	
	internal var containerLayer = CALayer()
	internal var iconLayer = CAShapeLayer()
	internal var alternateIconLayer = CAShapeLayer()
	internal var titleLayer = CATextLayer()
	internal var mouseDown = Bool()
	@IBInspectable public var momentary: Bool = true {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var onAnimationDuration: Double = 0
	@IBInspectable public var offAnimationDuration: Double = 0.1
	@IBInspectable public var glowRadius: CGFloat = 0 {
		didSet {
			containerLayer.shadowRadius = glowRadius
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var glowOpacity: Float = 0 {
		didSet {
			containerLayer.shadowOpacity = glowOpacity
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var cornerRadius: CGFloat = 4 {
		didSet {
			layer?.cornerRadius = cornerRadius
		}
	}
	@IBInspectable public var borderWidth: CGFloat = 1 {
		didSet {
			layer?.borderWidth = borderWidth
		}
	}
	@IBInspectable public var borderColor: NSColor = NSColor.sand115 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var hoverBorderColor: NSColor = NSColor.sand1 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var buttonColor: NSColor = NSColor.sand1 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var hoverButtonColor: NSColor = NSColor.sand1 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var iconColor: NSColor = NSColor.sand11 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var hoverIconColor: NSColor = NSColor.birkin {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var textColor: NSColor = NSColor.sand11 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	@IBInspectable public var hoverTextColor: NSColor = NSColor.sand12 {
		didSet {
			animateColor(mouseHovers: false)
		}
	}
	
	override open var title: String {
		didSet {
			setupTitle()
		}
	}
	override open var font: NSFont? {
		didSet {
			setupTitle()
		}
	}
	override open var frame: NSRect {
		didSet {
			positionTitleAndImage()
		}
	}
	override open var image: NSImage? {
		didSet {
			setupImage()
		}
	}
	override open var alternateImage: NSImage? {
		didSet {
			setupImage()
		}
	}
	override open var isEnabled: Bool {
		didSet {
			alphaValue = isEnabled ? 1 : 0.5
		}
	}
	
	
	// MARK: Setup & Initialization
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	override init(frame: NSRect) {
		super.init(frame: frame)
		setup()
	}
	
	internal func setup() {
		wantsLayer = true
		layer?.masksToBounds = false
		containerLayer.masksToBounds = false
		layer?.borderWidth = 1
		layer?.delegate = self
		titleLayer.delegate = self
		if let scale = window?.backingScaleFactor {
			titleLayer.contentsScale = scale
		}
		iconLayer.delegate = self
		alternateIconLayer.delegate = self
		iconLayer.masksToBounds = true
		alternateIconLayer.masksToBounds = true
		containerLayer.shadowOffset = NSSize.zero
		containerLayer.shadowColor = NSColor.clear.cgColor
		containerLayer.frame = NSMakeRect(0, 0, bounds.width, bounds.height)
		containerLayer.addSublayer(iconLayer)
		containerLayer.addSublayer(alternateIconLayer)
		containerLayer.addSublayer(titleLayer)
		layer?.addSublayer(containerLayer)
		setupTitle()
		setupImage()
	}
	
	internal func setupTitle() {
		guard let font = font else {
			return
		}
		titleLayer.string = title
		titleLayer.font = font
		titleLayer.fontSize = font.pointSize
		positionTitleAndImage()
	}
	
	func positionTitleAndImage() {
		let attributes = [NSAttributedString.Key.font: font as Any]
		let titleSize = title.size(withAttributes: attributes)
		var titleRect = NSMakeRect(0, 0, titleSize.width, titleSize.height)
		var imageRect = iconLayer.frame
		let hSpacing = round((bounds.width-(imageRect.width+titleSize.width))/3)
		let vSpacing = round((bounds.height-(imageRect.height+titleSize.height))/3)
		
		switch imagePosition {
		case .imageAbove:
			titleRect.origin.y = bounds.height-titleRect.height - 2
			titleRect.origin.x = round((bounds.width - titleSize.width)/2)
			imageRect.origin.y = vSpacing
			imageRect.origin.x = round((bounds.width - imageRect.width)/2)
			break
		case .imageBelow:
			titleRect.origin.y = 2
			titleRect.origin.x = round((bounds.width - titleSize.width)/2)
			imageRect.origin.y = bounds.height-vSpacing-imageRect.height
			imageRect.origin.x = round((bounds.width - imageRect.width)/2)
			break
		case .imageLeft:
			titleRect.origin.y = round((bounds.height - titleSize.height)/2)
			titleRect.origin.x = bounds.width - titleSize.width - 6
			imageRect.origin.y = round((bounds.height - imageRect.height)/2)
			imageRect.origin.x = hSpacing
			break
		case .imageRight:
			titleRect.origin.y = round((bounds.height - titleSize.height)/2)
			titleRect.origin.x = 2
			imageRect.origin.y = round((bounds.height - imageRect.height)/2)
			imageRect.origin.x = bounds.width - imageRect.width - hSpacing
			break
		default:
			titleRect.origin.y = round((bounds.height - titleSize.height)/2)
			titleRect.origin.x = round((bounds.width - titleSize.width)/2)
		}
		iconLayer.frame = imageRect
		alternateIconLayer.frame = imageRect
		titleLayer.frame = titleRect
	}
	
	internal func setupImage() {
		guard let image = image else {
			return
		}
		let maskLayer = CALayer()
		let imageSize = image.size
		var imageRect:CGRect = NSMakeRect(0, 0, imageSize.width, imageSize.height)
		let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
		maskLayer.contents = imageRef
		iconLayer.frame = imageRect
		maskLayer.frame = imageRect
		iconLayer.mask = maskLayer
		//maskLayer.backgroundColor = NSColor.green.withAlphaComponent(0.5).cgColor
		
		if let alternateImage = alternateImage {
			let altMaskLayer = CALayer()
			//altMaskLayer.backgroundColor = NSColor.green.withAlphaComponent(0.5).cgColor
			let altImageSize = alternateImage.size
			var altImageRect:CGRect = NSMakeRect(0, 0, altImageSize.width, altImageSize.height)
			let altImageRef = alternateImage.cgImage(forProposedRect: &altImageRect, context: nil, hints: nil)
			altMaskLayer.contents = altImageRef
			alternateIconLayer.frame = altImageRect
			altMaskLayer.frame = altImageRect
			alternateIconLayer.mask = altMaskLayer
			alternateIconLayer.frame = altImageRect
		}
		positionTitleAndImage()
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil)
		addTrackingArea(trackingArea)
	}
	
	// MARK: Animations
	
	internal func removeAnimations() {
		layer?.removeAllAnimations()
		if layer?.sublayers != nil {
			for subLayer in (layer?.sublayers)! {
				subLayer.removeAllAnimations()
			}
		}
	}
	
	public func animateColor(mouseHovers: Bool) {
		removeAnimations()
		let duration = mouseHovers ? onAnimationDuration : offAnimationDuration
		let bgColor = mouseHovers ? hoverButtonColor : buttonColor
		let titleColor = mouseHovers ? hoverTextColor : textColor
		let imageColor = mouseHovers ? hoverIconColor : iconColor
		let borderColor = mouseHovers ? hoverBorderColor : self.borderColor
		layer?.animate(color: bgColor.cgColor, keyPath: "backgroundColor", duration: duration)
		layer?.animate(color: borderColor.cgColor, keyPath: "borderColor", duration: duration)

		titleLayer.foregroundColor = titleColor.cgColor
		
		if alternateImage == nil {
			iconLayer.animate(color: imageColor.cgColor, keyPath: "backgroundColor", duration: duration)
		} else {
			iconLayer.animate(color: mouseHovers ? NSColor.clear.cgColor : iconColor.cgColor, keyPath: "backgroundColor", duration: duration)
			alternateIconLayer.animate(color: mouseHovers ? hoverIconColor.cgColor : NSColor.clear.cgColor, keyPath: "backgroundColor", duration: duration)
		}
		
		// Shadows
		
		if glowRadius > 0, glowOpacity > 0 {
			containerLayer.animate(color: mouseHovers ? hoverIconColor.cgColor : NSColor.clear.cgColor, keyPath: "shadowColor", duration: duration)
		}
	}
	
	// MARK: Interaction
	
	public func setOn(_ isOn: Bool) {
		let nextState = isOn ? NSControl.StateValue.on : NSControl.StateValue.off
		if nextState != state {
			state = nextState
		}
	}
	
	override open func hitTest(_ point: NSPoint) -> NSView? {
		return isEnabled ? super.hitTest(point) : nil
	}
	
	override open func mouseDown(with event: NSEvent) {
		if isEnabled {
			mouseDown = true
			setOn(state == .on ? false : true)
		}
	}
	
	override open func mouseEntered(with event: NSEvent) {
		animateColor(mouseHovers: true)
		if mouseDown{
			setOn(state == .on ? false : true)
		}
	}
	
	override open func mouseExited(with event: NSEvent) {
		animateColor(mouseHovers: false)
		if mouseDown {
			setOn(state == .on ? false : true)
			mouseDown = false
		}
	}
	
	override open func mouseUp(with event: NSEvent) {
		if mouseDown {
			mouseDown = false
			if momentary {
				setOn(state == .on ? false : true)
			}
			_ = target?.perform(action, with: self)
		}
	}
	
	// MARK: Drawing
	
	override open func viewDidChangeBackingProperties() {
		super.viewDidChangeBackingProperties()
		if let scale = window?.backingScaleFactor {
			titleLayer.contentsScale = scale
			layer?.contentsScale = scale
			iconLayer.contentsScale = scale
		}
	}
	
	open func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
		return true
	}
	
	override open func draw(_ dirtyRect: NSRect) {
		
	}
	
	override open func layout() {
		super.layout()
		positionTitleAndImage()
	}
	
	override open func updateLayer() {
		super.updateLayer()
	}
	
	
}
