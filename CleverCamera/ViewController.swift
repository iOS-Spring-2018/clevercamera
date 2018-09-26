//
//  ViewController.swift
//  CleverCamera
//
//  Created by Jon Eikholm on 26/02/2018.
//  Copyright © 2018 Jon Eikholm. All rights reserved.
//

import UIKit
// Check out AVFoundation for more features

extension UIImage {
    
    func resizeImage(newWidth: CGFloat) -> UIImage{
        let newHeight = newWidth * (self.size.height / self.size.width)
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight)) // start a new "canvas"
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Task: Create Button "Load Image" which has a method connected to it
    
    let imagePicker = UIImagePickerController()
    let APIKEY = "AIzaSyD5TGZ0G9wxeUmjQ-loZs4_TsVfZT2uZFI"
    var url: URL{
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(APIKEY)")!
    }
    
    var theImage:UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self //
        imagePicker.allowsEditing = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadImagePressed(_ sender: UIButton) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func base64EncodeImage(image:UIImage) -> String {
        let imagedata = UIImagePNGRepresentation(image)
        return imagedata!.base64EncodedString(options: .endLineWithLineFeed) // returns image as a String
    }
    
    @IBAction func analyzePressed(_ sender: UIButton) {
        let imageString = base64EncodeImage(image: theImage!)  // get image as String
        let reqObject = Request(image: ["content" : imageString]) // prepare JSON object
        let requestsObj = Requests(requests: [reqObject])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
        urlRequest.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifyer")
        let jsonEncoder = JSONEncoder()
        do{
            let jsonData = try jsonEncoder.encode(requestsObj)
            urlRequest.httpBody = jsonData
        }catch {
            print("error in encoding: \(error.localizedDescription)")
        }
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        let task = urlSession.dataTask(with: urlRequest) { (data_, urlresponse, error) in
            if error != nil {
                print("error in google request \(error.debugDescription)")
            }else {
                print("success!!")
                if let data = data_ {
                 
                    DispatchQueue.main.async {
                        var responses:Responses?
                        do{
                            try responses = JSONDecoder().decode(Responses.self, from: data)
                            let response = responses?.responses.first
                            for annotation in (response?.labelAnnotations)! {
                                print("description: \(annotation.description) score: \(annotation.score)")
                               // self.bigLabel.text.append("\(annotation.description) score: \(annotation.score) \n")
                            }
                        }catch let error {
                            print("error in decoding \(error)")
                        }
                    }
                }else {
                    print("no data...")
                }
            }
        }
        task.resume()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("returned from image picking...")
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let smallImage = image.resizeImage(newWidth: 200)
        theImage = smallImage
        imageView.contentMode = .scaleToFill
        imageView.image = smallImage
        imageView.frame.size = CGSize(width: (theImage?.size.width)!, height: (theImage?.size.height)!)
        picker.dismiss(animated: true, completion: nil) // tell the imagePicker to un-present itself
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("you cacelled the picking")
        picker.dismiss(animated: true, completion: nil) // tell the imagePicker to un-present itself
    }

}
















