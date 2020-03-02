//
//  CameraController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/28.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Vision
import SwiftyJSON

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    
    @IBAction func captureImage(_ sender: Any) {
        self.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            
            //self.postImage(image: image)
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "ResultPage")
//            self.present(controller, animated: true, completion: nil)
            
            // Safe Present
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultPage") as? DetectionResultController
            {
                vc.postImage(image: image)
                self.present(vc, animated: true, completion: nil)
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }

    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var imageViewer = UIImageView()
    public enum CameraPosition {
        case front
        case rear
    }
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shutterButton.setImage(UIImage(named: "shutter"), for: UIControl.State.normal)
        shutterButton.setImage(UIImage(named: "shutter_pressed"), for: UIControl.State.highlighted)
        shutterButton.imageView?.contentMode = .scaleAspectFit
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            
        }
        
        
        self.navigationItem.title = "Pest Identifier"
        // Do any additional setup after loading the view.
        func configureCameraController() {
            self.prepare { (error) in
                if let error = error {
                    print("error occured!" , error)
                }
                
                try? self.displayPreview(on: self.capturePreviewView)
            }
        }
        

        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait // disable rotation
        
        configureCameraController()
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer? = nil) {
        sender!.view?.removeFromSuperview()
    }
    
    func postImage(image: UIImage){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let stringOfDateTimeStamp = formatter.string(from: Date())
        let myUrl = URL(string: "http://140.112.94.123:20000/PEST_DETECT/PEST_PAPER_IMAGES/PAPER_COUNTER/RX_IMG.php?username=bblabx")
        //        print("Date time stamp String: \(stringOfDateTimeStamp)")
        let remoteName = "IMG_\(stringOfDateTimeStamp)"+".png"
        let request = NSMutableURLRequest(url: myUrl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let fname = remoteName
        let mimetype = "image/jpg"
        
        let imageData = image.jpegData(compressionQuality: 1)
        body.append("--\(boundary)\r\n".data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        
        body.append(imageData!)
        body.append("\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
        
        request.httpBody = body
        
        
        let session = URLSession.shared
        let spinner = Spinner()
        let spinnerView = spinner.setSpinnerView(view: self.view)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            if error != nil{
                print(error!)
                return
            }
            
            do{
                let json = try JSON(data: data!)
                DispatchQueue.main.async {
                    spinnerView.removeFromSuperview()
                    print(json)
                    self.showResultImage(json: json)
                }
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }
        
        task.resume()

    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func showResultImage(json: JSON){
        let resultView = UIView()
        let resultImageView = UIImageView()
        
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(resultImageView)
        self.view.addConstraints([NSLayoutConstraint(item: resultImageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: resultImageView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: resultImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.view.frame.width),
                                  NSLayoutConstraint(item: resultImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.view.frame.height)])
        let imageUrl = "http://140.112.94.123:20000/PEST_DETECT/PEST_PAPER_IMAGES/PAPER_COUNTER/" + json["result_img"].stringValue
        var newUrl = ""
        if(imageUrl.split(separator: " ").count == 3){
            newUrl = imageUrl.split(separator: " ")[0] + "%20" + imageUrl.split(separator: " ")[1] + "%20" + imageUrl.split(separator: " ")[2]
        }
        print(newUrl)
        guard let url = URL(string: newUrl) else{ return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Failed fetching image:", error as Any)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                return
            }
            
            DispatchQueue.main.async {
                resultImageView.image = UIImage(data: data!)
                print("Result image shown")
            }
        }.resume()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        //settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
        
    }
    
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
            guard let camera = AVCaptureDevice.default(for: .video) else {throw CameraControllerError.noCamerasAvailable}
            
            if camera.position == .front {
                self.frontCamera = camera
            }
            
            if camera.position == .back {
                self.rearCamera = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
            
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            //2
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
        }
        
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
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
extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
                self.photoCaptureCompletionBlock?(image, nil)
            }
            
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}
