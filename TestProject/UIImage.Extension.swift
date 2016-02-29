//
//  UIImage+Extension.swift
//  TestProject
//
//  Created by Anson on 2015-12-12.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit
import Darwin
let Corner_Radius = 10 / Scale_Factor
let Inset_Width = 5 / Scale_Factor
let Inset_Height = 5 / Scale_Factor
let Shadow_Width = 3 / Scale_Factor
let Shadow_Height = 3 / Scale_Factor
let Text_Height = CGFloat( 20 / Scale_Factor)
extension UIImage{
    func convertImageAsRequired(title: String) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, true, 0)
        let context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context)
        
        
        //While background
        let rectPath = UIBezierPath(rect: rect)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        rectPath.fill()
        
        
        //Get inset and corners
        CGContextSetShadowWithColor(context, CGSize(width: Shadow_Width, height: Shadow_Height), 5.0, UIColor.blackColor().CGColor)
        let insetRect = CGRectInset(rect, CGFloat(Inset_Width), CGFloat(Inset_Height))
        let bezierPath = UIBezierPath(roundedRect: insetRect, cornerRadius: CGFloat(Corner_Radius));
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, CGFloat(Inset_Height))
        bezierPath.stroke()
        bezierPath.addClip()
        
        //Draw image
        self.drawInRect(insetRect);
        CGContextSetShadowWithColor(context, CGSize(width: 0, height: 0), 0.0, UIColor.grayColor().CGColor)

        //draw text on diagnol
        let textRect = CGRectMake(insetRect.origin.x, insetRect.origin.y + insetRect.height - Text_Height/2, insetRect.width, Text_Height)
        let str = NSString(string: ("    "+title))
        CGContextTranslateCTM( context, 0.5 * rect.size.width, 0.5 * rect.size.height)
        let affineTransSub = CGAffineTransformMakeTranslation(-0.5 * rect.size.width, -0.5 * rect.size.height)
        
        let alpha = atan(insetRect.height/insetRect.width)
        CGContextRotateCTM(context, (CGFloat(alpha)));
        let affineRotate = CGAffineTransformMakeRotation(CGFloat(alpha))
        CGContextTranslateCTM(context, -0.5 * rect.size.width, -0.5 * rect.size.height );
        let affineTransAdd = CGAffineTransformMakeTranslation(0.5 * rect.size.width, 0.5 * rect.size.height)
        
        let rectTransSub = CGRectApplyAffineTransform(textRect, affineTransSub)
        let rectRotate = CGRectApplyAffineTransform(rectTransSub, affineRotate)
        let rectTransAdd = CGRectApplyAffineTransform(rectRotate, affineTransAdd)
        let rectFinal = CGRectMake(rectTransAdd.origin.x, rectTransAdd.origin.y, sqrt(pow(insetRect.width, 2)+pow(insetRect.height, 2)), Text_Height)
        
        
        var textAttributes = [String : AnyObject]()
        textAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(30.0)
        textAttributes[NSForegroundColorAttributeName] = UIColor.redColor()
        str.drawInRect(rectFinal, withAttributes: textAttributes)

        CGContextRestoreGState(context);
    
        //Get image result
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
