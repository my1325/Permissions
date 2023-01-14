Pod::Spec.new do |s|

 s.name             = "Permissions"
 s.version           = "0.0.1"
 s.summary         = "A light weight iOS Permission Authorization manager"
 s.homepage        = "https://github.com/my1325/Permissions.git"
 s.license            = "MIT"
 s.platform          = :ios, "12.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/Permissions.git", :tag => "#{s.version}" }
 s.swift_version = '5'
 s.source_files = 'Sources/Permissions/*.swift'
end