//
//  File.swift
//
//
//  Created by mayong on 2023/2/8.
//

import Foundation
import UserNotifications
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension UNAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        var status: PermissionStatus = .unknown
        switch self {
        case .denied: status = .denied
        case .notDetermined: status = .notDetermined
        case .provisional, .authorized: status = .authorized
        default: status = .unknown
        }
        if #available(iOS 14.0, *), self == .ephemeral {
            status = .authorized
        }
        return status
    }
}

public struct UserNotificationPermission: PermissionCompatiable {
    public var permissionStatus: PermissionStatus {
        fatalError()
    }

    public var infoDescription: String? {
        .permissionInfoDescription(.notification)
    }

    public func permissionStatusWithCallback(_ callback: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            callback(settings.authorizationStatus.permissionStatus)
        })
    }

    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: PermissionStatus = settings.authorizationStatus.permissionStatus
            switch status {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(completionHandler: { authorized, _ in
                    if authorized {
                        callback(true, .authorized)
                    } else {
                        callback(true, .denied)
                    }
                })
            default:
                callback(false, status)
            }
        }
    }
}

extension Permissions {
    public static let notification = Permissions(permission: UserNotificationPermission())
}
