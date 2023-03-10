//
//  File.swift
//
//
//  Created by mayong on 2023/2/8.
//

import Foundation

public enum PermissionType {
    case appTrack
    case microphone
    case camera
    case notification
    case photoLibrary
    case location
    case contact
    case event
    case reminder
}

public extension String {
   static func permissionInfoDescription(_ type: PermissionType) -> String? {
        let info = Bundle.main.infoDictionary
        switch type {
        case .appTrack:
            return info?["NSUserTrackingUsageDescription"] as? String
        case .microphone:
            return info?["NSMicrophoneUsageDescription"] as? String
        case .camera:
            return info?["NSCameraUsageDescription"] as? String
        case .notification:
            return ""
        case .photoLibrary:
            var description = info?["NSPhotoLibraryUsageDescription"] as? String
            if description == nil {
                description = info?["NSPhotoLibraryAddUsageDescription"] as? String
            }
            return description
        case .location:
            var description = info?["NSLocationAlwaysAndWhenInUseUsageDescription"] as? String
            if description == nil {
                description = info?["NSLocationWhenInUseUsageDescription"] as? String
            }
            if description == nil {
                description = info?["NSLocationAlwaysUsageDescription"] as? String
            }
            return description
        case .contact:
            return info?["NSContactsUsageDescription"] as? String
        case .event, .reminder:
            return info?["NSCalendarsUsageDescription"] as? String
        }
    }
}
