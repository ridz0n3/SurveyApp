//
//  Survey04ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 05/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import Fusuma
import AVFoundation
import AVKit
import Gallery
import Alamofire
import SDWebImage

class Survey04ViewController: BaseViewController, GalleryControllerDelegate, FusumaDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var allUploadView: UIView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var photoTableView: UITableView!
    
    @IBOutlet weak var uploadView2: UIView!
    @IBOutlet weak var uploadBtn: UIView!
    
    var isAddPhoto = Bool()
    var firstView = Bool()
    var uploadedImgArr = [UIImage]()
    var uploadedImgUrlArr = [URL]()
    var doneRefresh = Bool()
    var changeIndex = Int()
    var gallery: GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        
        navigationBarSetup("second", title: "Survey Photo")
        processNumber(4)
        addShadow(uploadView)
        addShadow(nextBtn)
        addShadow(uploadBtn)
        
        if uploadedImgArr.count == 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.allUploadView.alpha = 1
                self.photoTableView.alpha = 0
                self.uploadView2.alpha = 0
            })
        }else{
            UIView.animate(withDuration:0.5, animations: {
                self.allUploadView.alpha = 0
                self.photoTableView.alpha = 1
                self.uploadView2.alpha = 1
            })
        }
        
        if status == "edit"{
            
            if survey.status == "server"{
                
                if isConnectedToNetwork(){
                    Hud.show(view)
                    Api.getPhoto(survey.id).continueOnSuccessWith(block: { (task) -> Any? in
                        Hud.hide()
                        if task.succeed{
                            for img in self.survey.photo{
                                self.uploadedImgUrlArr.append(URL(string: img.imgUrl)!)
                            }
                            self.photoTableView.reloadData()
                            
                            if self.uploadedImgUrlArr.count == 0{
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.allUploadView.alpha = 1
                                    self.photoTableView.alpha = 0
                                    self.uploadView2.alpha = 0
                                })
                            }else{
                                
                                UIView.animate(withDuration:0.5, animations: {
                                    self.allUploadView.alpha = 0
                                    self.photoTableView.alpha = 1
                                    self.uploadView2.alpha = 1
                                })
                            }
                        }else{
                            task.showError()
                        }
                        
                        return nil
                    })
                }

            }else{
                
                var isEmpty = Bool()
                for img in survey.photo{
                    
                    if img.imgData.count == 0{
                        uploadedImgUrlArr.append(URL(string: img.imgUrl)!)
                        isEmpty = true
                    }else{
                        uploadedImgArr.append(UIImage(data: img.imgData)!)
                    }
                    
                }
                
                if isEmpty{
                    if uploadedImgUrlArr.count == 0{
                        UIView.animate(withDuration: 0.5, animations: {
                            self.allUploadView.alpha = 1
                            self.photoTableView.alpha = 0
                            self.uploadView2.alpha = 0
                        })
                    }else{
                        UIView.animate(withDuration:0.5, animations: {
                            self.allUploadView.alpha = 0
                            self.photoTableView.alpha = 1
                            self.uploadView2.alpha = 1
                        })
                    }
                }else{
                    if uploadedImgArr.count == 0{
                        UIView.animate(withDuration: 0.5, animations: {
                            self.allUploadView.alpha = 1
                            self.photoTableView.alpha = 0
                            self.uploadView2.alpha = 0
                        })
                    }else{
                        UIView.animate(withDuration:0.5, animations: {
                            self.allUploadView.alpha = 0
                            self.photoTableView.alpha = 1
                            self.uploadView2.alpha = 1
                        })
                    }
                }
            }
            
        }
        
        registerNibs()
        uploadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadPhoto)))
        
        uploadView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadPhoto)))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func registerNibs(){
        
        let viewNib = UINib(nibName: "PhotoTableViewCell", bundle: nil)
        photoTableView.register(viewNib, forCellReuseIdentifier: "Cell")
        
    }
    
    @objc func uploadPhoto(){
        
        gallery = GalleryController()
        gallery.delegate = self
        
        present(gallery, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if status == "edit"{
            if survey.status == "server" && !firstView && !isAddPhoto{
                return uploadedImgUrlArr.count
            }
        }
        return uploadedImgArr.count == 0 ? uploadedImgUrlArr.count : uploadedImgArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = photoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoTableViewCell
        if status == "edit"{
            
            if survey.status == "server" && !firstView && !isAddPhoto {
                let urlString = uploadedImgUrlArr[indexPath.row]
                cell.uploadedImgView.sd_setIndicatorStyle(.gray)
                cell.uploadedImgView.sd_setShowActivityIndicatorView(true)
                cell.uploadedImgView.sd_setImage(with: urlString) { (loadedImage, error, cacheType, url) in
                    cell.uploadedImgView.sd_removeActivityIndicator()
                    if error != nil {
                        print("Error code: \(error!.localizedDescription)")
                    } else {
                        cell.uploadedImgView.image = loadedImage
                        self.uploadedImgArr.append(loadedImage!)
                        
                        if self.uploadedImgUrlArr.count == self.uploadedImgArr.count{
                            self.firstView = true
                        }
                    }
                }
            }else{
                
                if uploadedImgArr.count == 0{
                    let urlString = uploadedImgUrlArr[indexPath.row]
                    cell.uploadedImgView.sd_setIndicatorStyle(.gray)
                    cell.uploadedImgView.sd_setShowActivityIndicatorView(true)
                    cell.uploadedImgView.sd_setImage(with: urlString) { (loadedImage, error, cacheType, url) in
                        cell.uploadedImgView.sd_removeActivityIndicator()
                        if error != nil {
                            print("Error code: \(error!.localizedDescription)")
                        } else {
                            cell.uploadedImgView.image = loadedImage
                            self.uploadedImgArr.append(loadedImage!)
                            
                            if self.uploadedImgUrlArr.count == self.uploadedImgArr.count{
                                self.firstView = true
                            }
                        }
                    }
                }else{
                    cell.uploadedImgView.image = uploadedImgArr[indexPath.row]
                }
                
            }
        }else{
            cell.uploadedImgView.image = uploadedImgArr[indexPath.row]
        }
        
        cell.changeBtn.tag = indexPath.row
        cell.removeBtn.tag = indexPath.row
        
        cell.changeBtn.addTarget(self, action: #selector(changeImage(_:)), for: UIControlEvents.touchUpInside)
        cell.removeBtn.addTarget(self, action: #selector(removeImage(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        uploadedImgArr.remove(at: changeIndex)
        uploadedImgArr.insert(image, at: changeIndex)
        
        photoTableView.reloadData()
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {}
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {}
    
    func fusumaCameraRollUnauthorized() {}
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            
            for image in resolvedImages {
                self?.uploadedImgArr.append(image!)
            }
            
            self?.isAddPhoto = true
            
            UIView.animate(withDuration: 0.5, animations: {
                self?.allUploadView.alpha = 0
                self?.photoTableView.alpha = 1
                self?.uploadView2.alpha = 1
            })
            
            self?.photoTableView.reloadData()
            
        })
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {}
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {}
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    @objc func removeImage(_ sender: UIButton){
        let tag = sender.tag
        var deadlineTime = DispatchTime.now()
        
        if !doneRefresh{
            
            if status == "edit"{
                
                if survey.status == "server" && !firstView {
                    if uploadedImgUrlArr.count > 0{
                        
                        doneRefresh = true
                        deadlineTime = deadlineTime + .seconds(1)
                        self.photoTableView.beginUpdates()
                        uploadedImgArr.remove(at: tag)
                        uploadedImgUrlArr.remove(at: tag)
                        let indexPath = IndexPath(row: tag, section: 0)
                        self.photoTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        self.photoTableView.endUpdates()
                        
                        if uploadedImgUrlArr.count == 0{
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                self.allUploadView.alpha = 1
                                self.photoTableView.alpha = 0
                                self.uploadView2.alpha = 0
                            })
                            
                        }
                    }else{
                        if uploadedImgUrlArr.count == 0{
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                self.allUploadView.alpha = 1
                                self.photoTableView.alpha = 0
                                self.uploadView2.alpha = 0
                            })
                            
                        }
                    }
                }else{
                    if uploadedImgArr.count > 0{
                        
                        doneRefresh = true
                        deadlineTime = deadlineTime + .seconds(1)
                        self.photoTableView.beginUpdates()
                        uploadedImgArr.remove(at: tag)
                        uploadedImgUrlArr.remove(at: tag)
                        let indexPath = IndexPath(row: tag, section: 0)
                        self.photoTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        self.photoTableView.endUpdates()
                        
                        if uploadedImgArr.count == 0{
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                self.allUploadView.alpha = 1
                                self.photoTableView.alpha = 0
                                self.uploadView2.alpha = 0
                            })
                            
                        }
                    }
                }
            }else{
                if uploadedImgArr.count > 0{
                    
                    doneRefresh = true
                    deadlineTime = deadlineTime + .seconds(1)
                    self.photoTableView.beginUpdates()
                    uploadedImgArr.remove(at: tag)
                    uploadedImgUrlArr.remove(at: tag)
                    let indexPath = IndexPath(row: tag, section: 0)
                    self.photoTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    self.photoTableView.endUpdates()
                    
                    if uploadedImgArr.count == 0{
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.allUploadView.alpha = 1
                            self.photoTableView.alpha = 0
                            self.uploadView2.alpha = 0
                        })
                        
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.photoTableView.reloadData()
                self.doneRefresh = false
            }
            
        }
    }
    
    @objc func changeImage(_ sender: UIButton){
        changeIndex = sender.tag
        
        let fusuma = FusumaViewController()
        
        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = false
        fusuma.availableModes = [.library, .camera]
        
        fusumaSavesImage = false
        fusumaCameraRollTitle = "Gallery"
        fusumaCameraTitle = "Camera"
        
        self.present(fusuma, animated: true, completion: nil)
        
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if status == "edit"{
            
            try! realm.write {
                
                realm.delete(User.current.photo)
                
                for img in uploadedImgArr{
                    let photo = Photo()
                    let tempImg = self.resizeImage(image: img, newWidth: 200)
                    let imageData:Data = UIImagePNGRepresentation( tempImg)!
                    photo.imgData = imageData
                    
                    User.current.photo.append(photo)
                }
                
                User.current.updateImg = true
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                survey05VC.status = status
                survey05VC.survey = survey
                survey05VC.surveyIndex = surveyIndex
                
                self.navigationController?.heroNavigationAnimationType = .fade
                self.navigationController?.pushViewController(survey05VC, animated: true)
            }
            
        }else{
            
            if uploadedImgArr.count != 0{
                try! realm.write {
                    
                    realm.delete(User.current.photo)
                    
                    for img in uploadedImgArr{
                        let photo = Photo()
                        let tempImg = self.resizeImage(image: img, newWidth: 200)
                        let imageData:Data = UIImagePNGRepresentation( tempImg)!
                        photo.imgData = imageData
                        
                        User.current.photo.append(photo)
                    }
                    
                    User.current.updateImg = true
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                    survey05VC.status = status
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey05VC, animated: true)
                }
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                survey05VC.status = status
                self.navigationController?.heroNavigationAnimationType = .fade
                self.navigationController?.pushViewController(survey05VC, animated: true)
            }
        }
    }
}
