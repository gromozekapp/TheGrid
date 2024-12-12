////
////  CameraViewController.swift
////  TheGrid
////
////  Created by Daniil Zolotarev on 28.09.24.
////
import SwiftUI
import AVFoundation

class CameraViewController: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    let cameraQueue = DispatchQueue(label: "CameraQueue")
    
    override init() {
        super.init()
        setupSession()
    }
    
    func makeShot() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        
        // Проверяем, работает ли сессия
        if !captureSession.isRunning {
            cameraQueue.async {
                self.captureSession.startRunning()
            }
        }
        
        DispatchQueue.main.async {
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    private func setupSession() {
        // Запрашиваем разрешение на использование камеры
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted, let self = self else { return }
            
            self.cameraQueue.async {
                self.configureSession()
            }
        }
    }
    
    private func configureSession() {
        captureSession.beginConfiguration()
        
        // Настраиваем фронтальную камеру
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
            print("Не удалось настроить камеру")
            return
        }
        
        // Добавляем input и output
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Запускаем сессию
        captureSession.startRunning()
    }
    
    // Добавляем функцию для создания скриншота
    func takeScreenshot() {
        guard let window = UIApplication.shared.windows.first else {
            print("Не удалось получить окно для скриншота")
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let screenshot = renderer.image { context in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        // Сохраняем скриншот в галерею
        UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Ошибка при съемке фото: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Не удалось получить данные изображения")
            return
        }
        
        // Сохраняем фото в галерею
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Ошибка при сохранении: \(error.localizedDescription)")
        } else {
            print("Фото успешно сохранено")
        }
    }
}

// MARK: - SwiftUI View
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Получаем shared instance камеры
        let cameraController = CameraViewController()
        
        // Создаем и настраиваем preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.layer.bounds
        
        viewController.view.layer.addSublayer(previewLayer)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
