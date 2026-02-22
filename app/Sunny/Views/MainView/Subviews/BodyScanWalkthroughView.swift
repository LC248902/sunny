//
//  BodyScanWalkthroughView.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//

import SwiftUI
import Foundation

struct WalkthroughStep: Identifiable, Hashable {
    let id = UUID()
    let bodyPart: BodyPart
    let subPart: BodySubPart
    let orientation: BodyOrientation?
    let instruction: String
    let tips: String?
    let isRequired: Bool
    
    var fullName: String {
        if let orientation = orientation {
            return "\(bodyPart.displayName) - \(subPart.displayName) (\(orientation == .front ? "Front" : "Back"))"
        }
        return "\(bodyPart.displayName) - \(subPart.displayName)"
    }
}

// MARK: - Walkthrough Generator

func generateFullBodyWalkthrough() -> [WalkthroughStep] {
    var steps: [WalkthroughStep] = []
    
    // Head - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .head,
            subPart: .face,
            orientation: .front,
            instruction: "Capture your face",
            tips: "Look straight ahead with good lighting",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .head,
            subPart: .neckFront,
            orientation: .front,
            instruction: "Capture front of your neck",
            tips: "Tilt your head back slightly",
            isRequired: true
        )
    ])
    
    // Head - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .head,
            subPart: .scalp,
            orientation: .back,
            instruction: "Capture your scalp",
            tips: "Part your hair to get a clear view, use a mirror or ask for help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .head,
            subPart: .headBack,
            orientation: .back,
            instruction: "Capture back of your head",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .head,
            subPart: .neckBack,
            orientation: .back,
            instruction: "Capture back of your neck",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        )
    ])
    
    // Head - Both Sides
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .head,
            subPart: .leftEar,
            orientation: nil,
            instruction: "Capture your left ear",
            tips: "Turn your head to show your left ear clearly",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .head,
            subPart: .rightEar,
            orientation: nil,
            instruction: "Capture your right ear",
            tips: "Turn your head to show your right ear clearly",
            isRequired: false
        )
    ])
    
    // Left Arm - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .shoulderFront,
            orientation: .front,
            instruction: "Capture front of your left shoulder",
            tips: nil,
            isRequired: true
        )
    ])
    
    // Left Arm - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .shoulderBack,
            orientation: .back,
            instruction: "Capture back of your left shoulder",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        )
    ])
    
    // Left Arm - Both Views
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .armUpper,
            orientation: nil,
            instruction: "Capture your left upper arm",
            tips: "Rotate to capture all sides",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .armLower,
            orientation: nil,
            instruction: "Capture your left forearm",
            tips: "Rotate to capture all sides",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .hand,
            orientation: nil,
            instruction: "Capture your left hand",
            tips: "Capture both palm and back",
            isRequired: true
        )
    ])
    
    // Left Hand Fingers - Optional
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .thumbFinger,
            orientation: nil,
            instruction: "Capture your left thumb",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .indexFinger,
            orientation: nil,
            instruction: "Capture your left index finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .middleFinger,
            orientation: nil,
            instruction: "Capture your left middle finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .ringFinger,
            orientation: nil,
            instruction: "Capture your left ring finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftArm,
            subPart: .pinkyFinger,
            orientation: nil,
            instruction: "Capture your left pinky finger",
            tips: "Get close for detail",
            isRequired: false
        )
    ])
    
    // Right Arm - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .shoulderFront,
            orientation: .front,
            instruction: "Capture front of your right shoulder",
            tips: nil,
            isRequired: true
        )
    ])
    
    // Right Arm - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .shoulderBack,
            orientation: .back,
            instruction: "Capture back of your right shoulder",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        )
    ])
    
    // Right Arm - Both Views
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .armUpper,
            orientation: nil,
            instruction: "Capture your right upper arm",
            tips: "Rotate to capture all sides",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .armLower,
            orientation: nil,
            instruction: "Capture your right forearm",
            tips: "Rotate to capture all sides",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .hand,
            orientation: nil,
            instruction: "Capture your right hand",
            tips: "Capture both palm and back",
            isRequired: true
        )
    ])
    
    // Right Hand Fingers - Optional
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .thumbFinger,
            orientation: nil,
            instruction: "Capture your right thumb",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .indexFinger,
            orientation: nil,
            instruction: "Capture your right index finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .middleFinger,
            orientation: nil,
            instruction: "Capture your right middle finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .ringFinger,
            orientation: nil,
            instruction: "Capture your right ring finger",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightArm,
            subPart: .pinkyFinger,
            orientation: nil,
            instruction: "Capture your right pinky finger",
            tips: "Get close for detail",
            isRequired: false
        )
    ])
    
    // Torso - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .chest,
            orientation: .front,
            instruction: "Capture your chest",
            tips: "Stand straight with arms at sides",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .abdomen,
            orientation: .front,
            instruction: "Capture your abdomen",
            tips: "Stand straight with good lighting",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .groin,
            orientation: .front,
            instruction: "Capture your groin area",
            tips: "Ensure privacy and good lighting",
            isRequired: true
        )
    ])
    
    // Torso - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .backUpper,
            orientation: .back,
            instruction: "Capture your upper back",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .backLower,
            orientation: .back,
            instruction: "Capture your lower back",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .torso,
            subPart: .buttocks,
            orientation: .back,
            instruction: "Capture your buttocks",
            tips: "Use a mirror for privacy and accuracy",
            isRequired: true
        )
    ])
    
    // Left Leg - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .legFrontUpper,
            orientation: .front,
            instruction: "Capture front of your left thigh",
            tips: "Stand straight for clear view",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .legFrontLower,
            orientation: .front,
            instruction: "Capture front of your left shin",
            tips: nil,
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .footTop,
            orientation: .front,
            instruction: "Capture top of your left foot",
            tips: "Ensure toes are visible",
            isRequired: true
        )
    ])
    
    // Left Leg - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .legBackUpper,
            orientation: .back,
            instruction: "Capture back of your left thigh",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .legBackLower,
            orientation: .back,
            instruction: "Capture back of your left calf",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .footHeel,
            orientation: .back,
            instruction: "Capture your left heel",
            tips: "Stand on tiptoes or elevate foot",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .footSole,
            orientation: .back,
            instruction: "Capture sole of your left foot",
            tips: "Sit and lift foot for clear view",
            isRequired: true
        )
    ])
    
    // Left Foot Toes - Optional
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .bigToe,
            orientation: .front,
            instruction: "Capture your left big toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .indexToe,
            orientation: .front,
            instruction: "Capture your left index toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .middleToe,
            orientation: .front,
            instruction: "Capture your left middle toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .ringToe,
            orientation: .front,
            instruction: "Capture your left ring toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .leftLeg,
            subPart: .pinkyToe,
            orientation: .front,
            instruction: "Capture your left pinky toe",
            tips: "Get close for detail",
            isRequired: false
        )
    ])
    
    // Right Leg - Front View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .legFrontUpper,
            orientation: .front,
            instruction: "Capture front of your right thigh",
            tips: "Stand straight for clear view",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .legFrontLower,
            orientation: .front,
            instruction: "Capture front of your right shin",
            tips: nil,
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .footTop,
            orientation: .front,
            instruction: "Capture top of your right foot",
            tips: "Ensure toes are visible",
            isRequired: true
        )
    ])
    
    // Right Leg - Back View
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .legBackUpper,
            orientation: .back,
            instruction: "Capture back of your right thigh",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .legBackLower,
            orientation: .back,
            instruction: "Capture back of your right calf",
            tips: "Use a mirror or ask someone to help",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .footHeel,
            orientation: .back,
            instruction: "Capture your right heel",
            tips: "Stand on tiptoes or elevate foot",
            isRequired: true
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .footSole,
            orientation: .back,
            instruction: "Capture sole of your right foot",
            tips: "Sit and lift foot for clear view",
            isRequired: true
        )
    ])
    
    // Right Foot Toes - Optional
    steps.append(contentsOf: [
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .bigToe,
            orientation: .front,
            instruction: "Capture your right big toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .indexToe,
            orientation: .front,
            instruction: "Capture your right index toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .middleToe,
            orientation: .front,
            instruction: "Capture your right middle toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .ringToe,
            orientation: .front,
            instruction: "Capture your right ring toe",
            tips: "Get close for detail",
            isRequired: false
        ),
        WalkthroughStep(
            bodyPart: .rightLeg,
            subPart: .pinkyToe,
            orientation: .front,
            instruction: "Capture your right pinky toe",
            tips: "Get close for detail",
            isRequired: false
        )
    ])
    
    return steps
}

