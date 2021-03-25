//
//  ThumbnailManager.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/18.
//

import Foundation
import AVKit

class ThumbnailManager {
    var avAsset: AVAsset
    
    internal init(avAsset: AVAsset) {
        self.avAsset = avAsset
        self.generator = AVAssetImageGenerator(asset: self.avAsset)
        
        self.generator.appliesPreferredTrackTransform = true
        self.generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 100)
        self.generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 100)
        self.generator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        
    }
    
    var frames: [UIImage] = []
    var generator: AVAssetImageGenerator! = nil
    
    var isFinished = false
    
    var imageCount = 50
    
    
    
    private func getAllFrames() {
        isFinished = false
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let duration = CMTimeGetSeconds(self.avAsset.duration)
            self.generator = AVAssetImageGenerator(asset: self.avAsset)
            self.generator.appliesPreferredTrackTransform = true
            
            
            self.frames = []
            
            for index in 0 ..< self.imageCount {
                let position = (duration / Double(self.imageCount)) * Double(index)
                
                self.getFrame(fromTime: Float64(position))
                
                print(position)
            }
            self.generator = nil
            self.isFinished = true
        }
        
    }
    
    private func getFrame(fromTime: Float64) {
        let time: CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
        let image: CGImage
        do {
            try image = self.generator.copyCGImage(at:time, actualTime:nil)
        } catch {
            return
        }
        self.frames.append(UIImage(cgImage:image))
    }
    
    
    
//    func getThumnailImage(second time: Double, completion: @escaping (UIImage?) -> ()) {
//        if !isFinished {
//            completion(nil)
//            return
//        }
//
//        let duration = CMTimeGetSeconds(self.avAsset.duration)
//
//        let position = Int(time * Double(imageCount) / duration)
//
//        DispatchQueue.global().async { [weak self] in
//            let image = self?.frames[position]
//
//            DispatchQueue.main.async {
//                completion(image)
//            }
//        }
//    }
//
    
    
    func getThumnailImage(second time: Double, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.generator.cancelAllCGImageGeneration()
            
                        
            do {
                let cgImage = try self.generator.copyCGImage(at: CMTimeMakeWithSeconds(time, preferredTimescale: self.avAsset.duration.timescale), actualTime: nil)
                DispatchQueue.main.async {
                    return completion(UIImage(cgImage: cgImage))
                }
            } catch {
//                print(error.localizedDescription)
                DispatchQueue.main.async {
                    return completion(nil)
                }
            }
        }
    }
    
    
    
}
