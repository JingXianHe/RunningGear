//
//  ModelAnimator.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/20/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit

class ModelAnimator: NSObject {
    let duration = 1.8
    var presenting = true//是present还是dismiss
    var originFrame = CGRect.zero

}
extension ModelAnimator:UIViewControllerAnimatedTransitioning{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval
    {
        return duration
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        //虽然动画是从按钮图标长大成presentedView的图画，但与按钮的图标并没有半毛钱的关系，这里
        //是将toView缩小成按钮图标的大小然后动画长大成toview的
        let herbView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width :finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(
                x: CGRectGetMidX(initialFrame),
                y: CGRectGetMidY(initialFrame))
            herbView.clipsToBounds = true
             herbView.layer.cornerRadius = 40/xScaleFactor
            let finalRadius:CGFloat = presenting ? 0.0 : 40/xScaleFactor
            let morphAnimation = CABasicAnimation(keyPath: "Alpha")
            morphAnimation.duration = 0.9
            morphAnimation.toValue = finalRadius
            morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            morphAnimation.delegate = self
            morphAnimation.setValue(herbView, forKey: "target")
            morphAnimation.setValue(finalRadius, forKey: "setValue")
            herbView.layer.addAnimation(morphAnimation, forKey: nil)
            containerView.addSubview(toView)
            containerView.bringSubviewToFront(herbView)
            
            UIView.animateWithDuration(duration, delay:0.4, usingSpringWithDamping: 0.4, initialSpringVelocity:0.0, options: [], animations: {
                herbView.transform = self.presenting ?
                    CGAffineTransformIdentity : scaleTransform
                herbView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
                
                }, completion:{_ in
                    transitionContext.completeTransition(true)
            })
        }else{
            let morphAnimation = CABasicAnimation(keyPath: "cornerRadius")
            let finalRadius:CGFloat = presenting ? 0.0 : 40/xScaleFactor
            morphAnimation.duration = 1.8
            morphAnimation.toValue = finalRadius
            morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            morphAnimation.delegate = self
            morphAnimation.setValue(herbView, forKey: "target")
            morphAnimation.setValue(finalRadius, forKey: "setValue")
            herbView.layer.addAnimation(morphAnimation, forKey: nil)
            containerView.addSubview(toView)
            containerView.bringSubviewToFront(herbView)
            
            UIView.animateWithDuration(duration/2, animations: { () -> Void in
                herbView.transform = self.presenting ?
                    CGAffineTransformIdentity : scaleTransform
                herbView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
                }, completion: { (Bool) -> Void in
                    transitionContext.completeTransition(true)
            })

        }

        
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let herbView = anim.valueForKey("target") as! UIView
        let finalValue = anim.valueForKey("setValue") as! CGFloat
        herbView.layer.cornerRadius = finalValue
        
    }


}