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

struct OuterBox{
    let x = 10.0
    let y = 60.0
    var width: CGFloat
    var height: CGFloat
}

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var saveModeSwitch: UISwitch!
    @IBAction func switchClicked(_ sender: Any) {
        if self.saveModeSwitch.isOn{
            self.detectMode.text = NSLocalizedString("Detect Mode", comment: "")
        }
        else{
            self.detectMode.text = NSLocalizedString("Save Mode", comment: "")
        }
    }
    @IBAction func captureImage(_ sender: Any) {
        self.zoomIn(factor: 1.3)
        self.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            if let previewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewPage") as? CameraPreviewController
            {
                self.present(previewVC, animated: true, completion: nil)
                previewVC.showPreview(image: image)
                if self.saveModeSwitch.isOn{
                    previewVC.switchMode = true
                }
                else{
                    previewVC.switchMode = false
                }
            }
            
            // Safe Present
//            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultPage") as? DetectionResultController
//            {
//                vc.postImage(image: image)
//                if self.saveModeSwitch.isOn{
//                    self.present(vc, animated: true, completion: nil)
//
//                }
//
//            }
            self.zoomIn(factor: 1.0)
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    
    var imagePicker = UIImagePickerController()
    var detectMode = UILabel()
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
        
        drawBoundingBoxes()
        
        shutterButton.setImage(UIImage(named: "shutter"), for: UIControl.State.normal)
        shutterButton.setImage(UIImage(named: "shutter_pressed"), for: UIControl.State.highlighted)
        shutterButton.imageView?.contentMode = .scaleAspectFit
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            
        }
        
        
        self.navigationItem.title = "Insect Pest Identifier"
        // Do any additional setup after loading the view.
        func configureCameraController() {
            self.prepare { (error) in
                if let error = error {
                    print("error occured!" , error)
                }
                
                try? self.displayPreview(on: self.capturePreviewView)
            }
        }
        self.detectMode.text = NSLocalizedString("Detect Mode", comment: "")
        self.detectMode.frame = CGRect(x: 50, y: 700, width: 150, height: 20)

        self.view.addSubview(detectMode)
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait // disable rotation
        
        configureCameraController()
        
    }
    
    @IBAction func galleryButtonClicked(_ sender: Any) {
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                print("Button capture")

                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false

                present(imagePicker, animated: true, completion: nil)
                
            }
            
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: { () -> Void in

            })
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            picker.dismiss(animated: true, completion: nil)
            
            //var pickedImage = UIImage()
            let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
           
            if let previewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewPage") as? CameraPreviewController
            {
                self.present(previewVC, animated: true, completion: nil)
                previewVC.image = pickedImage
                if self.saveModeSwitch.isOn{
                    previewVC.switchMode = true
                }
                else{
                    previewVC.switchMode = false
                }
            }
            
            
        }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer? = nil) {
        sender!.view?.removeFromSuperview()
    }
    
    func drawBoundingBoxes(){
        let width = self.view.frame.width-20
        let height = width*1.43
        let outerBox = UIView(frame: CGRect(x: 10+(width-(width/1.3))/2, y: 60+(height-height/1.3)/2, width: width/1.3, height: height/1.3))
        outerBox.layer.borderWidth = 3.0
        outerBox.layer.borderColor = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        self.view.addSubview(outerBox)
    }
    
    func zoomIn(factor:CGFloat){
        do {
            try self.rearCamera?.lockForConfiguration()
        }
        catch{
            print(error)
        }
        self.rearCamera?.videoZoomFactor = factor
        self.rearCamera?.unlockForConfiguration()
    }
    
    func postImage(image: UIImage){
        var rotatedImg = UIImage()
        rotatedImg = self.imageRotatedByDegrees(oldImage: image, deg: 30)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let stringOfDateTimeStamp = formatter.string(from: Date())
        let myUrl = URL(string: "http://140.112.94.123:20000/PEST_DETECT/PEST_PAPER_IMAGES/PAPER_COUNTER/RX_IMG.php?username=bblabx")
        //        print("Date time stamp String: \(stringOfDateTimeStamp)")
        let remoteName = "IMG_\(stringOfDateTimeStamp)"+".jpg"
        let request = NSMutableURLRequest(url: myUrl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let fname = remoteName
        let mimetype = "image/jpg"
        
        let imageData = rotatedImg.jpegData(compressionQuality: 1)
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
        let previewBox = UIView(frame: CGRect(x: 10, y: 60, width: view.frame.width-20, height: 1.43 * (view.frame.width-20)))
        
        self.previewLayer?.frame = previewBox.frame
        
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
                defer {
                    camera.unlockForConfiguration()
                }
                camera.focusMode = .continuousAutoFocus
                //camera.videoZoomFactor = 2.0
                //camera.unlockForConfiguration()
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
    public func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(M_PI / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -rotatedSize.width / 2, y: -rotatedSize.height / 2, width: rotatedSize.width, height: rotatedSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
