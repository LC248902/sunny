//
//  BodyPartUtilities.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import Foundation

// MARK: - Body Orientation

enum BodyOrientation: String, Codable {
    case front
    case back
}

// MARK: - Body Part

enum BodyPart: String, CaseIterable, Codable, Identifiable {
    
    case head = "Head"
    case leftLeg = "LeftLeg"
    case rightLeg = "RightLeg"
    case rightArm = "RightArm"
    case leftArm = "LeftArm"
    case torso = "Torso"
    
    var displayName: String {
        switch self {
        case .head:
            "Head"
        case .leftLeg:
            "Left Leg"
        case .rightLeg:
            "Right Leg"
        case .rightArm:
            "Right Arm"
        case .leftArm:
            "Left Arm"
        case .torso:
            "Torso"
        }
    }
    
    var id: Self {
        self
    }

    var previewTags: [String] {
        switch self {
        case .head:
            return ["Face", "Neck", "Scalp", "Ears"]
        case .torso:
            return ["Chest", "Abdomen", "Back", "Buttocks"]
        case .leftArm, .rightArm:
            return ["Shoulder", "Forearm", "Hand", "Fingers"]
        case .leftLeg, .rightLeg:
            return ["Thigh", "Shin", "Calf", "Foot"]
        }
    }
    
    var subParts: [BodySubPart] {
        switch self {
        case .head:
            return BodySubPart.headParts
        case .leftLeg:
            return BodySubPart.legParts
        case .rightLeg:
            return BodySubPart.legParts
        case .rightArm:
            return BodySubPart.armParts
        case .leftArm:
            return BodySubPart.armParts
        case .torso:
            return BodySubPart.torsoParts
        }
    }
}

// MARK: - Body Sub-Part (Detailed breakdown)

enum BodySubPart: String, CaseIterable, Codable, Identifiable {
    
    // Head sub-parts (9 total)
    case scalp = "Scalp"
    case headBack = "HeadBack"
    case face = "Face"
    case leftEar = "LeftEar"
    case rightEar = "RightEar"
    case neckFront = "NeckFront"
    case neckBack = "NeckBack"
    
    // Arm sub-parts (8 per arm, hand/fingers separate)
    case shoulderFront = "ShoulderFront"
    case shoulderBack = "ShoulderBack"
    case underarm = "Underarm"
    case armUpper = "ArmUpper"
    case armLower = "ArmLower"
    case hand = "Hand"
    
    // Fingers (5 per hand - shared between left/right)
    case thumbFinger = "ThumbFinger"
    case indexFinger = "IndexFinger"
    case middleFinger = "MiddleFinger"
    case ringFinger = "RingFinger"
    case pinkyFinger = "PinkyFinger"
    
    // Torso sub-parts (6 total)
    case chest = "Chest"
    case abdomen = "Abdomen"
    case groin = "Groin"
    case backUpper = "BackUpper"
    case backLower = "BackLower"
    case buttocks = "Buttocks"
    
    // Leg sub-parts (5 per leg, foot/toes separate)
    case legFrontUpper = "LegFrontUpper"
    case legFrontLower = "LegFrontLower"
    case legBackUpper = "LegBackUpper"
    case legBackLower = "LegBackLower"
    case footTop = "FootTop"
    case footHeel = "FootHeel"
    case footSole = "FootSole"
    
    // Toes (5 per foot - shared between left/right)
    case bigToe = "BigToe"
    case indexToe = "IndexToe"
    case middleToe = "MiddleToe"
    case ringToe = "RingToe"
    case pinkyToe = "PinkyToe"
    
    var displayName: String {
        switch self {
        // Head
        case .scalp: "Scalp"
        case .headBack: "Back of Head"
        case .face: "Face"
        case .leftEar: "Left Ear"
        case .rightEar: "Right Ear"
        case .neckFront: "Neck (Front)"
        case .neckBack: "Neck (Back)"
            
        // Arms
        case .shoulderFront: "Shoulder (Front)"
        case .shoulderBack: "Shoulder (Back)"
        case .underarm: "Underarm"
        case .armUpper: "Upper Arm"
        case .armLower: "Forearm"
        case .hand: "Hand"
            
        // Fingers
        case .thumbFinger: "Thumb"
        case .indexFinger: "Index Finger"
        case .middleFinger: "Middle Finger"
        case .ringFinger: "Ring Finger"
        case .pinkyFinger: "Pinky Finger"
            
        // Torso
        case .chest: "Chest"
        case .abdomen: "Abdomen"
        case .groin: "Groin"
        case .backUpper: "Upper Back"
        case .backLower: "Lower Back"
        case .buttocks: "Buttocks"
            
        // Legs
        case .legFrontUpper: "Thigh (Front)"
        case .legFrontLower: "Shin (Front)"
        case .legBackUpper: "Thigh (Back)"
        case .legBackLower: "Calf (Back)"
        case .footTop: "Foot (Top)"
        case .footHeel: "Foot (Heel)"
        case .footSole: "Foot (Sole)"
            
        // Toes
        case .bigToe: "Big Toe"
        case .indexToe: "Index Toe"
        case .middleToe: "Middle Toe"
        case .ringToe: "Ring Toe"
        case .pinkyToe: "Pinky Toe"
        }
    }
    