// MARK: - Helper Functions

extension Array where Element == WalkthroughStep {
    var requiredSteps: [WalkthroughStep] {
        filter { $0.isRequired }
    }
    
    var optionalSteps: [WalkthroughStep] {
        filter { !$0.isRequired }
    }
    
    var requiredCount: Int {
        requiredSteps.count
    }
    
    var totalCount: Int {
        count
    }
}
// MARK: - Walkthrough View

struct BodyScanWalkthroughView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    @Environment(CameraService.self)
    private var cameraService
    
    @State private var currentStepIndex: Int = 0
    @State private var capturedImages: [WalkthroughStep: UIImage] = [:]
    @State private var showCamera: Bool = false
    
    let steps: [WalkthroughStep] = generateFullBodyWalkthrough()
    
    var currentStep: WalkthroughStep {
        steps[currentStepIndex]
    }
    
    var progress: Double {
        Double(currentStepIndex + 1) / Double(steps.count)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: progress)
                    .tint(.orange)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text(currentStep.fullName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        // Camera preview / Captured image
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(height: 400)
                            
                            if let capturedImage = capturedImages[currentStep] {
                                Image(uiImage: capturedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 400)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.green, lineWidth: 3)
                                    )
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Tap to capture")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            showCamera = true
                        }
                        
                        // Instruction
                        VStack(spacing: 8) {
                            Text(currentStep.instruction)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            if let tips = currentStep.tips {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                    
                                    Text(tips)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Navigation buttons
                HStack(spacing: 12) {
                    // Back button
                    if currentStepIndex > 0 {
                        Button {
                            withAnimation {
                                currentStepIndex -= 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    
                    Button {
                        if currentStepIndex < steps.count - 1 {
                            withAnimation {
                                currentStepIndex += 1
                            }
                        } else {
                            finishWalkthrough()
                        }
                    } label: {
                        HStack {
                            Text(currentStepIndex < steps.count - 1 ? "Next" : "Finish")
                            if currentStepIndex < steps.count - 1 {
                                Image(systemName: "chevron.right")
                            } else {
                                Image(systemName: "checkmark")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            capturedImages[currentStep] != nil ? Color.orange : Color.gray
                        )
                        .cornerRadius(12)
                    }
                    .disabled(capturedImages[currentStep] == nil)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .backgroundViewModifier()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if currentStepIndex < steps.count - 1 {
                            withAnimation {
                                currentStepIndex += 1
                            }
                        }
                    } label: {
                        Text("Skip")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            Color.black
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        Spacer()
                        Button("Simulate Capture") {
                            simulateCapture()
                            showCamera = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                )
        }
    }
    
    private func simulateCapture() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        let image = renderer.image { context in
            UIColor.gray.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
        }
        capturedImages[currentStep] = image
    }
    
    private func finishWalkthrough() {
        // Save all captured images to SkinSpotService
        for (step, image) in capturedImages {
            let imageData = image.jpegData(compressionQuality: 0.8)
            
            let photo = SkinSpotPhoto(imageData: imageData, dateTaken: Date())
            let spot = SkinSpot(
                title: "Walkthrough - \(step.fullName)",
                photos: [photo],
                bodyPart: step.bodyPart,
                subPart: step.subPart
            )
            
            skinSpotService.addSkinSpot(spot, to: step.bodyPart, subPart: step.subPart)
        }
        
        dismiss()
    }
}

#Preview {
    BodyScanWalkthroughView()
}
