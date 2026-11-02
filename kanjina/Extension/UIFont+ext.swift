//
//  UIFont+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/11/26.
//

import UIKit

extension UIFont {
    enum ShoraiSansWeight: String {
        private var familyName: String { "ShoraiSansStdNVar" }
        
        case regular
        case thin
        case light
        case medium
        case demi
        case bold
        case extraBold
        case black
        case heavy
        
        var fontName: String {
            switch self {
            case .regular: return familyName + "_Refular"
            case .thin: return familyName + "_Thin"
            case .light: return familyName + "_Light"
            case .medium: return familyName + "_Medium"
            case .demi: return familyName + "_Demi"
            case .bold: return familyName + "_Bold"
            case .extraBold: return familyName + "_ExtraBold"
            case .black: return familyName + "_Black"
            case .heavy: return familyName + "_Heavy"
            }
        }
    }
    
    static func shoraiSans(size: CGFloat, weight: ShoraiSansWeight) -> UIFont {
        return UIFont.init(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
    }

}
