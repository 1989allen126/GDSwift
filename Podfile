platform :ios, '10.0'

use_frameworks!

def gd_common_pods
  pod 'SnapKit'
  pod 'Hero'
  #pod 'FMDB'
  #pod 'Kingfisher'
  #pod 'SwiftDate'
  #pod 'IQKeyboardManagerSwift'
  #pod 'SwiftyUserDefaults'
end

target 'GDSwift' do
    
  # GDSwift
  gd_common_pods
  
  target 'GDSwift_Tests' do
    inherit! :search_paths
    gd_common_pods
  end
end

target 'GDSwift_Example' do
  
  gd_common_pods
  # GDSwift
  #pod 'GDSwift', :path => './'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = "NO"
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
