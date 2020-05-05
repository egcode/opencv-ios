//
//  FrameExtractor.swift
//  opencvios
//
//  Created by Eugene Golovanov on 4/27/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

enum Cam: String {
    case front = "front"
    case back = "back"
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var fps = 1
    private var cam: Cam = .front
    
    var lastTimestamp = CMTime()
    
    
    private var frame = 0
    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.medium
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    
    weak var delegate: FrameExtractorDelegate?
    
    init(cam: Cam, fps:Int) {
        super.init()
        self.cam = cam
        self.fps = fps
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: AVSession configuration
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
        connection.isVideoMirrored = position == .back
    }
    
    //    private func selectCaptureDevice() -> AVCaptureDevice? {
    //        return AVCaptureDevice.devices().filter {
    //            ($0 as AnyObject).hasMediaType(AVMediaType.video) &&
    //                ($0 as AnyObject).position == position
    //            }.first
    //    }
    private func selectCaptureDevice() -> AVCaptureDevice? {
        //        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        
        if (self.cam == .back) {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        } else {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        }
    }
    
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        //        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        //        DispatchQueue.main.async { [unowned self] in
        //            self.delegate?.captured(image: uiImage)
        //        }
        
        // Because lowering the capture device's FPS looks ugly in the preview,
        // we capture at full speed but only call the delegate at its desired
        // framerate.
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        if deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            DispatchQueue.main.async { [unowned self] in
                self.delegate?.captured(image: uiImage)
            }
            
            //            frame = frame + 1
            //            print("Got a frame! \(CMTimeMake(1, Int32(fps)))")
            //            print("delta! \(deltaTime.seconds)")
            
        }
        
        
        
    }
    
    func stopSession() {
        self.captureSession.stopRunning()
    }
}

