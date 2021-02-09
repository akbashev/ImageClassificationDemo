//
//  CategoriseService.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import CoreML
import Vision
import Combine
import Foundation

#if !os(macOS)
import UIKit.UIImage
import UIKit.UIColor
#else
import AppKit.NSImage
/// Alias for `NSImage`.
// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(named name: String) {
        self.init(named: Name(name))
    }
}
#endif

class CategoriseService {
    
    let model: VNCoreMLModel
    private let q = DispatchQueue(label: "ClassificationProccessQueue")

    init() {
        self.model = try! VNCoreMLModel(for: ImageClassificationDemo_1().model)
    }
    
    
    func categorise(_ unsplashImages: [UnsplashImage]) -> AnyPublisher<[String:String], Never> {
        let pipeline = Publishers.MergeMany(
            unsplashImages.map { image in
                self.categorise(image)
            }).collect()
            .map {
                return $0.reduce([String:String]()) { dict, value in
                    var dict = dict
                    dict[value.0] = value.1
                    return dict
                }
            }
            .eraseToAnyPublisher()
        return pipeline
    }
    
    
    func categorise(_ unsplashImage: UnsplashImage) -> AnyPublisher<(String, String), Never> {
        let pipeline = self.fetch(unsplashImage)
            .flatMap { self.createRequest(model: self.model, image: $0, id: unsplashImage.id)}
            .replaceError(with: ("", ""))
            .eraseToAnyPublisher()
        return pipeline
    }
    
    private func fetch(_ unsplashImage: UnsplashImage) -> AnyPublisher<UIImage, Never> {
        return URLSession.shared.dataTaskPublisher(for: unsplashImage.urls!.thumb!)
            .map { UIImage(data: $0.data)! }
            .replaceError(with: UIImage() )
            .eraseToAnyPublisher()
    }
    
    private func createRequest(model: VNCoreMLModel, image: UIImage, id: String) -> AnyPublisher<(String, String), Never> {
        guard let cgImage = image.cgImage else { return Empty().eraseToAnyPublisher() }
        return Future<(String, String), Error> { promise in
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                guard let results = request.results else { promise(.failure("No result")); return }
                
                let classifications = results as! [VNClassificationObservation]
                
                guard !classifications.isEmpty else { promise(.failure("No result")); return }
                
                if let topClassification = classifications
                    .filter({ $0.identifier == "Cat" || $0.identifier == "Dog" })
                    .filter({ $0.confidence > 0.9 })
                    .sorted( by: { $0.confidence > $1.confidence }).first {
                    promise(.success((id, topClassification.identifier)))
                } else {
                    promise(.failure("No result")); return
                }
            })
            request.imageCropAndScaleOption = .centerCrop
            self.q.async {
                let handler = VNImageRequestHandler(cgImage: cgImage)
                do {
                    try handler.perform([request])
                } catch {
                    promise(.failure("No result"))
                }
            }
        }
        .replaceError(with: ("", ""))
        .eraseToAnyPublisher()
    }
}

extension String: Error {}
