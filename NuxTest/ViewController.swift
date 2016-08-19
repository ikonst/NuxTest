//
//  ViewController.swift
//  NuxTest
//
//  Created by Ilya Konstantinov on 6/24/16.
//  Copyright © 2016 Ilya Konstantinov. All rights reserved.
//

import UIKit

@IBDesignable
class DimView: UIView {

    func commonInit() {
        self.layer.fillRule = kCAFillRuleEvenOdd
        self.layer.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor

        self.addObserver(self, forKeyPath: "layer.position", options: [.New], context: nil)
        self.addObserver(self, forKeyPath: "layer.bounds", options: [.New], context: nil)
    }

    override func awakeFromNib() {
        self.commonInit()
    }

    override func prepareForInterfaceBuilder() {
        self.commonInit()
    }

    deinit {
        self.removeObserver(self, forKeyPath: "layer.position")
        self.removeObserver(self, forKeyPath: "layer.bounds")
    }
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }

    private var observedViews = [UIView]()

    private func observe(view view: UIView) {
        view.addObserver(self, forKeyPath: "layer.position", options: [.New], context: nil)
        view.addObserver(self, forKeyPath: "layer.bounds", options: [.New], context: nil)
    }

    private func removeObserver(from view: UIView) {
        view.removeObserver(self, forKeyPath: "layer.position")
        view.removeObserver(self, forKeyPath: "layer.bounds")
    }

    @IBOutlet var highlightViews: [UIView] {
        get {
            return self.observedViews
        }
        set {
            for oldView in self.observedViews {
                self.removeObserver(from: oldView)
            }
            for newView in newValue {
                self.observe(view: newView)
            }
            self.observedViews = newValue
            self.updatePath()
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.updatePath()
    }

    override var bounds: CGRect {
        didSet {
            self.updatePath()
        }
    }

    func updatePath() {
        let path = UIBezierPath()
        for highlightView in self.observedViews {
            let origin = self.frame.origin
            let highlightFrame = highlightView.convertRect(highlightView.bounds, toView: self)
                .offsetBy(dx: origin.x, dy: origin.y)
            path.appendPath(UIBezierPath(roundedRect: highlightFrame, cornerRadius: 10))
        }
        path.appendPath(UIBezierPath(rect: self.bounds))
        self.layer.path = path.CGPath
    }

}

class ViewController: UIViewController {

    @IBOutlet weak var maskView: UIView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    @IBOutlet weak var dimView: DimView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dimView.hidden = false
    }

    override func viewDidAppear(animated: Bool) {
        self.widthConstraint.constant += 50
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
