#
# Be sure to run `pod lib lint FunNet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunNet'
  s.version          = '0.0.1'
  s.summary          = 'FunNet provides a foundation for reusable functional networking in Swift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/schrockblock/funnet'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => '' }
  s.source           = { :git => 'https://github.com/schrockblock/funnet.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/elliot_schrock'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FunNet/Classes/**/*'
  s.dependency 'LithoOperators'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'FunNet/Classes/Core/**/*.swift'
    
    sp.dependency 'LithoOperators'
  end
  
  s.subspec 'Combine' do |sp|
    sp.source_files = 'FunNet/Classes/Combine/**/*.swift'
    
    sp.dependency 'FunNet/Core'
  end
  
  s.subspec 'ReactiveSwift' do |sp|
    sp.source_files = 'FunNet/Classes/ReactiveSwift/**/*'
    
    sp.dependency 'FunNet/Core'
    sp.dependency 'ReactiveSwift'
  end
end
