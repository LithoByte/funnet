#
# Be sure to run `pod lib lint FunNet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunNet'
  s.version          = '0.1.1'
  s.summary          = 'FunNet provides a foundation for reusable functional networking in Swift.'
  s.swift_versions   = ['4.2', '5.0', '5.1', '5.2', '5.3']

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/schrockblock/funnet'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => '' }
  s.source           = { :git => 'https://github.com/LithoByte/funnet.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/elliot_schrock'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/funnet/**/*'
  s.dependency 'LithoOperators'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Sources/funnet/Core/**/*.swift'
    sp.dependency 'LithoOperators'
    sp.dependency 'LithoUtils/Core'
    sp.dependency 'Slippers/Core'
  end
  
  s.subspec 'TCA' do |sp|
    sp.source_files = 'Sources/funnet/TCA/**/*.swift'
    sp.dependency 'FunNet/Core'
  end
  
  s.subspec 'Multipart' do |sp|
    sp.source_files = 'Sources/funnet/Multipart/**/*.swift'
    sp.dependency 'LithoOperators'
  end
  
  s.subspec 'ErrorHandling' do |sp|
    sp.source_files = 'Sources/funnet/ErrorHandling/**/*.swift'
    sp.dependency 'LithoOperators'
    sp.dependency 'LithoUtils/Core'
    sp.dependency 'Slippers/Core'
  end
  
  s.subspec 'ErrorHandlingCombine' do |sp|
    sp.source_files = 'Sources/funnet/ErrorHandlingCombine/**/*.swift'
    
    sp.dependency 'FunNet/ErrorHandling'
    sp.dependency 'LithoOperators'
    sp.dependency 'LithoUtils/Core'
    sp.dependency 'Slippers/Core'
    
    sp.framework = 'Combine'
  end
end
