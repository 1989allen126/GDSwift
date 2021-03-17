set -oe pipefail
mkdir -p build
xcodebuild -workspace GDSwift.xcworkspace -scheme GDSwift_Example -configuration Debug -destination "name=iPhone 11" clean test \
  | tee build/output \
  | grep .[0-9]ms \
  | grep -v ^0.[0-9]ms \
  | sort -nr > build/build-times.txt \
	&& cat build/build-times.txt | less
