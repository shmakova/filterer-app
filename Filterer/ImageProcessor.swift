import UIKit

public class ImageProcessor {
    var image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public func apply(filterName: String) -> UIImage {
        let filter = getFilterByName(filterName)!;
        return apply(filter);
    }
    
    public func apply(filter: Filter) -> UIImage {
        var imageRGBA = RGBAImage(image: image)!
        imageRGBA = applyFilter(imageRGBA, filter: filter);
        return imageRGBA.toUIImage()!;
    }

    public func apply(filterNames: [String]) -> UIImage {
        var imageRGBA = RGBAImage(image: image)!
        
        for filterName in filterNames {
            let filter = getFilterByName(filterName)!;
            imageRGBA = applyFilter(imageRGBA, filter: filter);
        }
        
        return imageRGBA.toUIImage()!;
    }
    
    func applyFilter(var imageRGBA: RGBAImage, filter: Filter?) -> RGBAImage {
        imageRGBA = filter!.apply(imageRGBA);
        return imageRGBA;
    }
    
    func getFilterByName(filterName: String) -> Filter? {
        switch filterName {
            case "Gray Scale":
                return GrayScaleFilter(intensity: 100);
            case "Sepia":
                return SepiaFilter(intensity: 100);
            case "Negative":
                return NegativeFilter(intensity: 100);
            case "Contrast 100%":
                return ContrastFilter(intensity: 100);
            case "Brightness 2x":
                return BrightnessFilter(intensity: 100);
        default: print("Bad filter: ", filterName);
            return nil;
        }
    }
}

public protocol Filter {
    var intensity: Double { get set }
    func apply(imageRGBA: RGBAImage) -> RGBAImage
}

public class CoefFilter: Filter {
    var redCoefs: Array<Double> = [1.0, 1.0, 1.0]
    var greenCoefs: Array<Double> = [1.0, 1.0, 1.0]
    var blueCoefs: Array<Double> = [1.0, 1.0, 1.0]
    var alphaCoef: Double = 1.0
    var intensityLevel: Double = 1.0
    public var intensity: Double {
        get {
            return self.intensityLevel
        }
        set (newIntensity) {
            self.intensityLevel = newIntensity / 100
        }
    }

    
    init(redCoefs: Array<Double>, greenCoefs: Array<Double>, blueCoefs: Array<Double>, alphaCoef: Double, intensity: Double) {
        self.redCoefs = redCoefs
        self.greenCoefs = greenCoefs
        self.blueCoefs = blueCoefs
        self.alphaCoef = alphaCoef
        self.intensity = intensity
    }
    
    init() {}
    
    public func apply(imageRGBA: RGBAImage) -> RGBAImage {
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index = y * imageRGBA.width + x
                var pixel = imageRGBA.pixels[index]
                let red = Double(pixel.red)
                let green = Double(pixel.green)
                let blue = Double(pixel.blue)
                let newRed = red * self.redCoefs[0] + green * self.greenCoefs[0] + blue * self.blueCoefs[0]
                let newGreen = red * self.redCoefs[1] + green * self.greenCoefs[1] + blue * self.blueCoefs[1]
                let newBlue = red * self.redCoefs[2] + green * self.greenCoefs[2] + blue * self.blueCoefs[2]
                pixel.red = UInt8(max(0, min(255, newRed * intensityLevel)))
                pixel.green = UInt8(max(0, min(255, newGreen * intensityLevel)))
                pixel.blue = UInt8(max(0, min(255, newBlue * intensityLevel)))
                pixel.alpha = UInt8(max(0, min(255, self.intensityLevel * Double(pixel.alpha))))
                imageRGBA.pixels[index] = pixel
            }
        }
        
        return imageRGBA
    }
}

public class GrayScaleFilter: CoefFilter {
    init(intensity: Double) {
        super.init(
            redCoefs: [0.2126, 0.2126, 0.2126],
            greenCoefs: [0.7152, 0.7152, 0.7152],
            blueCoefs: [0.0722, 0.0722, 0.0722],
            alphaCoef: 1.0,
            intensity: intensity
        )
    }
}

public class SepiaFilter: CoefFilter {
    init(intensity: Double) {
        super.init(
            redCoefs: [0.393, 0.349, 0.272],
            greenCoefs: [0.769, 0.686, 0.534],
            blueCoefs: [0.189, 0.168, 0.131],
            alphaCoef: 1.0,
            intensity: intensity
        )
    }
}

public class NegativeFilter: Filter {
    var intensityLevel: Double = 1.0
    
    public var intensity: Double {
        get {
            return self.intensityLevel
        }
        set (newIntensity) {
            self.intensityLevel = newIntensity / 100
        }
    }
    
    init(intensity: Double) {
        self.intensity = intensity
    }
    
    public func apply(imageRGBA: RGBAImage) -> RGBAImage {
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index = y * imageRGBA.width + x
                var pixel = imageRGBA.pixels[index]
                pixel.red = 255 - pixel.red
                pixel.green = 255 - pixel.green
                pixel.blue = 255 - pixel.blue
                pixel.red = UInt8(max(0, min(255, Double(pixel.red) * intensityLevel)))
                pixel.green = UInt8(max(0, min(255, Double(pixel.green) * intensityLevel)))
                pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) * intensityLevel)))
                imageRGBA.pixels[index] = pixel
            }
        }
        
        return imageRGBA
    }
}


public class ContrastFilter: Filter {
    var intensityLevel: Double = 128
    
    public var intensity: Double {
        get {
            return self.intensityLevel
        }
        set (newIntensity) {
            self.intensityLevel = (newIntensity - 100) * 1.28
        }
    }
    
    public init(intensity: Double) {
        self.intensity = intensity
    }
    
    public func apply(imageRGBA: RGBAImage) -> RGBAImage {
        var factor: Double
        let factorNumerator = Double(259 * (intensityLevel + 255))
        let factorDenumerator = Double(255 * (259 - intensityLevel))
        factor = factorNumerator / factorDenumerator
        
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index = y * imageRGBA.width + x
                var pixel = imageRGBA.pixels[index]
                let red = Double(pixel.red)
                let green = Double(pixel.green)
                let blue = Double(pixel.blue)
                let newRed = factor * (red - 128) + 128
                let newGreen = factor * (green - 128) + 128
                let newBlue = factor * (blue - 128) + 128
                pixel.red = UInt8(max(0, min(255, newRed)))
                pixel.green = UInt8(max(0, min(255, newGreen)))
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                imageRGBA.pixels[index] = pixel
            }
        }
        
        return imageRGBA
    }
}

public class BrightnessFilter: Filter {
    var intensityLevel: Double = 1.0
    
    public var intensity: Double {
        get {
            return self.intensityLevel
        }
        set (newIntensity) {
            self.intensityLevel = (newIntensity + 100) / 100
        }
    }
    
    public init(intensity: Double) {
        self.intensity = intensity
    }
    
    public func apply(imageRGBA: RGBAImage) -> RGBAImage {
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index = y * imageRGBA.width + x
                var pixel = imageRGBA.pixels[index]
                let red = Double(pixel.red)
                let green = Double(pixel.green)
                let blue = Double(pixel.blue)
                let newRed = red * intensityLevel
                let newGreen = green * intensityLevel
                let newBlue = blue * intensityLevel
                pixel.red = UInt8(max(0, min(255, newRed)))
                pixel.green = UInt8(max(0, min(255, newGreen)))
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                imageRGBA.pixels[index] = pixel
            }
        }
        
        return imageRGBA
    }
}
