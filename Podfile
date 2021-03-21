use_frameworks!


def gd_common_pods
  pod 'SnapKit'
  #pod 'FMDB'
  #pod 'Kingfisher'
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
