//
//  BodySelectionActions.swift
//  Sunny
//
//  Created by Josh Bourke on 6/2/2026.
//

import Foundation

enum ScanOption {
    case singleScan
    case walkthroughScan
    case sunscreenScan
}

struct ScanOptionActions: Identifiable, Hashable {
    var id: UUID = UUID()
    var image: String
    var title: String
    var subTitle: String
    var scanOption: ScanOption
}

let scanOptionActions: [ScanOptionActions] = [
    .init(
        image: "photo.fill",
        title: "Single Scan",
        subTitle: "Scan a specific area or spot",
        scanOption: .singleScan
    ),
    .init(
        image: "figure",
        title: "Start a full body scan",
        subTitle: "Systematic scan of all body parts",
        scanOption: .walkthroughScan
    ),
    .init(
        image: "vial.viewfinder",
        title: "Sunscreen Check",
        subTitle: "Take a photo of sunscreen to scan details",
        scanOption: .sunscreenScan
    )
]

struct BodySelectionActions: Identifiable, Hashable {
    var id: UUID = UUID()
    var image: String?
    var title: String
    var bodyPart: BodyPart
}

let bodySelectionActions: [BodySelectionActions] = [
    .init(title: "Head", bodyPart: .head),
    .init(title: "Torso", bodyPart: .torso),
    .init(title: "Left Arm", bodyPart: .leftArm),
    .init(title: "Right Arm", bodyPart: .rightArm),
    .init(title: "Left Leg", bodyPart: .leftLeg),
    .init(title: "Right Leg", bodyPart: .rightLeg)
]

struct SubBodyPartSelectionActions: Identifiable, Hashable {
    var id: UUID = UUID()
    var image: String?
    var title: String
    var subPart: BodySubPart
    var bodyPart: BodyPart
    var orientation: BodyOrientation?
}

// MARK: - Sub-Part Selection Arrays by Body Part

let headSubPartActions: [SubBodyPartSelectionActions] = [
    // Front view
    .init(title: "Face", subPart: .face, bodyPart: .head, orientation: .front),
    .init(title: "Neck", subPart: .neckFront, bodyPart: .head, orientation: .front),
    
    // Back view
    .init(title: "Scalp", subPart: .scalp, bodyPart: .head, orientation: .back),
    .init(title: "Back of Head", subPart: .headBack, bodyPart: .head, orientation: .back),
    .init(title: "Neck", subPart: .neckBack, bodyPart: .head, orientation: .back),
    
    // Ears (front and back)
    .init(title: "Left Ear", subPart: .leftEar, bodyPart: .head, orientation: .front),
    .init(title: "Left Ear", subPart: .leftEar, bodyPart: .head, orientation: .back),
    .init(title: "Right Ear", subPart: .rightEar, bodyPart: .head, orientation: .front),
    .init(title: "Right Ear", subPart: .rightEar, bodyPart: .head, orientation: .back)
]

let armSubPartActions: [SubBodyPartSelectionActions] = [
    // Front view
    .init(title: "Shoulder", subPart: .shoulderFront, bodyPart: .leftArm, orientation: .front),
    .init(title: "Underarm", subPart: .underarm, bodyPart: .leftArm, orientation: .front),
    
    // Back view
    .init(title: "Shoulder", subPart: .shoulderBack, bodyPart: .leftArm, orientation: .back),
    
    // Both views
    .init(title: "Upper Arm", subPart: .armUpper, bodyPart: .leftArm, orientation: nil),
    .init(title: "Forearm", subPart: .armLower, bodyPart: .leftArm, orientation: nil),
    .init(title: "Hand", subPart: .hand, bodyPart: .leftArm, orientation: nil),
    
    // Fingers (visible on both views)
    .init(title: "Thumb", subPart: .thumbFinger, bodyPart: .leftArm, orientation: nil),
    .init(title: "Index Finger", subPart: .indexFinger, bodyPart: .leftArm, orientation: nil),
    .init(title: "Middle Finger", subPart: .middleFinger, bodyPart: .leftArm, orientation: nil),
    .init(title: "Ring Finger", subPart: .ringFinger, bodyPart: .leftArm, orientation: nil),
    .init(title: "Pinky Finger", subPart: .pinkyFinger, bodyPart: .leftArm, orientation: nil)
]

