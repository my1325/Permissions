//
//  File.swift
//  
//
//  Created by mayong on 2023/2/8.
//

import Foundation
import AppTrackingTransparency
#if canImport(PermissionsCore)
import PermissionsCore
#endif

@available(iOS 14.0, *)
extension ATTrackingManager.AuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

@available(iOS 14.0, *)
public struct AppTrackingPermission: PermissionCompatiable {
    public var permissionStatus: PermissionStatus {
        ATTrackingManager.trackingAuthorizationStatus.permissionStatus
    }
    
    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                callback(true, self.permissionStatus)
            })
        default:
            callback(false, status)
        }
    }
    
    public var infoDescription: String? {
        .permissionInfoDescription(.appTrack)
    }
}

extension Permissions {
    @available(iOS 14.0, *)
    public static let appTrack = Permissions(permission: AppTrackingPermission())
}
