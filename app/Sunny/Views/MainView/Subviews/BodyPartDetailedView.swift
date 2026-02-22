//
//  BodyPartDetailView.swift
//  Sunny
//
//  Created by Josh Bourke on 22/1/2026.
//

import SwiftUI

struct BodyPartDetailView: View {
    let bodyPart: BodyPart
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(SkinSpotService.self)
    private var skinSpotService
    
    @Environment(CameraService.self)
    private var cameraService
    
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    
    var skinSpots: [SkinSpot] {
        skinSpotService.getSkinSpots(for: bodyPart)
    }
    
    var status: BodyPartStatus {
        skinSpotService.getStatus(for: bodyPart)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header card with status
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(statusColor.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: statusIcon)
                                .font(.system(size: 40))
                                .foregroundColor(statusColor)
                        }
                        
                        VStack(spacing: 8) {
                            Text(bodyPart.displayName)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            // Status badge
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 8, height: 8)
                                
                                Text(status.scanStatus.rawValue)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(statusColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(statusColor.opacity(0.15))
                            )
                            
                            if let lastScanned = status.lastScanned {
                                Text("Last scanned \(timeAgo(from: lastScanned))")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Add Photo Button
                    Button(action: {
                        HapticManager.shared.medium()
                        if cameraService.isAuthorized {
                            showingCamera = true
                        } else {
                            // Show alert to enable camera
                            cameraService.openAppSettings()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text(skinSpots.isEmpty ? "Add First Photo" : "Add Another Photo")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orange)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Existing photos
                    if !skinSpots.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Photos (\(skinSpots.count))")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(skinSpots) { spot in
                                    SkinSpotCard(spot: spot, bodyPart: bodyPart)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("No photos yet")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Add your first photo to start tracking this area")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraCaptureView(bodyPart: bodyPart)
            }
        }
    }
    
    private var statusColor: Color {
        switch status.scanStatus {
        case .notScanned:
            return .gray
        case .scanned:
            return .green
        case .needsUpdate:
            return .orange
        }
    }
    
    private var statusIcon: String {
        switch status.scanStatus {
        case .notScanned:
            return "camera.badge.ellipsis"
        case .scanned:
            return "checkmark.circle.fill"
        case .needsUpdate:
            return "clock.badge.exclamationmark"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Skin Spot Card

struct SkinSpotCard: View {
    let spot: SkinSpot
    let bodyPart: BodyPart
    
    @Environment(SkinSpotService.self) private var skinSpotService
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                // Spot info
                VStack(alignment: .leading, spacing: 6) {
                    Text(spot.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(spot.photos.count) photo\(spot.photos.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(spot.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            SkinSpotDetailView(spot: spot, bodyPart: bodyPart)
        }
    }
}

// MARK: - Placeholder Camera Capture View

struct CameraCaptureView: View {
    let bodyPart: BodyPart
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SkinSpotService.self) private var skinSpotService
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Camera Capture")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Taking photo for:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(bodyPart.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Demo Photo") {
                    let newSpot = SkinSpot(
                        title: "Spot \(Date().formatted(date: .omitted, time: .shortened))",
                        notes: "Demo spot for \(bodyPart.displayName)",
                        photos: [SkinSpotPhoto()],
                        bodyPart: bodyPart
                    )
                    
                    skinSpotService.addSkinSpot(newSpot, to: bodyPart)
                    HapticManager.shared.success()
                    dismiss()
                }
                .largeButtonViewModifier(bgColor: .orange)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Skin Spot Detail View

struct SkinSpotDetailView: View {
    let spot: SkinSpot
    let bodyPart: BodyPart
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(spot.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Detailed view of this skin spot")
                        .foregroundColor(.secondary)
                    
                    Text("\(spot.photos.count) photo(s)")
                    
                    if let notes = spot.notes {
                        Text(notes)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let fmService = FileManagerService()
    return BodyPartDetailView(bodyPart: .head)
        .environment(SkinSpotService(
            context: PersistenceController.preview.viewContext,
            fileManager: fmService
        ))
        .environment(CameraService())
}