    var id: Self {
        self
    }
    
    func svgId(for bodyPart: BodyPart, orientation: BodyOrientation) -> String? {
        switch (self, bodyPart, orientation) {
        // Head parts
        case (.scalp, .head, .back):
            return "scalp"
        case (.headBack, .head, .back):
            return "head-back"
        case (.face, .head, .front):
            return "face"
        case (.leftEar, .head, .front):
            return "ear-left-front"
        case (.leftEar, .head, .back):
            return "ear-left-back"
        case (.rightEar, .head, .front):
            return "ear-right-front"
        case (.rightEar, .head, .back):
            return "ear-right-back"
        case (.neckFront, .head, .front):
            return "neck-front"
        case (.neckBack, .head, .back):
            return "neck-back"
            
        // Right Arm parts (Front)
        case (.shoulderFront, .rightArm, .front):
            return "shoulder-right-front"
        case (.armUpper, .rightArm, .front):
            return "arm-right-upper"
        case (.armLower, .rightArm, .front):
            return "arm-right-lower"
        case (.hand, .rightArm, .front):
            return "hand-right"
            // Right Arm underarm (front view only)
        case (.underarm, .rightArm, .front):
            return "underarm-right"
            
        // Right Arm parts (Back)
        case (.shoulderBack, .rightArm, .back):
            return "shoulder-right-back"
        case (.armUpper, .rightArm, .back):
            return "arm-right-upper"
        case (.armLower, .rightArm, .back):
            return "arm-right-lower"
        case (.hand, .rightArm, .back):
            return "hand-right"
            
        // Right Arm fingers (both orientations)
        case (.thumbFinger, .rightArm, _):
            return "thumb-finger-right"
        case (.indexFinger, .rightArm, _):
            return "index-finger-right"
        case (.middleFinger, .rightArm, _):
            return "middle-finger-right"
        case (.ringFinger, .rightArm, _):
            return "ring-finger-right"
        case (.pinkyFinger, .rightArm, _):
            return "pinky-finger-right"
            
        // Left Arm parts (Front)
        case (.shoulderFront, .leftArm, .front):
            return "shoulder-left-front"
        case (.armUpper, .leftArm, .front):
            return "arm-left-upper"
        case (.armLower, .leftArm, .front):
            return "arm-left-lower"
        case (.hand, .leftArm, .front):
            return "hand-left"
            // Left Arm underarm (front view only)
        case (.underarm, .leftArm, .front):
            return "underarm-left"

        // Left Arm parts (Back)
        case (.shoulderBack, .leftArm, .back):
            return "shoulder-left-back"
        case (.armUpper, .leftArm, .back):
            return "arm-left-upper"
        case (.armLower, .leftArm, .back):
            return "arm-left-lower"
        case (.hand, .leftArm, .back):
            return "hand-left"
            
        // Left Arm fingers (both orientations)
        case (.thumbFinger, .leftArm, _):
            return "thumb-finger-left"
        case (.indexFinger, .leftArm, _):
            return "index-finger-left"
        case (.middleFinger, .leftArm, _):
            return "middle-finger-left"
        case (.ringFinger, .leftArm, _):
            return "ring-finger-left"
        case (.pinkyFinger, .leftArm, _):
            return "pinky-finger-left"
            
        // Torso parts (Front)
        case (.chest, .torso, .front):
            return "chest"
        case (.abdomen, .torso, .front):
            return "abdomen"
        case (.groin, .torso, .front):
            return "groin"
            
        // Torso parts (Back)
        case (.backUpper, .torso, .back):
            return "back-upper"
        case (.backLower, .torso, .back):
            return "back-lower"
        case (.buttocks, .torso, .back):
            return "buttocks"
            
        // Right Leg parts (Front)
        case (.legFrontUpper, .rightLeg, .front):
            return "leg-right-front-upper"
        case (.legFrontLower, .rightLeg, .front):
            return "leg-right-front-lower"
        case (.footTop, .rightLeg, .front):
            return "foot-right-top"
            
        // Right Leg parts (Back)
        case (.legBackUpper, .rightLeg, .back):
            return "leg-right-back-upper"
        case (.legBackLower, .rightLeg, .back):
            return "leg-right-back-lower"
        case (.footHeel, .rightLeg, .back):
            return "foot-right-heel"
        case (.footSole, .rightLeg, .back):
            return "foot-right-sole"
            
        // Right Leg toes (Front only)
        case (.bigToe, .rightLeg, .front):
            return "big-toe-right"
        case (.indexToe, .rightLeg, .front):
            return "index-toe-right"
        case (.middleToe, .rightLeg, .front):
            return "middle-toe-right"
        case (.ringToe, .rightLeg, .front):
            return "ring-toe-right"
        case (.pinkyToe, .rightLeg, .front):
            return "pinky-toe-right"
            
        // Left Leg parts (Front)
        case (.legFrontUpper, .leftLeg, .front):
            return "leg-left-front-upper"
        case (.legFrontLower, .leftLeg, .front):
            return "leg-left-front-lower"
        case (.footTop, .leftLeg, .front):
            return "foot-left-top"
            
        // Left Leg parts (Back)
        case (.legBackUpper, .leftLeg, .back):
            return "leg-left-back-upper"
        case (.legBackLower, .leftLeg, .back):
            return "leg-left-back-lower"
        case (.footHeel, .leftLeg, .back):
            return "foot-left-heel"
        case (.footSole, .leftLeg, .back):
            return "foot-left-sole"
            
        // Left Leg toes (Front only)
        case (.bigToe, .leftLeg, .front):
            return "big-toe-left"
        case (.indexToe, .leftLeg, .front):
            return "index-toe-left"
        case (.middleToe, .leftLeg, .front):
            return "middle-toe-left"
        case (.ringToe, .leftLeg, .front):
            return "ring-toe-left"
        case (.pinkyToe, .leftLeg, .front):
            return "pinky-toe-left"
            
        default:
            return nil
        }
    }
    
