import SwiftUI

enum AppTypography {
    // Display
    static let displayLarge = Font.custom("PlayfairDisplay-Regular", size: 52)
    static let displayMedium = Font.custom("PlayfairDisplay-Regular", size: 36)
    
    // Heading
    static let headingLarge = Font.custom("PlayfairDisplay-Regular", size: 28)
    static let headingMedium = Font.custom("PlayfairDisplay-Regular", size: 22)
    static let headingSmall = Font.custom("PlayfairDisplay-Medium", size: 18)
    
    // Body
    static let bodyLarge = Font.custom("Manrope-Light", size: 16)
    static let bodyMedium = Font.custom("Manrope-Light", size: 14)
    static let bodySmall = Font.custom("Manrope-Light", size: 13)
    
    // Label
    static let labelLarge = Font.custom("Manrope-Medium", size: 14)
    static let labelMedium = Font.custom("Manrope-Medium", size: 13)
    static let labelSmall = Font.custom("Manrope-SemiBold", size: 11)
    
    // Caption
    static let caption = Font.custom("Manrope-Regular", size: 12)
    
    // Tab
    static let tabLabel = Font.custom("Manrope-Medium", size: 10)
}
