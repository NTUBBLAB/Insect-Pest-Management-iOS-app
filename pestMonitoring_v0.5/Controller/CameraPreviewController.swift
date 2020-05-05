//
//  CameraPreviewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2020/4/14.
//  Copyright © 2020 Lab405. All rights reserved.
//

import UIKit

class CameraPreviewController: UIViewController {

    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!

    var image = UIImage()
    var switchMode: Bool?
    @IBAction func confirmClicked(_ sender: Any) {
        
        if self.switchMode == true{
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultPage") as? DetectionResultController
            {
                vc.postImage(image: image)
                
                self.present(vc, animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
                
            }
        }
        else{
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultPage") as? DetectionResultController
            {
                vc.postImage(image: image)
                
                //self.present(vc, animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelClicked(_ sender: Any) {
//        if let cameravc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraPage") as? CameraController
//        {
//                self.present(cameravc, animated: true, completion: nil)
//
//        }
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.image = self.image
        previewImageView.contentMode = .scaleAspectFit
        // Do any additional setup after loading the view.
    }
    
    public func showPreview(image: UIImage){
        self.image = image
        print(image)
        previewImageView.image = image
        previewImageView.contentMode = .scaleAspectFit
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


