//
//  CameraViewController.swift
//  TheGrid
//
//  Created by Daniil Zolotarev on 28.09.24.
//
import SwiftUI
import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Настраиваем захват с фронтальной камеры
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        // Получаем фронтальную камеру
        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession?.canAddInput(input) == true {
                    captureSession?.addInput(input)
                }
            } catch {
                print("Ошибка при настройке фронтальной камеры: \(error)")
            }
        }

        // Настройка слоя для отображения видео
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        // Запускаем сессию на фоновом потоке
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    // Останавливаем захват при уничтожении контроллера
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Останавливаем сессию на фоновом потоке
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
        }
    }
}

// Представление для интеграции CameraViewController в SwiftUI
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Обновления здесь не требуются
    }
}

