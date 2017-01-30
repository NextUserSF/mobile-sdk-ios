Pod::Spec.new do |s|
  s.name             = 'NextUser'
  s.version          = '0.1.9'
  s.summary          = 'NextUser analytics for iOS.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Dino4674/NextUserKitTestPod'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Next User' => 'dino.bartosak@gmail.com' }
  s.source           = { :git => 'https://github.com/Dino4674/NextUserKitTestPod.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'NextUser/Classes/**/*'
  s.public_header_files = 'NextUser/Classes/Public/**/*.h'
  s.resource_bundles = {
    'NextUser' => ['NextUser/Assets/*.png']
  }

  # s.frameworks = 'UIKit', 'MapKit'
    s.libraries = 'z'

    s.dependency 'CocoaLumberjack'
    s.dependency 'AFNetworking', '~> 3.0'
    s.dependency 'PubNub', '~> 4'
end
