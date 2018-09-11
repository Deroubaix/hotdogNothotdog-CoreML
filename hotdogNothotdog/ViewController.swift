//
//  ViewController.swift
//  hotdogNothotdog
//
//  Created by Marisha Deroubaix on 10/09/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var topBarImage: UIImageView!
 
  
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePicker.delegate = self
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    
    if let userPickedImage = info[.originalImage] as? UIImage {
     
      imageView.image = userPickedImage
      imagePicker.dismiss(animated: true, completion: nil)
      
      guard let ciImage = CIImage(image: userPickedImage) else {
        fatalError("Could not convert UIImage to CIImage")
      }
      
      detect(image: ciImage)
      
    }
  }
  
  
  func detect(image: CIImage) {
    
    guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
      fatalError("Loading CoreML Model failed")
    }

    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let results = request.results as? [VNClassificationObservation],
      let firstResult = results.first
      else {
        fatalError("Model failed to process image")
      }
      
        if firstResult.identifier.contains("hotdog") {
          DispatchQueue.main.async {
            self.navigationItem.title = "It's a Hotdog! 😍"
            self.navigationController?.navigationBar.barTintColor = UIColor.green
            self.navigationController?.navigationBar.isTranslucent = false
            self.topBarImage.image = UIImage(named: "yeshotdog")
          }
        } else {
          DispatchQueue.main.async {
            self.navigationItem.title = "Not a Hotdog! 😞"
            self.navigationController?.navigationBar.barTintColor = UIColor.red
            self.navigationController?.navigationBar.isTranslucent = false
            self.topBarImage.image = UIImage(named: "nothotdog")
          }
      }
    }
    
    let handler = VNImageRequestHandler(ciImage: image)
    
    do {
    try handler.perform([request])
    } catch {
      print(error)
    }
  }

  @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = false
    present(imagePicker, animated: true, completion: nil)
    
  }
  
}

