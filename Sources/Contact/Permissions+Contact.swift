//
//  File.swift
//
//
//  Created by mayong on 2023/2/16.
//

import Contacts
import Foundation
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension CNAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        switch self {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        @unknown default: return .unknown
        }
    }
}

public struct ContactsPermission: PermissionCompatiable {
    public var infoDescription: String? {
        .permissionInfoDescription(.contact)
    }
    
    public var permissionStatus: PermissionStatus {
        CNContactStore.authorizationStatus(for: .contacts).permissionStatus
    }

    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts, completionHandler: { _, _ in
                callback(true, self.permissionStatus)
            })
        default:
            callback(false, status)
        }
    }
}

extension Permissions {
    public static let contact = Permissions(permission: ContactsPermission())
}
