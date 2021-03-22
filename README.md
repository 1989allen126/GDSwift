# 1.0 初始化项目代码

##1.1 验证pod是否通过校验
./scripts/validate-podspec.sh GDSwift.podspec

pod repo lint . (pod lib lint --allow-warnings)
pod lib lint  GDSwift.podspec --use-libraries --allow-warnings 
pod repo push AllenSpecs  GDSwift.podspec --use-libraries --allow-warnings

#
pod repo push AllenSpecs 'GDSwift.podspec' --allow-warnings --skip-import-validation


##1.2 提交代码
fastlane pushGit version:0.0.1 message:"初始化项目"

##1.3 测试启动时间
./scripts/profile-build-times.sh

##1.3 测试启动时间


## 提交记录
1）日拱一卒

EventMonitor.swift
