import UIKit
import SwiftUI

func registerCustomFont(from fileName: String, withExtension fileExtension: String) {
    guard let fontURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
        print("Failed to locate font files")
        return
    }
    
    guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
        print("Failed to create font data provider")
        return
    }
    
    guard let font = CGFont(fontDataProvider) else {
        print("Failed to create font")
        return
    }
    
    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterGraphicsFont(font, &error) {
        print("Failed to register font: \(String(describing: error?.takeRetainedValue()))")
    } else {
        print("Font \(fileName).\(fileExtension) has been successfully registered!")
    }
}

let fontsToLoad = ["ChakraPetch-Bold",
                   "ChakraPetch-BoldItalic",
                   "ChakraPetch-Italic",
                   "ChakraPetch-Light",
                   "ChakraPetch-LightItalic",
                   "ChakraPetch-Medium",
                   "ChakraPetch-MediumItalic",
                   "ChakraPetch-Regular",
                   "ChakraPetch-SemiBold",
                   "ChakraPetch-SemiBoldItalic",
                   "CrimsonPro-Italic-VariableFont_wght",
                   "CrimsonPro-VariableFont_wght",
                   "Doto-VariableFont_ROND,wght",
                   "London Underground LCD Clock",
                   "PlayfairDisplay-Italic-VariableFont_wght",
                   "PlayfairDisplay-VariableFont_wght",
                   "PlaywriteAUSA-VariableFont_wght",
                   "PublicSans-Italic-VariableFont_wght",
                   "PublicSans-VariableFont_wght",
                   "ShareTechMono-Regular",
                   "SpaceGrotesk-VariableFont_wght"]

@MainActor
class FontManager {
    static let shared = FontManager()
    
    private init() {
        for item in fontsToLoad {
            registerCustomFont(from: item, withExtension: "ttf")
        }
    }
}
