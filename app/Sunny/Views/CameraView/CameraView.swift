//
//  CameraView.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    let bodyPart: BodyPart?
    let subPart: BodySubPart?
    let scanOption: ScanOption?
    let onCapture: (UIImage) -> Void
    
    @State private var camera = CameraViewModel()
    @State private var capturedImage: UIImage?
    @State private var showFlash = false
    
    var title: String {
        if let subPart = subPart, let bodyPart = bodyPart {
            return "\(bodyPart.displayName) - \(subPart.displayName)"
        } else if scanOption == .sunscreenScan {
            return "Sunscreen Check"
        } else {
            return "Take Photo"
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Camera preview
            cameraPreviewView(isTaken: ((capturedImage) != nil) == true)
            
            // Flash effect
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(showFlash ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: showFlash)
            }
        }
        .onAppear {
            Task {
                await camera.startSession()
            }
        }
        .onDisappear {
            camera.stopSession()
        }
    }
    
    // MARK: - Camera Preview View
    
    @ViewBuilder
    private func cameraPreviewView(isTaken: Bool) -> some View {
        ZStack {
            // Camera preview layer
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
            
            if isTaken {
                reviewView()
            } else {
                VStack {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        Button {
                            camera.switchCamera()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Capture controls
                    VStack(spacing: 20) {
                        // Flash toggle
                        HStack(spacing: 40) {
                            Button {
                                camera.toggleFlash()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                        .font(.title2)
                                    Text(camera.isFlashOn ? "On" : "Off")
                                        .font(.caption)
                                }
                                .foregroundColor(camera.isFlashOn ? .yellow : .white)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                        
                        // Capture button
                        Button {
                            Task {
                                await capturePhoto()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 68, height: 68)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

        }
    }
    
    // MARK: - Review View
    
    private func reviewView() -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack(spacing: 40) {
                    // Retake button
                    Button {
                        withAnimation {
                            capturedImage = nil
                        }
                        Task {
                            await camera.startSession()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                            Text("Retake")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    // Use photo button
                    Button {
                        if let capturedImage {
                            onCapture(capturedImage)
                        }
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                            Text("Use Photo")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Capture Photo
    
    private func capturePhoto() async {
        // Flash effect
        showFlash = true
        try? await Task.sleep(for: .milliseconds(100))
        showFlash = false
        
        // Capture the photo
        if let image = await camera.capturePhoto() {
            withAnimation {
                capturedImage = image
            }
        }
        camera.stopSession()
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Camera View Model

@MainActor
@Observable
final class CameraViewModel: NSObject {
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var currentCamera: AVCaptureDevice.Position = .back
    
    var isFlashOn = false
    
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
    }
    
    func startSession() async {
        await setupCamera()
        
        sessionQueue.async { [session] in
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [session] in
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    private func setupCamera() async {
        session.beginConfiguration()
        
        // Set session preset
        session.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCamera) else {
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            // Remove existing inputs
            session.inputs.forEach { session.removeInput($0) }
            
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
            }
        } catch {
            print("Error creating camera input: \(error)")
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        session.commitConfiguration()
    }
    
    func switchCamera() {
        currentCamera = currentCamera == .back ? .front : .back
        
        Task {
            await setupCamera()
        }
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func capturePhoto() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let settings = AVCapturePhotoSettings()
            
            if isFlashOn && photoOutput.supportedFlashModes.contains(.on) {
                settings.flashMode = .on
            } else {
                settings.flashMode = .off
            }
            
            settings.photoQualityPrioritization = .quality
            
            captureCompletion = { image in
                continuation.resume(returning: image)
            }
            
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - Photo Capture Delegate

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            Task { @MainActor in
                captureCompletion?(nil)
                captureCompletion = nil
            }
            return
        }
        
        Task { @MainActor in
            captureCompletion?(image)
            captureCompletion = nil
        }
    }
}

#Preview {
    CameraView(bodyPart: nil, subPart: nil, scanOption: nil, onCapture: {_ in })
}
