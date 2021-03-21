Pod::Spec.new do |s|
  s.name             = 'GDSwift'
  s.version          = "0.0.1"
  s.summary          = '常见工具类封装'


  s.description      = <<-DESC
GDSwift集成常用组件
                       DESC

  s.homepage         = 'https://github.com/1989allen126/GDSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'apple' => 'jjl13142008@126.com' }
  s.source           = { :git => 'git@github.com:1989allen126/GDSwift.git', :tag => s.version.to_s }
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-ObjC'
  }

  s.ios.deployment_target = '9.0'
  s.swift_version         = '5.1'
  #s.resource     = ['GDSwift/Resource/*']
  #s.resource = ['GDSwift/Resource/Assets']
  s.resource_bundle = {
        'GDBundleResource' => ['GDSwift/Resource/*']
  }
  s.source_files = 'GDSwift/Classes/**/*'

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "GDSwift/Classes/Core/**/*"
  end
  
  s.subspec "Widgets" do |ss|
    ss.source_files  = "GDSwift/Classes/Widgets/**/*"
    ss.dependency "SnapKit"
    ss.dependency "Hero"
    ss.dependency "GDSwift/Core"
  end

end
