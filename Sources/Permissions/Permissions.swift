//
//  PermissionCompatible.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import AppTrackingTransparency
import Contacts
import CoreLocation
import EventKit
import Foundation
import Photos
import UserNotifications
import UIKit

public enum PermissionStatus {
    case unknown
    case authorized
    case denied
    case notDetermined
}

protocol PermissionStatusCompatible {
    var permissionStatus: PermissionStatus { get }
}

extension CLAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized, .authorizedAlways, .authorizedWhenInUse: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

extension PHAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
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

extension CNAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
        switch self {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        @unknown default: return .unknown
        }
    }
}

extension AVAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
        switch self {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        @unknown default: return .unknown
        }
    }
}

@available(iOS 14.0, *)
extension ATTrackingManager.AuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

extension EKAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
        switch self {
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
}

extension UNAuthorizationStatus: PermissionStatusCompatible {
    var permissionStatus: PermissionStatus {
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

public enum Permissions {
    case location
    case contact
    case photoLibrary
    case camera
    case microphone
    case calendarEvent
    case calendarReminder
    case notification

    @available(iOS 14.0, *)
    case appTracking
}

public extension Permissions {
    var infoDescription: String? {
        let info = Bundle.main.infoDictionary
        if #available(iOS 14.0, *), self == .appTracking {
            return info?["NSUserTrackingUsageDescription"] as? String
        }

        switch self {
        case .camera: return info?["NSCameraUsageDescription"] as? String
        case .microphone: return info?["NSMicrophoneUsageDescription"] as? String
        case .contact: return info?["NSContactsUsageDescription"] as? String
        case .calendarEvent: return info?["NSCalendarsUsageDescription"] as? String
        case .calendarReminder: return info?["NSCalendarsUsageDescription"] as? String
        case .location:
            var description = info?["NSLocationWhenInUseUsageDescription"] as? String
            if description == nil {
                description = info?["NSLocationAlwaysAndWhenInUseUsageDescription"] as? String
            }
            return description
        case .photoLibrary:
            var description = info?["NSPhotoLibraryUsageDescription"] as? String
            if description == nil {
                description = info?["NSPhotoLibraryAddUsageDescription"] as? String
            }
            return description
        default: return " "
        }
    }

    var permissionStatus: PermissionStatus {
        if #available(iOS 14.0, *), self == .appTracking {
            return appTrackingPermission()
        }

        switch self {
        case .location: return locationPermission()
        case .camera: return AVDeviceCapturePermission(.video)
        case .microphone: return AVDeviceCapturePermission(.audio)
        case .photoLibrary: return photoPermission()
        case .contact: return contactsPersmission()
        case .calendarEvent: return calendarPermission(.event)
        case .calendarReminder: return calendarPermission(.reminder)
        case .notification: fatalError("notification permission please use permissionStatusWithCallback(_:) instead")
        default: return .unknown
        }
    }

    func permissionStatusWithCallback(_ callback: @escaping (PermissionStatus) -> Void) {
        switch self {
        case .notification: notificationPermission(callback)
        default:
            callback(permissionStatus)
        }
    }

    func requestAuthorizionWithCallback(_ from: UIViewController? = nil,
                                        shouldRedirectToSettingsWhenNotDeterminedStatus redirectToSettingsIfNotDetermined: Bool = false,
                                        redirectToSettingsIfDenied redirectToSettings: Bool = true,
                                        callback: @escaping (PermissionStatus) -> Void) {
        let _callBack: (Bool, URL?, PermissionStatus) -> Void = { isNotDetermined, URL, status in
            DispatchQueue.main.async {
                if status == .denied, redirectToSettings, (!isNotDetermined || redirectToSettingsIfNotDetermined) {
                    self.showAlertAndRedirectToURL(URL, from: from)
                }
                callback(status)
            }
        }
        
        let setttingURLCallback: (Bool, PermissionStatus) -> Void = {
            _callBack($0, URL(string: UIApplication.openSettingsURLString), $1)
        }
        
        if #available(iOS 14.0, *), self == .appTracking {
            return requestAppTracking(setttingURLCallback)
        }
        switch self {
        case .location: requestLocation(setttingURLCallback)
        case .contact: requestContacts(setttingURLCallback)
        case .photoLibrary: requestPhoto(setttingURLCallback)
        case .camera: requestAVDevice(.video, completion: setttingURLCallback)
        case .microphone: requestAVDevice(.audio, completion: setttingURLCallback)
        case .calendarEvent: requestCalendar(.event, completion: setttingURLCallback)
        case .calendarReminder: requestCalendar(.reminder, completion: setttingURLCallback)
        case .notification:
            if #available(iOS 16.0, *) {
                requestNotification({ _callBack($0, URL(string: UIApplication.openNotificationSettingsURLString), $1) })
            } else {
                requestNotification(setttingURLCallback)
            }
        default: DispatchQueue.main.async { callback(.unknown) }
        }
    }
    
    private func showAlertAndRedirectToURL(_ url: URL?, from viewController: UIViewController?) {
        let alertController = UIAlertController(title: "", message: infoDescription, preferredStyle: .alert)
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .destructive))
        alertController.addAction(.init(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
            if let _url = url, UIApplication.shared.canOpenURL(_url) {
                UIApplication.shared.open(_url)
            }
        }))
        
        var _viewController = viewController
        if _viewController == nil {
            _viewController = UIApplication.shared.delegate?.window??.rootViewController
        }
        _viewController?.present(alertController, animated: true)
    }
}

