// QRScannerViewModel.swift

import Foundation
import AVFoundation
import SwiftUI
import Combine

enum QRResult {
    case url(URL)
    case text(String)
    
    var rawString: String {
        switch self {
        case .url(let url):
            return url.absoluteString
        case .text(let text):
            return text
        }
    }
}

class QRScannerViewModel: NSObject, ObservableObject {
    @Published var scannedResult: QRResult?
    @Published var isScanning: Bool = false
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined
    @Published var torchOn: Bool = false
    
    let session = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestPermissionAutorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermission = granted ? .authorized : .denied
                }
                if granted {
                    self?.setupSession()
                }
            }
        default:
            DispatchQueue.main.async {
                self.cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }
            
            self.captureDevice = device
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            let output = AVCaptureMetadataOutput()
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.qr]
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    func toggleTorch() {
        guard let device = captureDevice, device.hasTorch else { return }
        try? device.lockForConfiguration()
        torchOn.toggle()
        device.torchMode = torchOn ? .on : .off
        device.unlockForConfiguration()
    }
    
    func resetScan() {
        isScanning = false
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.stopRunning()
        }
    }
}

extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard scannedResult == nil,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        if let url = URL(string: stringValue),
           url.scheme == "https" || url.scheme == "http",
           url.host != nil {
            scannedResult = .url(url)
        } else {
            scannedResult = .text(stringValue)
        }
    }
}
