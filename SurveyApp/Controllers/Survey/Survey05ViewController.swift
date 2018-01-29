//
//  Survey05ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 12/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Gallery
import Alamofire

class Survey05ViewController: BaseViewController, GalleryControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var allUploadView: UIView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var photoTableView: UITableView!
    
    @IBOutlet weak var uploadView2: UIView!
    @IBOutlet weak var uploadBtn: UIView!
    
    var uploadVideo = [Video]()
    var uploadedImgArr = [UIImage]()
    var uploadedUrlArr = [URL]()
    var doneRefresh = Bool()
    var changeIndex = Int()
    var isChange = Bool()
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gallery.Config.tabsToShow = [.videoTab]
        
        navigationBarSetup("second", title: "Survey Video")
        processNumber(5)
        addShadow(uploadView)
        addShadow(nextBtn)
        addShadow(uploadBtn)
        
        if status == "edit"{
            let survey = User.current.survey[surveyIndex]
            
            for img in survey.video{
                uploadedImgArr.append(UIImage(data: img.thumbnail)!)
                uploadedUrlArr.append(URL(string: img.url)!)
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
        cell.playBtn.isHidden = false
        cell.playImg.isHidden = false
        cell.playBtn.tag = indexPath.row
        
        cell.playBtn.addTarget(self, action: #selector(playVideo(_:)), for: UIControlEvents.touchUpInside)
        
        cell.changeBtn.addTarget(self, action: #selector(changeImage(_:)), for: UIControlEvents.touchUpInside)
        cell.removeBtn.addTarget(self, action: #selector(removeImage(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
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
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        var isFirst = Bool()
        
        editor.edit(video: video) { (vdeo, url) in
            video.fetchThumbnail { (image) in
                
                if !isFirst{
                    isFirst = true
                }else{
                    if self.isChange{
                        self.uploadedUrlArr.remove(at: self.changeIndex)
                        self.uploadedImgArr.remove(at: self.changeIndex)
                        self.uploadVideo.remove(at: self.changeIndex)
                        
                        self.uploadedUrlArr.insert(url!, at: self.changeIndex)
                        self.uploadedImgArr.insert(image!, at: self.changeIndex)
                        self.uploadVideo.insert(video, at: self.changeIndex)
                        
                        self.isChange = false
                    }else{
                        self.uploadedUrlArr.append(url!)
                        self.uploadedImgArr.append(image!)
                        self.uploadVideo.append(video)
                    }
                    
                    
                    controller.dismiss(animated: true, completion: nil)
                    self.gallery = nil
                    
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.allUploadView.alpha = 0
                    self.photoTableView.alpha = 1
                    self.uploadView2.alpha = 1
                })
                
                self.photoTableView.reloadData()
            }
        }
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {}
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        isChange = false
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
        
        isChange = true
        gallery = GalleryController()
        gallery.delegate = self
        
        present(gallery, animated: true, completion: nil)
        
    }
    
    @objc func playVideo(_ sender: UIButton){
        let tag = sender.tag
        
        if status == "edit"{
            let tempPath = uploadedUrlArr[tag]
            
            let controller = AVPlayerViewController()
            controller.player = AVPlayer(url: tempPath)
            controller.player?.play()
            
            self.present(controller, animated: true, completion: nil)
            
        }else{
            let video = uploadVideo[tag]
            
            Hud.show(view)
            editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
                DispatchQueue.main.async {
                    Hud.hide()
                    if let tempPath = tempPath {
                        
                        let controller = AVPlayerViewController()
                        controller.player = AVPlayer(url: tempPath)
                        controller.player?.play()
                        
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if uploadedImgArr.count != 0{
            
            try! realm.write {
                
                realm.delete(User.current.video)
                
                var i = 0
                for thumbnail in uploadedImgArr{
                    
                    let video = VideoSurvey()
                    let imageData:Data = UIImagePNGRepresentation(thumbnail)!
                    video.thumbnail = imageData
                    video.url = "\(uploadedUrlArr[i])"
                    User.current.video.append(video)
                    
                    i += 1
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let survey06VC = storyboard.instantiateViewController(withIdentifier: "Survey06VC") as! Survey06ViewController
                survey06VC.status = status
                
                if status == "edit"{
                    survey06VC.surveyIndex = surveyIndex
                }
                
                self.navigationController?.heroNavigationAnimationType = .fade
                self.navigationController?.pushViewController(survey06VC, animated: true)
                
            }
            /*
            var request = try! URLRequest(url: URL(string: "\(settings.api.baseUrl)v1/surveys/videos")!, method: .post)
            request.setValue("FrsApi \(defaults.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
            
            Hud.show(self.view)
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                // code
                var i = 0
                for url in self.uploadedUrlArr{
                    multipartFormData.append(url, withName: "videos[\(i)]", fileName: "vdeo.mp4", mimeType: "video/mp4")
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
                            let survey06VC = storyboard.instantiateViewController(withIdentifier: "Survey06VC") as! Survey06ViewController
                            survey06VC.status = self.status
                            
                            if self.status == "edit"{
                                survey06VC.surveyIndex = self.surveyIndex
                            }
                            
                            self.navigationController?.heroNavigationAnimationType = .fade
                            self.navigationController?.pushViewController(survey06VC, animated: true)
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
            let survey06VC = storyboard.instantiateViewController(withIdentifier: "Survey06VC") as! Survey06ViewController
            survey06VC.status = status
            
            if status == "edit"{
                survey06VC.surveyIndex = surveyIndex
            }
            
            self.navigationController?.heroNavigationAnimationType = .fade
            self.navigationController?.pushViewController(survey06VC, animated: true)
        }
    }
}
