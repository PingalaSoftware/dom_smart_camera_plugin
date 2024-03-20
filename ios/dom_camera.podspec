#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dom_camera.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dom_camera'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pingala Software' => 'ajay@pingalasoftware.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.{h,hh}'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.vendored_frameworks = 'FUNSdk.framework', 'XMNetInterface.framework'
  s.frameworks = 'AVFoundation', 'AudioToolbox','VideoToolbox', 'OpenAL', 'Photos'
  s.libraries = 'z', 'bz2', 'resolv', 'iconv'
  s.pod_target_xcconfig = { 
  'DEFINES_MODULE' => 'YES', 
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  'OTHER_LDFLAGS' => '-ld_classic -ObjC',

  'CLANG_CXX_LIBRARY' => 'libc++',
  'OTHER_CPLUSPLUSFLAGS' => '-std=c++11',
  'HEADER_SEARCH_PATHS' => '$(inherited) "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include/c++/v1/"',
  }
end
