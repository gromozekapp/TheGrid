////
////  CameraViewController.swift
////  TheGrid
////
////  Created by Daniil Zolotarev on 28.09.24.
////
//import SwiftUI
//import AVFoundation
//
//class CameraViewController: UIViewController {
//    
//    let captureSession = AVCaptureSession()
//    let photoOutput = AVCapturePhotoOutput()
//    let cameraQueue = DispatchQueue(label: "CameraQueue")
//    let photoImageView = UIImageView()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        openCamera()
//        
//        // Настройка слоя для отображения видео
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.layer.bounds
//        view.layer.addSublayer(previewLayer)
//    }
//    
//    func makeShot() {
//        cameraQueue.async {
//                self.captureSession.startRunning()
//        }
//        let photoSettings = AVCapturePhotoSettings()
//        photoSettings.flashMode = .auto
//        photoOutput.capturePhoto(with: photoSettings, delegate: self)
//    }
//    
//    func openCamera() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//            
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                if granted {
//                    self.setupSession()
//                }
//                else {
//                    print("the user has not granted to the camera")
//                }
//            }
//        case .restricted:
//            print("somthing went wrong")
//        case .denied:
//            print("somthing went wrong")
//        case .authorized:
//            setupSession()
//        @unknown default:
//            print("somthing went wrong")
//        }
//    }
//    
//    func setupSession() {
//        captureSession.beginConfiguration()
//        
//        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
//        
//            do {
//                let input = try AVCaptureDeviceInput(device: frontCamera)
//                
//                if captureSession.canAddInput(input) == true {
//                    captureSession.addInput(input)
//                }
//                
//                guard captureSession.canAddOutput(photoOutput) else { return }
//                captureSession.addOutput(photoOutput)
//                
//            } catch let error {
//                print("Ошибка при настройке фронтальной камеры: \(error)")
//            }
//        
//        captureSession.commitConfiguration()
//    
//        cameraQueue.async {
//                self.captureSession.startRunning()
//        }
//    }
//}
////MARK: persistion
//extension CameraViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation(),
//              let previewImage = UIImage(data: imageData) else { return }
//        
//        photoImageView.image = previewImage
//        UIImageWriteToSavedPhotosAlbum(previewImage, nil, nil, nil)
//        cameraQueue.async {
//            self.captureSession.stopRunning()
//        }
//    }
//}
//
////MARK: Представление для интеграции CameraViewController в SwiftUI
//struct CameraView: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> CameraViewController {
//        return CameraViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
//        // Обновления здесь не требуются
//    }
//}
//
import SwiftUI
import AVFoundation

class CameraViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()  // Новый объект для записи видео
    let cameraQueue = DispatchQueue(label: "CameraQueue")
    let photoImageView = UIImageView()
    var isRecording = false  // Состояние записи
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
        
        // Настройка слоя для отображения видео
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    func makeShot() {
        cameraQueue.async {
            self.captureSession.startRunning()
        }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                } else {
                    print("The user has not granted access to the camera")
                }
            }
        case .restricted, .denied:
            print("Camera access denied")
        case .authorized:
            setupSession()
        @unknown default:
            print("Unknown camera authorization status")
        }
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // Добавление фото-выхода
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            // Добавление видео-выхода для записи
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
            }
            
        } catch {
            print("Ошибка при настройке фронтальной камеры: \(error)")
        }
        
        captureSession.commitConfiguration()
        
        cameraQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    // Функция начала/остановки записи
    func toggleRecording() {
        if isRecording {
            // Остановить запись
            movieOutput.stopRecording()
        } else {
            // Начать запись
            let outputPath = NSTemporaryDirectory() + "tempMovie.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
        isRecording.toggle()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate для фото

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let previewImage = UIImage(data: imageData) else { return }
        
        photoImageView.image = previewImage
        UIImageWriteToSavedPhotosAlbum(previewImage, nil, nil, nil)
        
        cameraQueue.async {
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate для видео

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        // Сохранить видео в фотоальбом
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
    }
}

// MARK: - Представление для интеграции CameraViewController в SwiftUI

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Обновления здесь не требуются
    }
}
