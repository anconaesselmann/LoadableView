Pod::Spec.new do |s|
  s.name             = 'LoadableView'
  s.version          = '0.1.1'
  s.summary          = 'LoadableViews reduces boilerplate when creating SwiftUI views that have loading/loaded/error states'
  s.swift_version    = '5.5'
  s.ios.deployment_target = '13.0'
  s.description      = <<-DESC
LoadableViews reduces boilerplate when creating SwiftUI views that have loading/loaded/error states.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/LoadableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Axel Ancona Esselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/LoadableView.git', :tag => s.version.to_s }
  s.source_files = 'LoadableView/Classes/**/*'
end