    // Static arrays for filtering
    static var headParts: [BodySubPart] {
        [.scalp, .headBack, .face, .leftEar, .rightEar, .neckFront, .neckBack]
    }
    
    static var armParts: [BodySubPart] {
        [.shoulderFront, .shoulderBack, .underarm, .armUpper, .armLower, .hand,
         .thumbFinger, .indexFinger, .middleFinger, .ringFinger, .pinkyFinger]
    }
    
    static var torsoParts: [BodySubPart] {
        [.chest, .abdomen, .groin, .backUpper, .backLower, .buttocks]
    }
    
    static var legParts: [BodySubPart] {
        [.legFrontUpper, .legFrontLower, .legBackUpper, .legBackLower,
         .footTop, .footHeel, .footSole,
         .bigToe, .indexToe, .middleToe, .ringToe, .pinkyToe]
    }
}

// MARK: - Scan Status

enum ScanStatus: String, Codable {
    case notScanned = "Not Scanned"
    case scanned = "Scanned"
    case needsUpdate = "Needs Update"
    
    var color: String {
        switch self {
        case .notScanned:
            return "gray"
        case .scanned:
            return "green"
        case .needsUpdate:
            return "orange"
        }
    }
}

// MARK: - Body Part Status

struct BodyPartStatus {
    var bodyPart: BodyPart
    var subPart: BodySubPart?
    var scanStatus: ScanStatus
    var photoCount: Int
    var lastScanned: Date?
    
    init(
        bodyPart: BodyPart,
        subPart: BodySubPart? = nil,
        scanStatus: ScanStatus = .notScanned,
        photoCount: Int = 0,
        lastScanned: Date? = nil
    ) {
        self.bodyPart = bodyPart
        self.subPart = subPart
        self.scanStatus = scanStatus
        self.photoCount = photoCount
        self.lastScanned = lastScanned
    }
    
    var fullDisplayName: String {
        if let subPart = subPart {
            return "\(bodyPart.displayName) - \(subPart.displayName)"
        }
        return bodyPart.displayName
    }
}



