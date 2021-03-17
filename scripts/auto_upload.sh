#!/bin/zsh
# 当前似有库pod名称
podspecName="GDSwift.podspec"


version=`cat ${podspecName} | grep -E "s.version\s+=" | cut -d '"' -f 2`
LineNumber=`grep -nE 's.version.*=' ${podspecName} | cut -d : -f1`

#获取最新版本的tag
git_rev_list=`git rev-list --tags --max-count=1`
newVersion=`git describe --tags ${git_rev_list}`

echo "newVersion:"${newVersion}

if [[ ${version} =~ ${newVersion} ]]; then
  # 修改HSBKit.podspec文件中的version为指定值
	sed -i  "${LineNumber}s/${version}/${newVersion}/g" ${podspecName}
fi

echo "----准备打包-fastlane打包发布----"
# 下面是使用fastlane打包发布
fastlane release version:${newVersion}  message:'update' podspec:${podspecName}