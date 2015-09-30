//
//  PhotoManager.swift
//  HackVision
//
//  Created by Sudeep Agarwal on 9/19/15.
//  Copyright © 2015 Sudeep Agarwal. All rights reserved.
//

import Foundation

class PhotoManager {
    
    static let sharedManager = PhotoManager()
    let client: ClarifaiClient?
    
    init() {
        client = ClarifaiClient(appID: kAppID, appSecret: kAppSecret)
    }

    func imageToData(image: UIImage) -> NSData? {
        let size = CGSize(width: 256, height: 256 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = UIImageJPEGRepresentation(scaledImage, 0.6)
        return imageData
    }
    
    func getResultForImage(image: UIImage, handler:ClarifaiResult? -> Void) {
        let data = imageToData(image)
        var result: ClarifaiResult?
        if (data != nil) {
            print("sending image")
            client?.recognizeJpegs([data!], completion: { (results, err) -> Void in
                result = results.first as? ClarifaiResult
                handler(result!)
                //SpeechManager.sharedManager.readText(self.wordForTags(result.tags as! [String])!)
            })
        } else {
            print("image data is nil")
        }
    }

}