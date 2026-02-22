//
//  AIModelService.swift
//  Sunny
//
//  Created by Josh Bourke on 13/2/2026.
//

import Foundation
import MLX
import MLXLLM
import MLXVLM
import MLXLMCommon
import Tokenizers
import Hub
import CoreImage
import SwiftUI

@Observable
class AIModelService {
    
    // MARK: - Properties
    
    var modelState: ModelState = .idle
    var currentOutput: String = ""
    var tokensPerSecond: Double = 0
    
    private var modelContainer: ModelContainer?
    var currentModelInfo: ModelInfo?
    
    private let hub: HubApi
    
    let myHFToken = "<Enter_Your_HF_Token>"
    
    var isVLM: Bool {
        currentModelInfo?.isVLM ?? false
    }
    
    var isModelLoaded: Bool {
        modelContainer != nil && modelState == .ready
    }
    
    let model = ModelInfo(
        id: "mrdbourke/sunny-medgemma-1.5-4b-finetune-mlx-4bit",
        displayName: "MedGemma Skin",
        isVLM: true
    )
    
    private var unloadTask: Task<Void, Never>?
    
    init() {
        // On iOS, use Documents/huggingface
        let downloadBase = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(path: "huggingface")
        
        hub = HubApi(downloadBase: downloadBase, hfToken: myHFToken)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: downloadBase, withIntermediateDirectories: true)
        
