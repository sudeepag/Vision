//
//  CamViewController.swift
//  HackVision
//
//  Created by Sudeep Agarwal on 9/19/15.
//  Copyright © 2015 Sudeep Agarwal. All rights reserved.
//

import UIKit
import AVFoundation
import KYShutterButton
import AFNetworking
import SwiftyJSON
import SWXMLHash

class CamViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    var currentImage: UIImage!
    var pulsingLayer: PulsingLayer!
    var audioTimer: NSTimer!
    var audioPlayer: AVAudioPlayer!
    var camera:XMCCamera?
    var preview:AVCaptureVideoPreviewLayer!
    var result: ClarifaiResult?
    var completionSoundURL: NSURL!
    var shouldRecognizeMultipleTaps = false
    var isOtherLanguage = false
    @IBOutlet var shutterButton: KYShutterButton!
    @IBOutlet var bigButton: UIButton!
    @IBOutlet weak var camPrev: UIView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        SpeechManager.sharedManager.camVC = self
        
        let startMusicPath = NSBundle.mainBundle().pathForResource("shutdown", ofType: "mp3")
        let startMusicURL = NSURL.fileURLWithPath(startMusicPath!)
        do {
            try!  audioPlayer = AVAudioPlayer(contentsOfURL: startMusicURL)
        }
        audioPlayer.play()
        
        SpeechManager.sharedManager.readText("Welcome to Vision. Tap anywhere on the screen to identify an object or read a document.")
        
        initializeCamera()
        
        let completionSoundPath = NSBundle.mainBundle().pathForResource("completion", ofType: "wav")
        completionSoundURL = NSURL.fileURLWithPath(completionSoundPath!)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap")
        doubleTapRecognizer.numberOfTapsRequired = 2
        bigButton.addGestureRecognizer(doubleTapRecognizer)
        
        let tripleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleTripleTap")
        tripleTapRecognizer.numberOfTapsRequired = 3
        bigButton.addGestureRecognizer(tripleTapRecognizer)
        
        doubleTapRecognizer.requireGestureRecognizerToFail(tripleTapRecognizer)
    }
    
    func handleDoubleTap() {
        if (shouldRecognizeMultipleTaps) {
            if (isOtherLanguage) {
                self.shouldRecognizeMultipleTaps = false
                SpeechManager.sharedManager.readText("The document is in Spanish. Let me translate that for you.")
                animateButtonOut()
                audioTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "playSound", userInfo: nil, repeats: true)
                playSound()
                recognizeImage(self.currentImage, lang:"es") { (stringToRead) -> Void in
                    if (stringToRead != "") {
                        self.translate(stringToRead, authToken: NSUserDefaults.standardUserDefaults().valueForKey("translateToken") as! String, completion: { (translatedString) -> Void in
                
                        })
                    } else {
                        SpeechManager.sharedManager.readText("There was an error.")
                    }
                    self.animateButtonIn()
                    self.stopSound()
                }
            } else {
                self.shouldRecognizeMultipleTaps = false
                SpeechManager.sharedManager.readText("Gotcha. Hold on.")
                animateButtonOut()
                audioTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "playSound", userInfo: nil, repeats: true)
                playSound()
                recognizeImage(self.currentImage, lang:"en") { (stringToRead) -> Void in
                    if (stringToRead != "") {
                        SpeechManager.sharedManager.readText("Here's what I got." + stringToRead)
                    } else {
                        SpeechManager.sharedManager.readText("There was an error.")
                    }
                    self.animateButtonIn()
                    self.stopSound()
                }
            }
            
        }
    }
    
    func handleTripleTap() {
        isOtherLanguage = !isOtherLanguage
    }
    
    func recognizeImage(image: UIImage, lang:String, completion: String -> Void) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "https://api.projectoxford.ai/"))
        
        manager.requestSerializer.setValue("b83dcc45c08948ef846f6aacf72fbeea", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.POST("vision/v1/ocr?language=\(lang)&detectOrientation=true", parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            formData.appendPartWithFormData(imageData!, name:"image")
            }, success: { (ops, obj) -> Void in
                
                //                print("success \(ops) and \(obj)")
                
                var json = JSON(obj)
                //print(json["regions"])
                
                var textArray = [String]()
                var mutString = ""
                for (idx1, arr1):(String, JSON) in json["regions"] {
                    for (idx2, arr2):(String, JSON) in arr1["lines"] {
                        for (idx3, arr3):(String, JSON) in arr2["words"] {
                            mutString = mutString + " " + arr3["text"].stringValue
                        }
                    }
                }
                completion(mutString)
            }) { (req, err) -> Void in
                
                print("err \(req) and \(err)")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        createCamPrev()
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.visualEffectView.alpha = 0;
        }
        do {
            try!  audioPlayer = AVAudioPlayer(contentsOfURL: completionSoundURL)
        }
        
    }
    
    func initializeCamera() {
        camera = XMCCamera(sender: self)
    }
    
    func createCamPrev() {
        preview = AVCaptureVideoPreviewLayer(session: camera?.session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = camPrev.bounds
        camPrev.layer.addSublayer(preview)
    }
    
    @IBAction func bigButtonSelected(sender: AnyObject) {
        shutterButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    @IBAction func buttonSelected(sender: AnyObject) {
        audioTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "playSound", userInfo: nil, repeats: true)
        animateButtonOut()
        sendPhoto()
    }
    
    func playSound() {
        self.audioPlayer.play()
    }
    
    func stopSound() {
        self.audioPlayer.stop()
        audioTimer.invalidate()
    }
    
    func animateButtonIn() {
        removePulsing()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.shutterButton.alpha = 1.0
            self.shutterButton.enabled = true
        }
    }
    
    func animateButtonOut() {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.shutterButton.alpha = 0
            self.shutterButton.enabled = false
        }
        addPulsing()
    }
    
    func addPulsing() {
        pulsingLayer = PulsingLayer(pulseColor: UIColor.whiteColor())
        pulsingLayer.radius = 500.0
        pulsingLayer.animationDuration = 2.0
        pulsingLayer.pulseInterval = 0
        pulsingLayer.position = shutterButton.center
        self.camPrev.layer.addSublayer(pulsingLayer)
    }
    
    func removePulsing() {
        pulsingLayer.removeFromSuperlayer()
        pulsingLayer = nil
    }
    
    
    func sendPhoto() {
        camera?.captureStillImage({ (image) -> Void in
            print("image captured")
            self.currentImage = image
            PhotoManager.sharedManager.getResultForImage(image!, handler: { (res) -> Void in
                if (res != nil) {
                    SpeechManager.sharedManager.readTextForResult(res!)
                } else {
                    SpeechManager.sharedManager.readText("There was an error.")
                }
                self.animateButtonIn()
                self.stopSound()
            })
        })
    }
    
    func translate(textInSpanish:String, authToken:String, completion:String -> Void) {
        
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://api.microsofttranslator.com/"))
        
        manager.requestSerializer.setValue("Bearer" + " " + authToken, forHTTPHeaderField: "Authorization")
//        manager.responseSerializer.acceptableContentTypes = ["application/xml"]
        manager.responseSerializer = AFXMLParserResponseSerializer()

        let params = ["appId":"",
            "text":textInSpanish,
            "to": "en"]
        manager.GET("V2/Http.svc/Translate", parameters: params, success: { (res, obj) -> Void in
            
//            (obj as! NSXMLParser)
            
            let xmlp = obj as! NSXMLParser
            xmlp.delegate = self
            xmlp.parse()
            
//            completion(transText!)
            

            //Hadnle translation text here!!! ;)
            }) { (req, err) -> Void in
                
                print("error \(err)")
                
                
        }
    }
}

extension CamViewController:NSXMLParserDelegate {
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(qName)
        print(attributeDict)
        print(namespaceURI)
        print(elementName)
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        print(string)
        SpeechManager.sharedManager.readText("Here's what I got." + string)
    }
}

extension CamViewController:XMCCameraDelegate {
    
    func cameraSessionDidStop() {
        
    }
    
    func cameraSessionConfigurationDidComplete() {
        camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        
    }
}