extension Permissions {
    private final class Store: NSObject, CLLocationManagerDelegate {
        let locationManager = CLLocationManager()
        let eventStore = EKEventStore()
        override init() {
            super.init()
            locationManager.delegate = self
        }
        
        var locationAuthorizationCallback: ((PermissionStatus) -> Void)?
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if #available(iOS 14.0, *) {
                locationAuthorizationCallback?(manager.authorizationStatus.permissionStatus)
            } else {
                locationAuthorizationCallback?(CLLocationManager.authorizationStatus().permissionStatus)
            }
            locationAuthorizationCallback = nil
        }
    }
    
    private static let store = Store()
}

extension Permissions {
    func locationPermission() -> PermissionStatus {
        if #available(iOS 14.0, *) {
            return Permissions.store.locationManager.authorizationStatus.permissionStatus
        } else {
            return CLLocationManager.authorizationStatus().permissionStatus
        }
    }

    func photoPermission() -> PermissionStatus {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite).permissionStatus
        } else {
            return PHPhotoLibrary.authorizationStatus().permissionStatus
        }
    }

    func contactsPersmission() -> PermissionStatus {
        CNContactStore.authorizationStatus(for: .contacts).permissionStatus
    }

    func AVDeviceCapturePermission(_ type: AVMediaType) -> PermissionStatus {
        AVCaptureDevice.authorizationStatus(for: type).permissionStatus
    }

    @available(iOS 14.0, *)
    func appTrackingPermission() -> PermissionStatus {
        ATTrackingManager.trackingAuthorizationStatus.permissionStatus
    }

    func calendarPermission(_ type: EKEntityType) -> PermissionStatus {
        EKEventStore.authorizationStatus(for: type).permissionStatus
    }

    func notificationPermission(_ callback: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            callback(settings.authorizationStatus.permissionStatus)
        })
    }
}

extension Permissions {
    
    func requestLocation(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = locationPermission()
        switch status {
        case .notDetermined:
            Permissions.store.locationAuthorizationCallback = {
                completion(true, $0)
            }
            let locationManager = Permissions.store.locationManager
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        default:
            completion(false, status)
        }
    }
    
    func requestPhoto(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = photoPermission()
        switch status {
        case .notDetermined:
            if #available(iOS 14.0, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in
                    completion(true, self.photoPermission())
                })
            } else {
                PHPhotoLibrary.requestAuthorization { _ in
                    completion(true, self.photoPermission())
                }
            }
        default: completion(false, status)
        }
    }

    func requestContacts(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = contactsPersmission()
        switch contactsPersmission() {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts, completionHandler: { _, _ in
                completion(true, self.contactsPersmission())
            })
        default:
            completion(false, status)
        }
    }

    func requestAVDevice(_ type: AVMediaType, completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = AVDeviceCapturePermission(type)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: type, completionHandler: { _ in
                completion(true, self.AVDeviceCapturePermission(type))
            })
        default:
            completion(false, status)
        }
    }

    @available(iOS 14.0, *)
    func requestAppTracking(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = appTrackingPermission()
        switch status {
        case .notDetermined:
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                completion(true, self.appTrackingPermission())
            })
        default:
            completion(false, status)
        }
    }
    
    func requestCalendar(_ type: EKEntityType, completion: @escaping (Bool, PermissionStatus) -> Void) {
        let status = calendarPermission(type)
        switch status {
        case .notDetermined:
            Permissions.store.eventStore.requestAccess(to: type, completion: { _, _ in
                completion(true, self.calendarPermission(type))
            })
        default:
            completion(false, status)
        }
    }
    
    func requestNotification(_ completion: @escaping (Bool, PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: PermissionStatus = settings.authorizationStatus.permissionStatus
            switch status {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(completionHandler: { authorized, _ in
                    if authorized {
                        completion(true, .authorized)
                    } else {
                        completion(true, .denied)
                    }
                })
            default:
                completion(false, status)
            }
        }
    }
}
