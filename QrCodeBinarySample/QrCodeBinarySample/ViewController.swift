//
//  ViewController.swift
//  QrCodeBinarySample
//
//  Created by Taizo Kusuda on 2018/02/10.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import UIKit
import AVFoundation
import ZXingObjC

class ViewController: UIViewController {

    @IBOutlet weak var preview: UIView!

    var zxcapture: ZXCapture? = nil
    var capturing: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // check if camera device is available
        guard AVCaptureDevice.default(for: AVMediaType.video) != nil else {
            print("error_no_camera")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        switch (status) {
        case .authorized: // ok
            break
        case .denied: // ng
            print("error_camera_denied")
            return
        case .restricted: // ?
            break
        case .notDetermined:
            // first time
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> () in
                if !granted {
                    print("error_camera_denied")
                    return
                }})
        }

        let zxcapture = ZXCapture()
        self.zxcapture = zxcapture
        zxcapture.delegate = self
        zxcapture.camera = zxcapture.back()

        zxcapture.layer.frame = preview.bounds
        preview.layer.addSublayer(zxcapture.layer)

        zxcapture.start()
        capturing = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : ZXCaptureDelegate {

    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        guard capturing else {
            return
        }
        if (result.barcodeFormat != kBarcodeFormatQRCode){
            return;
        }
        capturing = false

        zxcapture?.stop()

        if let text = result.text {
            print("Result text: \(text)")
        }

        if let bytes = result.resultMetadata.object(forKey: kResultMetadataTypeByteSegments.rawValue) as? NSArray {
            let byteArray = bytes[0] as! ZXByteArray
            let data =  Data.init(bytes: UnsafeRawPointer(byteArray.array), count: Int(byteArray.length))

            // print result
            var resultString = ""
            data.forEach { (byte) in
                resultString.append(String(format:"0x%02X,", byte))
            }
            print("Result binary: \(resultString)")
        }
    }
}


