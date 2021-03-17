#! /bin/zsh
infoPlist=/Users/apple/Desktop/GDSwift/Example/Info.plist
bundleDisplayName=`/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $infoPlist`
bundleVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $infoPlist`
bundleBuildVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $infoPlist`
echo "$bundleDisplayName"
echo "$bundleVersion"
echo "$bundleBuildVersion"