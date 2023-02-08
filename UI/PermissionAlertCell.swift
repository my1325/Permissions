//
//  PermissionAlertCell.swift
//  GeSwift
//
//  Created by my on 2023/1/14.
//  Copyright © 2023 my. All rights reserved.
//

import UIKit

public protocol PermissionAlertCellDelegate: AnyObject {
    func permissionCell(_ cell: PermissionAlertCell, didTapedStatusButtonAt indexPath: IndexPath)
}

open class PermissionAlertCell: UITableViewCell {
    open lazy var descriptionInfoLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 100
        $0.textAlignment = .center
        self.contentView.addSubview($0)
        let top = NSLayoutConstraint(item: $0, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 10)
        let left = NSLayoutConstraint(item: $0, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 20)
        let right = NSLayoutConstraint(item: $0, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: -20)
        self.contentView.addConstraints([top, left, right])
        return $0
    }(UILabel())
    
    open lazy var statusButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(touchStatusButton), for: .touchUpInside)
        $0.clipsToBounds = true
        self.contentView.addSubview($0)
        let top = NSLayoutConstraint(item: $0, attribute: .top, relatedBy: .equal, toItem: self.descriptionInfoLabel, attribute: .bottom, multiplier: 1, constant: 10)
        let bottom = NSLayoutConstraint(item: $0, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -10)
        let centerX = NSLayoutConstraint(item: $0, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: $0, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        let height = NSLayoutConstraint(item: $0, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        self.contentView.addConstraints([top, bottom, centerX])
        $0.addConstraints([width, height])
        return $0
    }(UIButton(type: .custom))
    
    private var currentIsNotification: Bool = false
    open private(set) var indexPath: IndexPath?
    open private(set) weak var delegate: PermissionAlertCellDelegate?
    open func reloadPermission(_ permission: Permissions,
                          infoAttribute: [PermissionAlertConfiguration.Attribute]?,
                          buttonAttribute: [PermissionStatus: [PermissionAlertConfiguration.Attribute]]?,
                          delegate: PermissionAlertCellDelegate,
                          at indexPath: IndexPath)
    {
        self.indexPath = indexPath
        self.delegate = delegate
        self.reloadInfoAttribute(permission, attributes: infoAttribute)
        self.reloadButtonAttribute(permission, attributes: buttonAttribute)
    }
    
    open func reloadInfoAttribute(_ permissions: Permissions, attributes: [PermissionAlertConfiguration.Attribute]?) {
        let text = attributes?.value(for: .text) ?? permissions.infoDescription
        let textColor = attributes?.value(for: .foregroundColor) ?? UIColor.black
        let font = attributes?.value(for: .font) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributeString = NSAttributedString(string: text ?? "", attributes: [
            .font: font,
            .foregroundColor: textColor
        ])
        descriptionInfoLabel.attributedText = attributeString
    }
    
    open func reloadButtonAttribute(_ permissions: Permissions, attributes: [PermissionStatus: [PermissionAlertConfiguration.Attribute]]?) {
        if permissions == .notification {
            currentIsNotification = true
            permissions.permissionStatusWithCallback({ [weak self] status in
                if self?.currentIsNotification == true {
                    DispatchQueue.main.async {
                        self?.reloadButtonAttribute(status, attributes: attributes?[status])
                    }
                }
            })
        } else {
            currentIsNotification = false
            reloadButtonAttribute(permissions.permissionStatus, attributes: attributes?[permissions.permissionStatus])
        }
    }
    
    private func reloadButtonAttribute(_ status: PermissionStatus, attributes: [PermissionAlertConfiguration.Attribute]?) {
        let text = attributes?.value(for: .text) ?? status.defaultStringValue
        let textColor = attributes?.value(for: .foregroundColor) ?? status.defaultTextColor
        let backgroundColor = attributes?.value(for: .backgroundColor) ?? status.defaultBackgroundColor
        let borderColor = attributes?.value(for: .borderColor) ?? status.defaultBorderColor
        let cornerRadius: CGFloat = attributes?.value(for: .cornerRadius) ?? 16
        let font = attributes?.value(for: .font) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributeString = NSAttributedString(string: text, attributes: [
            .foregroundColor: textColor,
            .font: font
        ])
        statusButton.setAttributedTitle(attributeString, for: .normal)
        statusButton.backgroundColor = backgroundColor
        statusButton.layer.cornerRadius = cornerRadius
        statusButton.layer.borderColor = borderColor?.cgColor
        statusButton.layer.borderWidth = 1 / UIScreen.main.scale
    }
    
    @objc private func touchStatusButton() {
        if let _indexPath = indexPath {
            delegate?.permissionCell(self, didTapedStatusButtonAt: _indexPath)
        }
    }
}

extension PermissionStatus {
    var defaultStringValue: String {
        switch self {
        case .authorized: return NSLocalizedString("authorized", comment: "")
        case .notDetermined: return NSLocalizedString("notDetermined", comment: "")
        case .denied: return NSLocalizedString("denied", comment: "")
        case .unknown: return NSLocalizedString("unknown", comment: "")
        }
    }
    
    var defaultTextColor: UIColor {
        switch self {
        case .denied, .authorized: return .white
        case .unknown, .notDetermined: return .black
        }
    }
    
    var defaultBackgroundColor: UIColor {
        switch self {
        case .authorized: return .green
        case .denied: return .red
        case .unknown, .notDetermined: return .white
        }
    }
    
    var defaultBorderColor: UIColor? {
        switch self {
        case .authorized, .denied: return nil
        case .unknown, .notDetermined: return .black
        }
    }
}
