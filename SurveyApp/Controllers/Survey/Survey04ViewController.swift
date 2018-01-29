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

class Survey04ViewController: BaseViewController, GalleryControllerDelegate, FusumaDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var allUploadView: UIView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var photoTableView: UITableView!
    
    @IBOutlet weak var uploadView2: UIView!
    @IBOutlet weak var uploadBtn: UIView!
    
    var uploadedImgArr = [UIImage]()
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
        
        if status == "edit"{
            let survey = User.current.survey[surveyIndex]
            
            for img in survey.photo{
                uploadedImgArr.append(UIImage(data: img.imgData)!)
            }
            
        }
        
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
        return uploadedImgArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = photoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoTableViewCell
        cell.uploadedImgView.image = uploadedImgArr[indexPath.row]
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
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
        for image in images {
            uploadedImgArr.append(image)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.allUploadView.alpha = 0
            self.photoTableView.alpha = 1
            self.uploadView2.alpha = 1
        })
        
        photoTableView.reloadData()
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {}
    
    func fusumaCameraRollUnauthorized() {}
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            
            for image in resolvedImages {
                self?.uploadedImgArr.append(image!)
            }
            
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
            
            if uploadedImgArr.count > 0{
                
                doneRefresh = true
                deadlineTime = deadlineTime + .seconds(1)
                self.photoTableView.beginUpdates()
                uploadedImgArr.remove(at: tag)
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
        
        if uploadedImgArr.count != 0{
            
            try! realm.write {
                
                realm.delete(User.current.photo)
                
                for img in uploadedImgArr{
                    let photo = Photo()
                    let imageData:Data = UIImagePNGRepresentation(img)!
                    photo.imgData = imageData
                    User.current.photo.append(photo)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                survey05VC.status = status
                
                if status == "edit"{
                    survey05VC.surveyIndex = surveyIndex
                }
                
                self.navigationController?.heroNavigationAnimationType = .fade
                self.navigationController?.pushViewController(survey05VC, animated: true)
            }
            
            /*
            
            
            var request = try! URLRequest(url: URL(string: "\(settings.api.baseUrl)v1/surveys/photos")!, method: .post)
            request.setValue("FrsApi \(defaults.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
            
            Hud.show(self.view)
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                // code
                var i = 0
                for img in self.uploadedImgArr{
                    let tempImg = self.resizeImage(image: img, newWidth: 200)
                    let imageData:Data = UIImagePNGRepresentation(tempImg)!
                    multipartFormData.append(imageData, withName: "photos[\(i)]", fileName: "1.png", mimeType: "image/png")
                    i += 1
                }
                multipartFormData.append("\(User.current.icnumber)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "icnumber")
            }, with: request, encodingCompletion: { (result) in
                // code
                switch result {
                case .success(let upload, _ , _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        Hud.hide()
                        
                        guard let data = response.result.value as? [String: AnyObject] else{
                            showErrorMessage("Internal server error")
                            return
                        }
                        
                        if data["code"] as! Int == 201{
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                            survey05VC.status = self.status
                            
                            if self.status == "edit"{
                                survey05VC.surveyIndex = self.surveyIndex
                            }
                            
                            self.navigationController?.heroNavigationAnimationType = .fade
                            self.navigationController?.pushViewController(survey05VC, animated: true)
                        }else{
                            showErrorMessage(data["message"] as! String)
                        }
                    })
                    
                case .failure(let _):
                    print("failed")
                    showErrorMessage("Internal server error")
                    
                }
            })*/
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
            survey05VC.status = status
            
            if status == "edit"{
                survey05VC.surveyIndex = surveyIndex
            }
            
            self.navigationController?.heroNavigationAnimationType = .fade
            self.navigationController?.pushViewController(survey05VC, animated: true)
        }
    }
}
