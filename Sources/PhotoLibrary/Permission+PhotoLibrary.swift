//
//  File.swift
//
//
//  Created by mayong on 2023/2/8.
//

import Foundation
import Photos
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension PHAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        var status: PermissionStatus = .unknown
        switch self {
        case .authorized: status = .authorized
        case .notDetermined: status = .notDetermined
        case .denied, .restricted: status = .denied
        default: status = .unknown
        }
        if #available(iOS 14.0, *), self == .limited {
            status = .authorized
        }
        return status
    }
}

public struct PhotoLibraryPermission: PermissionCompatiable {
    public var permissionStatus: PermissionStatus {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite).permissionStatus
        } else {
            return PHPhotoLibrary.authorizationStatus().permissionStatus
        }
    }

    public var infoDescription: String? {
        .permissionInfoDescription(.photoLibrary)
    }

    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            if #available(iOS 14.0, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in
                    callback(true, self.permissionStatus)
                })
            } else {
                PHPhotoLibrary.requestAuthorization { _ in
                    callback(true, self.permissionStatus)
                }
            }
        default: callback(false, status)
        }
    }
}

extension Permissions {
    public static let photoLibrary = Permissions(permission: PhotoLibraryPermission())
}
