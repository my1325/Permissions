//
//  File.swift
//
//
//  Created by mayong on 2023/2/8.
//

import AVFoundation
import Foundation
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension AVAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        switch self {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        @unknown default: return .unknown
        }
    }
}

public struct AVDevicePermission: PermissionCompatiable {
    public let type: AVMediaType
    public init(type: AVMediaType) {
        self.type = type
    }

    public var permissionStatus: PermissionStatus {
        AVCaptureDevice.authorizationStatus(for: type).permissionStatus
    }

    public var infoDescription: String? {
        switch type {
        case .audio:
            return .permissionInfoDescription(.microphone)
        case .video:
            return .permissionInfoDescription(.camera)
        default:
            return nil
        }
    }

    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: type, completionHandler: { _ in
                callback(true, self.permissionStatus)
            })
        default:
            callback(false, status)
        }
    }
}

extension Permissions {
    public static let microphone = Permissions(permission: AVDevicePermission(type: .audio))
    
    public static let camera = Permissions(permission: AVDevicePermission(type: .video))
}
