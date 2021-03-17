#!/bin/zsh
# 当前似有库pod名称
podspecName="GDSwift.podspec"

a=`grep -E 's.version.*=' ${podspecName}`
b=${a#*\'}
version=${b%\'*}
LineNumber=`grep -nE 's.version.*=' ${podspecName} | cut -d : -f1`

#获取最新版本的tag
git_rev_list=`git rev-list --tags --max-count=1`
newVersion=`git describe --tags ${git_rev_list}`

echo "newVersion:"${newVersion}

if [[ ${version} =~ ${newVersion} ]]; then
  # 修改HSBKit.podspec文件中的version为指定值
	sed -i  "${LineNumber}s/${version}/${newVersion}/g" ${podspecName}
	# 修改readme版本号
	sed -i  "s/${version}/${newVersion}/g" README.md
fi

echo "----准备打包-fastlane打包发布----"
# 下面是使用fastlane打包发布
fastlane release tag:${newVersion} message:'update' podspec:${podspecName}