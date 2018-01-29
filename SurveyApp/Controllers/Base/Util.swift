//
//  Util.swift
//
//
//  Created by MacBook 1 on 29/09/2017.
//  Copyright © 2017 Lacuna Labs Sdn Bhd. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

var tabIndex = Int()

extension UILabel{
    var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of: "Regular") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }

    var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of: "Bold") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }

}

extension String {
    var localized:String {
        return NSLocalizedString(self, comment:"")
    }

    var setting:String {
        return Bundle.main.object(forInfoDictionaryKey: self) as! String!
    }

    var url: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

extension UIColor {
    convenience init(hexString:String) {
        let hexString:String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 256.0
        let green = CGFloat(g) / 256.0
        let blue  = CGFloat(b) / 256.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 256.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 256.0,
            blue: CGFloat(value & 0x0000FF) / 256.0,
            alpha: alpha
        )
    }

    class func fromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat((rgbValue & 0xFF) >> 0)/256.0

        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

    var hex: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*256.0)<<16 | (Int)(g*256.0)<<8 | (Int)(b*256.0)<<0
        return String(format:"%06x", rgb)
        
    }

    var hsba:(h: CGFloat, s: CGFloat,b: CGFloat,a: CGFloat) {
        var hsba:(h: CGFloat, s: CGFloat,b: CGFloat,a: CGFloat) = (0,0,0,0)
        self.getHue(&(hsba.h), saturation: &(hsba.s), brightness: &(hsba.b), alpha: &(hsba.a))
        return hsba
    }

    func colorWithBrightnessFactor(_ factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
}

func addGradientColor(_ view: UIView, color: String) -> CAGradientLayer{

    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.name = color

    if color == ""{
        gradientLayer.colors = [UIColor(colorWithHexValue: 0x55DECC, alpha: 0).cgColor,  UIColor(colorWithHexValue: 0x38BEE2, alpha: 0.4).cgColor]
    }else if color == "white"{
        gradientLayer.colors = [ UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor,  UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.4).cgColor]
    }else if color == "red"{
        gradientLayer.colors = [ UIColor(colorWithHexValue: 0xEB4A5F, alpha: 1).cgColor,  UIColor(colorWithHexValue: 0xEB977C, alpha: 1).cgColor]
    }else{
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
    }

    gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)

    if color == "" || color == "white"{
        animateLayer(gradientLayer, color: color)
    }

    return gradientLayer

}

func addShadow(_ view: UIView){
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowOpacity = 0.1
    view.layer.masksToBounds = false
}

func animateLayer(_ gradientLayer: CAGradientLayer, color: String){

    let fromColors = gradientLayer.colors
    var toColors = [AnyObject]()

    if color == ""{
        toColors = [UIColor.fromHex(0x38BEE2).cgColor,  UIColor.fromHex(0x55DECC).cgColor]
    }else if color == "white"{
        toColors = [ UIColor.white.cgColor,  UIColor.white.cgColor]
    }

    gradientLayer.colors = toColors
    gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
    let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")

    animation.fromValue = fromColors
    animation.toValue = toColors
    animation.duration = 1
    animation.isRemovedOnCompletion = true
    animation.fillMode = kCAFillModeForwards
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    //animation.delegate = self

    gradientLayer.add(animation, forKey:"animateGradient")
}
