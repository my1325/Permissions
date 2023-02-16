//
//  File.swift
//
//
//  Created by mayong on 2023/2/16.
//

import CoreLocation
import Foundation
#if canImport(PermissionsCore)
import PermissionsCore
#endif

extension CLAuthorizationStatus: PermissionStatusCompatible {
    public var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized, .authorizedAlways, .authorizedWhenInUse: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

public final class LocationPermission: NSObject, PermissionCompatiable {
    private lazy var locationManager: CLLocationManager = {
        $0.delegate = self
        return $0
    }(CLLocationManager())

    public var permissionStatus: PermissionStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus.permissionStatus
        } else {
            return CLLocationManager.authorizationStatus().permissionStatus
        }
    }

    public var infoDescription: String? {
        .permissionInfoDescription(.location)
    }

    private var locationAuthorizationCallback: (PermissionStatus) -> Void = { _ in }
    public func requestAuthorizionWithCallback(_ callback: @escaping (Bool, PermissionStatus) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            locationAuthorizationCallback = { callback(true, $0) }
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        default:
            callback(false, status)
        }
    }
}

extension LocationPermission: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationAuthorizationCallback(status.permissionStatus)
        locationAuthorizationCallback = { _ in }
    }
}

extension Permissions {
    public static let location = Permissions(permission: LocationPermission())
}
