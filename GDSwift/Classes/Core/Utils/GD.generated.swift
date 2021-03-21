//
//  GD.generated.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.

import UIKit

public class GD {
    fileprivate class Class {}
    
    public static let hostingBundle = Bundle(for: GD.Class.self)
    
    static let IPhoneX = {
        return isIPhoneXSeries()
    }()
    
    static let ScreenWidth = UIScreen.main.bounds.width;
    static let ScreenHeight = UIScreen.main.bounds.height;
    
    ///状态栏高度
    static let StateBarHeight: CGFloat = {
        return UIApplication.shared.statusBarFrame.height
    }()

    ///导航栏高度
    static let NavBarRealHeight: CGFloat = 44.0

    ///标准Tabbar的高度
    static fileprivate let StantardTabbarH: CGFloat =  49.0

    ///NavigationBar 的高度
    static let NavigationBarHeight: CGFloat = {
        return (IPhoneX ? NavBarRealHeight * 2.0 : StateBarHeight + NavBarRealHeight)
    }()
    
    ///Tabbar的高度
    static let TabbarHeight: CGFloat = {
        return (IPhoneX ? (StantardTabbarH + safeAreaInsets.bottom) : StantardTabbarH)
    }()
    
    static var safeAreaInsets: UIEdgeInsets = {
        guard let window = UIApplication.shared.keyWindow else {
            return .zero
        }
        
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            // Fallback on earlier versions
            return .zero
        }
    }()
    
    class public func g(_ closure:@escaping () -> Void) {
        DispatchQueue.global().async {
            closure()
        }
    }

    class public func  m(_ closure:@escaping () -> Void) {
        let thread = Thread.current
        if thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: {
                closure()
            })
        }
    }

    class public func delayG(_ interval: TimeInterval, action:@escaping () -> Void) {
        let when = DispatchTime.now() + interval
        DispatchQueue.global().asyncAfter(deadline: when, execute: action)
    }

    class public func delayM(_ interval: TimeInterval, closure:@escaping () -> Void) {
        let when = DispatchTime.now() + interval
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    fileprivate static func isIPhoneXSeries() -> Bool {
        if (UIDevice.current.userInterfaceIdiom != .phone ) {
            return false
        }
        return (safeAreaInsets.bottom > 0);
    }
}

extension GD {
    public class func convertToSnakeCase(_ key: String) -> String {
        convert(key, usingSeparator: "_")
    }

    public class func convertToKebabCase(_ key: String) -> String {
        convert(key, usingSeparator: "-")
    }

    public class func convert(_ key: String, usingSeparator separator: String) -> String {
        guard !key.isEmpty else { return key }

        var words: [Range<String.Index>] = []
        // The general idea of this algorithm is to split words on
        // transition from lower to upper case, then on transition of >1
        // upper case characters to lowercase
        //
        // myProperty -> my_property
        // myURLProperty -> my_url_property
        //
        // It is assumed, per Swift naming conventions, that the first character of the key is lowercase.
        var wordStart = key.startIndex
        var searchRange = key.index(after: wordStart)..<key.endIndex

        // Find next uppercase character
        while let upperCaseRange = key.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            // Find next lowercase character
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            guard let lowerCaseRange = key.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                // There are no more lower case letters. Just end here.
                wordStart = searchRange.lowerBound
                break
            }

            // Is the next lowercase letter more than 1 after the uppercase?
            // If so, we encountered a group of uppercase letters that we
            // should treat as its own word
            let nextCharacterAfterCapital = key.index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                // The next character after capital is a lower case character and therefore not a word boundary.
                // Continue searching for the next upper case for the boundary.
                wordStart = upperCaseRange.lowerBound
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                let beforeLowerIndex = key.index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                // Next word starts at the capital before the lowercase we just found
                wordStart = beforeLowerIndex
            }
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        words.append(wordStart..<searchRange.upperBound)
        let result = words.map { range in
            key[range].lowercased()
        }.joined(separator: separator)

        return result
    }
}
