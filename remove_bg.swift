import Cocoa
import Vision
import CoreImage

guard CommandLine.arguments.count == 3 else {
    print("Usage: \(CommandLine.arguments[0]) <input> <output>")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

guard let image = NSImage(contentsOfFile: inputPath),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to load image.")
    exit(1)
}

if #available(macOS 14.0, *) {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first else {
                print("No mask generated.")
                exit(1)
            }
            
            // Generate masked image directly using the built-in Vision API with cropping enabled
            let maskedBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: true
            )
            
            let ciImage = CIImage(cvPixelBuffer: maskedBuffer)
            let context = CIContext()
            guard let outputCG = context.createCGImage(ciImage, from: ciImage.extent) else {
                print("Failed to create CGImage.")
                exit(1)
            }
            
            let outImage = NSImage(cgImage: outputCG, size: NSSize(width: outputCG.width, height: outputCG.height))
            
            guard let tiffData = outImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                print("Failed to create PNG.")
                exit(1)
            }
            
            try pngData.write(to: URL(fileURLWithPath: outputPath))
            print("Success: \(outputPath)")
        
    } catch {
        print("Error: \(error)")
        exit(1)
    }
} else {
    print("Requires macOS 14.0 or newer.")
    exit(1)
}
