//
//  PermissionAlertControler+Configuration.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import UIKit

public struct PermissionAlertConfiguration {
    public struct Attribute {
        public enum Key {
            case text
            case font
            case foregroundColor
            case backgroundColor
            case cornerRadius
            case borderColor
        }
        
        public let value: Any?
        public let key: Key
        private init(value: Any?, key: Key) {
            self.value = value
            self.key = key
        }
        
        public static func font(_ font: UIFont) -> Attribute {
            Attribute(value: font, key: .font)
        }
        
        public static func text(_ text: String?) -> Attribute {
            Attribute(value: text, key: .text)
        }
        
        public static func foregroundColor(_ color: UIColor?) -> Attribute {
            Attribute(value: color, key: .foregroundColor)
        }
        
        public static func backgroundColor(_ color: UIColor?) -> Attribute {
            Attribute(value: color, key: .backgroundColor)
        }
        
        public static func cornerRadius(_ radius: CGFloat) -> Attribute {
            Attribute(value: radius, key: .cornerRadius)
        }
        
        public static func borderColor(_ color: UIColor) -> Attribute {
            Attribute(value: color, key: .borderColor)
        }
    }
    
    public let statusButtonAttribute: [PermissionStatus: [Attribute]]?
    public let infoAttribute: [Permissions: [Attribute]]?
    public let attribute: [Attribute]?
    public let dismissWhenAllAuthorized: Bool
    public let filterAuthorized: Bool
    public let redirectToSettingsIfDenied: Bool
    
    public static let `default` = PermissionAlertConfiguration(statusButtonAttribute: nil,
                                                               infoAttribute: nil,
                                                               attribute: nil,
                                                               dismissWhenAllAuthorized: true,
                                                               filterAuthorized: true,
                                                               redirectToSettingsIfDenied: true)
}

extension Array where Element == PermissionAlertConfiguration.Attribute {
    public func value<V>(for key: PermissionAlertConfiguration.Attribute.Key) -> V? {
        if let attribute = first(where: { $0.key == key }) {
            return attribute.value as? V
        }
        return nil
    }
}
