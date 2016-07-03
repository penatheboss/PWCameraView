# PWCameraView
An awesome camera for everybody's use!

Notes about PWCameraView


This project is witten in Swift 3

rotateButton has an image named "rotate" PWCameraView checks if the image exists; otherwise it will replace with a title

The 'reload' method cannot be called in 'viewDidLoad'. Call it in 'viewWillAppear' or 'viewDidAppear'

Add "NSCameraUsageDescription" in your info.plist with a String that states how your app will use the camera


Usage:

    let camera = PWCameraView(frame: self.view.frame)
    self.view.addSubview(camera)
    camera.reload()
