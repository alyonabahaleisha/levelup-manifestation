import SwiftUI
import UIKit
import ImageIO

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        if let asset = NSDataAsset(name: gifName),
           let source = CGImageSourceCreateWithData(asset.data as CFData, nil) {
            let count = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var duration: Double = 0

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                    if let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifProps = props[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                       let delay = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double ?? gifProps[kCGImagePropertyGIFDelayTime as String] as? Double {
                        duration += delay
                    } else {
                        duration += 0.1
                    }
                }
            }

            imageView.animationImages = images
            imageView.animationDuration = duration
            imageView.startAnimating()
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
