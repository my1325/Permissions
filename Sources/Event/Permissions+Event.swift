//
//  File.swift
//
//
//  Created by mayong on 2023/2/16.
//

import EventKit
import Foundation
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension EKAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

public struct EventPermission: PermissionCompatiable {
    let eventStore: EKEventStore = .init()
    public let type: EKEntityType
    public init(type: EKEntityType) {
        self.type = type
    }
    
    public var permissionStatus: PermissionStatus {
        EKEventStore.authorizationStatus(for: type).permissionStatus
    }
    
    public var infoDescription: String? {
        switch type {
        case .reminder:
            return .permissionInfoDescription(.reminder)
        case .event:
            return .permissionInfoDescription(.event)
        @unknown default:
            return ""
        }
    }
    
    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            eventStore.requestAccess(to: type, completion: { _, _ in
                callback(true, self.permissionStatus)
            })
        default:
            callback(false, status)
        }
    }
}

extension Permissions {
    public static let event = Permissions(permission: EventPermission(type: .event))
    
    public static let reminder = Permissions(permission: EventPermission(type: .reminder))
}
