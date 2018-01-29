//
//  HomeViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 04/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, UITabBarControllerDelegate {

    fileprivate enum TabTitles: String, CustomStringConvertible {
        case Profile
        case Survey
        case Checklist
        
        fileprivate var description: String {
            return self.rawValue
        }
    }
    
    fileprivate var tabIcons = [
        TabTitles.Profile: "profileImg",
        TabTitles.Survey: "matchImg",
        TabTitles.Checklist: "exploreImg"
    ]
    
    fileprivate var tabIconsSelect = [
        TabTitles.Profile: "profileSelectImg",
        TabTitles.Survey: "matchSelectImg",
        TabTitles.Checklist: "exploreSelectImg"
    ]
    
    func imageWithImage(_ image: UIImage, scaledToSize:CGSize) -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(scaledToSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledToSize.width, height: scaledToSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.fromHex(0xEB4C60)], for: .selected)
        
        if User.current.rolename != "PDMLeader"{
            viewControllers?.remove(at: 2)
        }
        
        if let tabBarItems = tabBar.items {
            
            var count = 0
            var newImg = UIImage()
            for item in tabBarItems {
                
                if let title = item.title, let tab = TabTitles(rawValue: title), let glyph = tabIcons[tab], let glyphSelect = tabIconsSelect[tab]  {
                    
                    if count == 0 {
                        
                        let tempImg = UIImage(named: glyphSelect)
                        newImg = imageWithImage(tempImg!, scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
                        
                    } else {
                        let img = UIImage(named: glyph)
                        newImg = imageWithImage(img!, scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
                    }
                    
                    item.image = newImg
                    item.selectedImage = newImg
                    item.title = tab.rawValue
                    item.titlePositionAdjustment = UIOffsetMake(0, -5);
                    
                }
                count += 1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UITabbar delegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        var count = 1
        var title = String()
        var newImg = UIImage()
        for tabBarItems in tabBar.items! {
            
            if tabBarItems != item {
                let newIndex = count - 1
                
                if count == 1 {
                    title = "Profile"
                } else if count == 2 {
                    title = "Survey"
                } else if count == 3 {
                    title = "Checklist"
                }
                
                let glyph = tabIcons[TabTitles(rawValue: title)!]!
                let img = UIImage(named: glyph)
                
                newImg = imageWithImage(img!, scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
                
                tabBar.items?[newIndex].image = newImg
                tabBar.items?[newIndex].selectedImage = newImg
                tabBar.items?[newIndex].title = TabTitles(rawValue: title)!.rawValue
                tabBar.items?[newIndex].titlePositionAdjustment = UIOffsetMake(0, -5)
                
            } else {
                let newIndex = count
                
                if newIndex == 1 {
                    title = "Profile"
                } else if newIndex == 2 {
                    title = "Survey"
                } else if newIndex == 3 {
                    title = "Checklist"
                }
                
                let glyph = tabIconsSelect[TabTitles(rawValue: title)!]!
                let img = UIImage(named: glyph)
                
                newImg = imageWithImage(img!, scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
                
                item.image = newImg
                item.selectedImage = newImg
                item.title = TabTitles(rawValue: title)!.rawValue
                item.titlePositionAdjustment = UIOffsetMake(0, -5)
                
            }
            
            count += 1
        }
        
        var index = 0
        for loc in tabBar.items!{
            if loc == item{
                tabIndex = index
            }
            index += 1
        }
        
        let animation = CATransition()
        animation.type = kCATransitionFade
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.view.window?.layer.add(animation, forKey: "slideTransition")
    }

}
