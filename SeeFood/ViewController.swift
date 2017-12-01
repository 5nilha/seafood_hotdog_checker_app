//
//  ViewController.swift
//  SeeFood
//
//  Created by Fabio Quintanilha on 12/1/17.
//  Copyright © 2017 Fabio Quintanilha. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ProgressHUD
import SVProgressHUD

/* Added at info.plit privacy - Camera usage description and privacy - Photo Library Usage Description */

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera // picks an image from camera
        imagePicker.allowsEditing = false
        
        cameraButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cameraTapped(cameraButton)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Passes a key to the info dictionary which contains the picked image
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            imageView.image = userPickedImage
            
            //Converts the UIImage to CIImage
            guard let ciImage = CIImage(image: userPickedImage)
            else {
                fatalError("Could not convert UIImage to CIImage") // this line only s called when the ciImage is nil
            }
            
            //Pass the CIIimage in the detect method
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func detect(image: CIImage) {
        
        //Load the model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)
        else {
            fatalError("Loading CoreML model Failed") // this line only s called when the model is nil
        }
        
        //Creates a request to ask the model to classify the whatever data that is passed
        let request = VNCoreMLRequest(model: model) { (request, error) in
           guard let results = request.results as? [VNClassificationObservation]
            else {
                fatalError("Model failed to process image")
            }
            
            print(results)
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    ProgressHUD.showSuccess("Hotdog!")
                    
                }
                else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                   ProgressHUD.showError("Not Hotdog!")
                }
            }
        
        }
        
        //the data that is passed is defined here using a handler to perform the request of classify the the image
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print("Error: \(error)")
        }
        
        
    }
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        //When the camera is tapped, it presents the imagePicker to the user
        present(imagePicker, animated: true, completion: nil)
    }
    

}

