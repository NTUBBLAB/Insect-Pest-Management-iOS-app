//
//  DetectionResultController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2020/2/11.
//  Copyright © 2020年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts

class DetectionResultController: UIViewController {

    @IBAction func dismissPage(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        // Do any additional setup after loading the view.
    }
    
    func postImage(image: UIImage){
        var rotatedImg = UIImage()
        rotatedImg = self.imageRotatedByDegrees(oldImage: image, deg: 0)
        
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
                    self.drawResults(counts: json["counts"].arrayObject as! [Int], species: json["species_cn"].arrayObject as! [String])
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
        
        let resultImageView = UIImageView()
        
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        //resultImageView.transform = resultImageView.transform.rotated(by: CGFloat( M_PI/2 ))
        resultImageView.contentMode = .scaleToFill
        self.view.addSubview(resultImageView)
        self.view.addConstraints([NSLayoutConstraint(item: resultImageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 120),
                                  NSLayoutConstraint(item: resultImageView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 20),
                                  NSLayoutConstraint(item: resultImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.view.frame.width-40),
                                  NSLayoutConstraint(item: resultImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        let imageUrl = "http://140.112.94.123:20000/PEST_DETECT/PEST_PAPER_IMAGES/PAPER_COUNTER/" + json["result_img"].stringValue
        var newUrl = ""
        if(imageUrl.split(separator: " ").count == 3){
            newUrl = imageUrl.split(separator: " ")[0] + "%20" + imageUrl.split(separator: " ")[1] + "%20" + imageUrl.split(separator: " ")[2]
        }
        print(newUrl)
        guard let url = URL(string: newUrl) else{return}
        
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
                resultImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                resultImageView.addGestureRecognizer(tap)
                
                print("Result image shown")
            }
        }.resume()
    }
    
    func drawResults(counts: [Int], species: [String]){
        let pieChartView = PieChartView()
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<counts.count {
            if counts[i] > 0{
                let dataEntry1 = PieChartDataEntry(value: Double(i), label: String(species[i]), data: counts[i] as AnyObject)
                
                dataEntries.append(dataEntry1)
            }
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<species.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pieChartView)
        self.view.addConstraints([NSLayoutConstraint(item: pieChartView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 350),
                                  NSLayoutConstraint(item: pieChartView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 150),
                                  NSLayoutConstraint(item: pieChartView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
                                  NSLayoutConstraint(item: pieChartView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        for i in 0..<species.count{
            let pestCount = UILabel()
            
            pestCount.text = species[i] + ": " + String(counts[i])
            pestCount.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(pestCount)
            self.view.addConstraints([NSLayoutConstraint(item: pestCount, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: CGFloat(370+50*i)),
                                      NSLayoutConstraint(item: pestCount, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 50),
                                      NSLayoutConstraint(item: pestCount, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                                      NSLayoutConstraint(item: pestCount, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30)])
            
            
        }
    }
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
           //Calculate the size of the rotated view's containing box for our drawing space
           let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.height, height: oldImage.size.width))
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
