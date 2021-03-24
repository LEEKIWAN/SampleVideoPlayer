//
//  AVAsset+.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/18.
//

import Foundation
import AVKit


extension AVAsset {
    func getThumnailImage(position time: Double, completion: @escaping (UIImage?) -> ()) {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let imageGenerator = AVAssetImageGenerator(asset: self)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 100)
            imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 100)
            imageGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            imageGenerator.cancelAllCGImageGeneration()
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(time, preferredTimescale: self.duration.timescale), actualTime: nil)
                DispatchQueue.main.async {
                    return completion(UIImage(cgImage: cgImage))
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    return completion(nil)
                }
            }
        }
    }
  
}