let torsoSubPartActions: [SubBodyPartSelectionActions] = [
    // Front view
    .init(title: "Chest", subPart: .chest, bodyPart: .torso, orientation: .front),
    .init(title: "Abdomen", subPart: .abdomen, bodyPart: .torso, orientation: .front),
    .init(title: "Groin", subPart: .groin, bodyPart: .torso, orientation: .front),
    
    // Back view
    .init(title: "Upper Back", subPart: .backUpper, bodyPart: .torso, orientation: .back),
    .init(title: "Lower Back", subPart: .backLower, bodyPart: .torso, orientation: .back),
    .init(title: "Buttocks", subPart: .buttocks, bodyPart: .torso, orientation: .back)
]

let legSubPartActions: [SubBodyPartSelectionActions] = [
    // Front view
    .init(title: "Thigh", subPart: .legFrontUpper, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Shin", subPart: .legFrontLower, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Foot", subPart: .footTop, bodyPart: .leftLeg, orientation: .front),
    
    // Back view
    .init(title: "Thigh", subPart: .legBackUpper, bodyPart: .leftLeg, orientation: .back),
    .init(title: "Calf", subPart: .legBackLower, bodyPart: .leftLeg, orientation: .back),
    .init(title: "Foot (Heel)", subPart: .footHeel, bodyPart: .leftLeg, orientation: .back),
    .init(title: "Foot (Sole)", subPart: .footSole, bodyPart: .leftLeg, orientation: .back),
    
    // Toes (front view only)
    .init(title: "Big Toe", subPart: .bigToe, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Index Toe", subPart: .indexToe, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Middle Toe", subPart: .middleToe, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Ring Toe", subPart: .ringToe, bodyPart: .leftLeg, orientation: .front),
    .init(title: "Pinky Toe", subPart: .pinkyToe, bodyPart: .leftLeg, orientation: .front)
]

// MARK: - Sub-Part Lookup

func getSubPartActions(for bodyPartAction: BodySelectionActions) -> [SubBodyPartSelectionActions] {
    switch bodyPartAction.bodyPart {
    case .head:
        return headSubPartActions
        
    case .leftArm:
        return armSubPartActions.map { action in
            var updatedAction = action
            updatedAction.bodyPart = .leftArm
            return updatedAction
        }
        
    case .rightArm:
        return armSubPartActions.map { action in
            var updatedAction = action
            updatedAction.bodyPart = .rightArm
            return updatedAction
        }
        
    case .torso:
        return torsoSubPartActions
        
    case .leftLeg:
        return legSubPartActions.map { action in
            var updatedAction = action
            updatedAction.bodyPart = .leftLeg
            return updatedAction
        }
        
    case .rightLeg:
        return legSubPartActions.map { action in
            var updatedAction = action
            updatedAction.bodyPart = .rightLeg
            return updatedAction
        }
    }
}

func getSubPartActions(for bodyPartAction: BodySelectionActions, orientation: BodyOrientation?) -> [SubBodyPartSelectionActions] {
    let allSubParts = getSubPartActions(for: bodyPartAction)
    
    guard let orientation = orientation else {
        return allSubParts
    }
    
    // Filter by orientation (nil orientation means visible in both views)
    return allSubParts.filter { subPart in
        subPart.orientation == orientation || subPart.orientation == nil
    }
}

// MARK: - Display Name

extension SubBodyPartSelectionActions {
    var displayName: String {
        if let orientation = orientation {
            return "\(title) (\(orientation == .front ? "Front" : "Back"))"
        }
        return title
    }
}
