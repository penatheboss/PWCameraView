/*
 MIT License
 
 Copyright (c) [2016] [Pranav Wadhwa]
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

//Notes:

//This project is witten in Swift 3
//rotateButton has an image named "rotate" PWCameraView checks if the image exists; otherwise it will replace with a title
//The 'reload' method cannot be called in 'viewDidLoad'. Call it in 'viewWillAppear' or 'viewDidAppear'
//Add "NSCameraUsageDescription" in your info.plist with a String that states how your app will use the camera

import UIKit
import AVFoundation

class PWCameraView: UIView {
    
    enum CameraDirection {
        case Front
        case Back
    }
    
    var direction: CameraDirection = .Back
    
    func flipCamera(sender: AnyObject) {
        
        if direction == .Back {
            direction = .Front
        } else {
            direction = .Back
        }
        
        reload()
        
    }
    
    var clickButton = UIButton()
    
    var rotateButton = UIButton()
    
    var beginGestureScale = CGFloat()
    
    var captureSession: AVCaptureSession?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var tempBackground = UIImageView()
    
    var clickedImage: UIImage? {
        didSet {
            tempBackground.image = clickedImage
        }
    }
    
    func clickPicture() {
        
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            
            videoConnection.videoOrientation = .portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                
                if sampleBuffer != nil {
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData!)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1, orientation: .right)
                    
                    self.captureSession?.stopRunning()
                    self.clickedImage = image
                    
                    self.clickButton.frame.size = CGSize(width: 200, height: 80)
                    self.clickButton.setTitle("Retake", for: [])
                    self.clickButton.layer.cornerRadius =  40
                    self.clickButton.center.x = self.center.x
                    self.clickButton.layer.backgroundColor = self.shadeColor.cgColor
                    self.clickButton.removeTarget(nil, action: nil, for: .allEvents)
                    self.clickButton.addTarget(self, action: #selector(self.retakePicture), for: .touchUpInside)
                    self.clickButton.superview!.bringSubview(toFront: self.clickButton)
                    
                }
                
            })
            
        }
    }
    
    func retakePicture() {
        
        tempBackground.frame = self.frame
        reload()
        clickButton.setTitle("", for: [])
        clickButton.frame.size = CGSize(width: 80, height: 80)
        clickButton.layer.cornerRadius = clickButton.frame.size.width / 2
        clickButton.layer.borderColor = UIColor.white().cgColor
        clickButton.removeTarget(nil, action: nil, for: .allEvents)
        clickButton.layer.backgroundColor = shadeColor.cgColor
        clickButton.center.x = self.center.x
        clickButton.addTarget(self, action: #selector(self.clickPicture), for: .touchUpInside)
        clickButton.superview!.bringSubview(toFront: clickButton)
    }
    
    func reload() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetiFrame1280x720
        var captureDevice:AVCaptureDevice! = nil
        
        let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        
        
        for device in videoDevices! {
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.front {
                captureDevice = device
                break
            }
        }
        
        var input = AVCaptureDeviceInput()
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            print("catch")
            return
        }
        
        if self.captureSession!.canAddInput(input) == true {
            self.captureSession!.addInput(input)
            self.stillImageOutput = AVCaptureStillImageOutput()
            self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if self.captureSession!.canAddOutput(self.stillImageOutput) {
                self.captureSession!.addOutput(self.stillImageOutput)
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.previewLayer!.connection?.videoOrientation = .portrait
                self.previewLayer?.frame = self.bounds
                self.layer.addSublayer(self.previewLayer!)
                self.captureSession!.startRunning()
                self.clickedImage = nil
                self.bringSubview(toFront: self.clickButton)
                self.bringSubview(toFront: self.rotateButton)
            } else {
                print("cannot add ouput")
            }
        } else {
            print("cannot add input")
        }
        
        self.bringSubview(toFront: clickButton)
        self.bringSubview(toFront: rotateButton)
        
        
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .began {
            beginGestureScale = recognizer.scale
        }
        
        var allTouchesAreOnThePreviewLayer: Bool = true
        let numTouches: Int = recognizer.numberOfTouches()
        
        for i in 0..<numTouches {
            let location: CGPoint = recognizer.location(ofTouch: i, in: self)
            let convertedLocation: CGPoint = previewLayer!.convert(location, from: previewLayer!.superlayer)
            if !previewLayer!.contains(convertedLocation) {
                allTouchesAreOnThePreviewLayer = false
            }
        }
        
        if allTouchesAreOnThePreviewLayer {
            var effectiveScale = beginGestureScale * recognizer.scale
            if effectiveScale < 1.0 {
                effectiveScale = 1.0
            }
            let maxScaleAndCropFactor: CGFloat = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo).videoMaxScaleAndCropFactor
            if effectiveScale > maxScaleAndCropFactor {
                effectiveScale = maxScaleAndCropFactor
            }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.025)
            previewLayer?.setAffineTransform(CGAffineTransform(scaleX: effectiveScale, y: effectiveScale))
            CATransaction.commit()
        }
        
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            UIApplication.shared().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.zoom(recognizer:)))
        self.addGestureRecognizer(pinch)
        previewLayer?.frame = self.bounds
        
        clickButton.frame.size = CGSize(width: 100, height: 100)
        clickButton.layer.cornerRadius = clickButton.frame.size.width / 2
        clickButton.layer.borderColor = UIColor.white().cgColor
        clickButton.layer.borderWidth = 2.5
        clickButton.layer.backgroundColor = shadeColor.cgColor
        clickButton.center.x = self.center.x
        clickButton.center.y = self.frame.size.height - clickButton.frame.size.height + 20
        clickButton.addTarget(self, action: #selector(self.clickPicture), for: .touchUpInside)
        self.addSubview(clickButton)
        
        rotateButton.frame.size = CGSize(width: 45, height: 45)
        rotateButton.center = CGPoint(x: self.frame.size.width - rotateButton.frame.size.width, y: rotateButton.frame.size.height)
        if let rotateImage = UIImage(named: "rotate") {
            rotateButton.setImage(rotateImage, for: [])
        } else {
            rotateButton.setTitle("Rotate", for: [])
            rotateButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight)
        }
        self.addSubview(rotateButton)
        self.addSubview(tempBackground)
        
        self.bringSubview(toFront: clickButton)
        self.bringSubview(toFront: rotateButton)
        
    }
    
    let shadeColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