        print("Models will be downloaded to: \(downloadBase.path)")
        print("Local repo location: \(hub.localRepoLocation(.init(id: model.id)))")
    }
    
    // MARK: - Load Model (Downloads if needed)
    
    /// Loads the model into memory. Downloads automatically if not already cached.
    func loadModel(_ model: ModelInfo, hubToken: String? = nil) async {
        // Skip if already loaded
        if currentModelInfo == model, modelContainer != nil {
            modelState = .ready
            return
        }
        
        // Unload previous model
        unloadModel()
        currentModelInfo = model
        
        modelState = isModelDownloadedLocally ? .loading : .downloading(progress: 0)
        
        do {
            let configuration = model.configuration
            
            // Choose the correct factory based on model type
            let factory: ModelFactory = model.isVLM
                ? VLMModelFactory.shared
                : LLMModelFactory.shared
            
            let container = try await factory.loadContainer(
                hub: hub,
                configuration: configuration
            ) { [weak self] progress in
                if self?.isModelDownloadedLocally == false {
                    Task { @MainActor in
                        self?.modelState = .downloading(progress: progress.fractionCompleted)
                    }
                }
            }
            
            modelContainer = container
            modelState = .ready
            
            print("Model loaded successfully")
            
        } catch {
            print("Error trying to load model: \(error.localizedDescription)")
            modelState = .failed(error.localizedDescription)
        }
    }
    
    /// Schedule model unload after a delay of inactivity
    func scheduleAutoUnload(after seconds: TimeInterval = 120) {
        // Cancel any existing unload task
        unloadTask?.cancel()
        
        unloadTask = Task {
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if self.modelState == .ready {
                    self.unloadModel()
                    print("Model auto-unloaded after \(seconds)s of inactivity")
                }
            }
        }
    }
    
    /// Cancel any scheduled auto-unload
    func cancelAutoUnload() {
        unloadTask?.cancel()
        unloadTask = nil
    }
    
    /// Releases the model from memory.
    func unloadModel() {
        modelContainer = nil
        currentModelInfo = nil
        currentOutput = ""
        modelState = .idle
        
        MLX.Memory.clearCache()
    }
    
    /// Get the model download size (if available)
    var modelDownloadPath: URL? {
        let repo = Hub.Repo(id: model.id, type: .models)
        return hub.localRepoLocation(repo)
    }
    
    /// Check if model files exist locally
    var isModelDownloadedLocally: Bool {
        guard let localPath = modelDownloadPath else { return false }
        
        // Check if directory exists and contains files
        guard FileManager.default.fileExists(atPath: localPath.path) else {
            return false
        }
        
        // Check for essential files
        let configPath = localPath.appending(path: "config.json")
        let tokenizerPath = localPath.appending(path: "tokenizer.json")
        
        return FileManager.default.fileExists(atPath: configPath.path) &&
               FileManager.default.fileExists(atPath: tokenizerPath.path)
    }
    
    // MARK: - Generate without Chat Session (Stateless)

    /// Stream a response to a text prompt + images WITHOUT using chat session.
    func generateStateless(prompt: String, images: [UIImage]) async throws -> String {
        guard let container = modelContainer else {
            throw ModelServiceError.modelNotLoaded
        }
        guard currentModelInfo?.isVLM == true else {
            throw ModelServiceError.vlmRequired
        }
        
        modelState = .generating
        currentOutput = ""
        
        let vlmImages: [UserInput.Image] = images.compactMap { uiImage in
            guard let ciImage = CIImage(image: uiImage) else { return nil }
            return .ciImage(ciImage)
        }
        
        let userInput = UserInput(prompt: prompt, images: vlmImages, videos: [])
        
        // Prepare the input
        let preparedInput = try await container.prepare(input: userInput)
        
        // Generate parameters
        let parameters = GenerateParameters(
            maxTokens: 2048,
            temperature: 0.5,  // Lower for more focused medical analysis
            topP: 0.95
        )
        
        // Generate response
        let stream = try await container.generate(input: preparedInput, parameters: parameters)
        
        for await generation in stream {
            switch generation {
            case .chunk(let text):
                currentOutput += text
            case .info(let info):
                tokensPerSecond = info.tokensPerSecond
            case .toolCall:
                break
            }
        }
        
        modelState = .ready
        
        return currentOutput
    }
    
    // MARK: - JSON Parsing
    
    private func parseSkinAnalysis(from response: String) throws -> SkinAnalysis {
        var cleanResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanResponse.hasPrefix("```json") {
            cleanResponse = cleanResponse.replacingOccurrences(of: "```json", with: "")
        }
        if cleanResponse.hasPrefix("```") {
            cleanResponse = cleanResponse.replacingOccurrences(of: "```", with: "")
        }
        if cleanResponse.hasSuffix("```") {
            cleanResponse = String(cleanResponse.dropLast(3))
        }
        
        cleanResponse = cleanResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON object in the response
        if let jsonStart = cleanResponse.firstIndex(of: "{"),
           let jsonEnd = cleanResponse.lastIndex(of: "}") {
            cleanResponse = String(cleanResponse[jsonStart...jsonEnd])
        }
        
        guard let data = cleanResponse.data(using: .utf8) else {
            throw ModelServiceError.parseError("Could not convert response to data")
        }
        
        do {
            let decoder = JSONDecoder()
            let analysis = try decoder.decode(SkinAnalysis.self, from: data)
            return analysis
        } catch {
            print("JSON parsing error: \(error)")
            print("Response was: \(cleanResponse)")
            throw ModelServiceError.parseError("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    /// Analyze a skin image and return structured data
    func analyzeSkinImageStructured(
        _ image: UIImage,
        bodyPart: String? = nil,
        imagePath: String
    ) async throws -> SkinLesionRecord {
        let startTime = Date()
    
        let rawResponse = try await generateStateless(prompt: "skin extract", images: [image])
        
        let endTime = Date()
        let latency = String(format: "%.2f", endTime.timeIntervalSince(startTime))
        
        // Parse the JSON response
        let analysis = try parseSkinAnalysis(from: rawResponse)
        
        let record = SkinLesionRecord(
            id: UUID().uuidString,
            imagePath: imagePath,
            timestamp: formatTimestamp(Date()),
            analysis: analysis,
            latency: latency
        )
        
        return record
    }
    
    /// Analyze a single skin image
    func analyzeSkinImage(
        _ image: UIImage,
        bodyPart: String? = nil,
        customPrompt: String? = nil
    ) async throws -> String {
        let defaultPrompt = """
        skin extract
        """
        
        let prompt = customPrompt ?? defaultPrompt
        
        return try await generateStateless(prompt: prompt, images: [image])
    }
}



