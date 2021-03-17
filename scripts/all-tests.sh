. scripts/common.sh

RELEASE_TEST=0

VALIDATE_IOS_EXAMPLE=1
VALIDATE_IOS=1

UNIX_NAME=`uname`
DARWIN="Darwin"
LINUX="Linux"

function unsuppported_os() {
	printf "${RED}Unsupported os: ${UNIX_NAME}${RESET}\n"
	exit -1
}

function unsupported_target() {
	printf "${RED}Unsupported os: ${UNIX_NAME}${RESET}\n"
	exit -1
}

if [ "$1" == "r" ]; then
	printf "${GREEN}Pre release tests on, hang on tight ...${RESET}\n"
	RELEASE_TEST=1
elif [ "$1" == "iOS-Example" ]; then
	VALIDATE_IOS_EXAMPLE=1
	VALIDATE_IOS=0
elif [ "$1" == "iOS" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_IOS=1
fi

if [ "${RELEASE_TEST}" -eq 1 ]; then
	VALIDATE_PODS=${VALIDATE_PODS:-1}
else
	VALIDATE_PODS=${VALIDATE_PODS:-0}
fi

RUN_DEVICE_TESTS=${RUN_DEVICE_TESTS:-1}

function ensureVersionEqual() {
	if [[ "$1" != "$2" ]]; then
		echo "Version $1 and $2 are not equal ($3)"
		exit -1
	fi 
}

function ensureNoGitChanges() {
	if [ `(git add . && git diff HEAD && git reset) | wc -l` -gt 0 ]; then
		echo $1
		exit -1
	fi
}

function checkPlistVersions() {
	GDSWIFT_VERSION=`cat GDSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
	echo "GDSwift version: ${GDSwift_VERSION}"
	PROJECTS=(GDSwift  GDSwift_Tests)
	for project in ${PROJECTS[@]}
	do
		echo "Checking version for ${project}"
		PODSPEC_VERSION=`cat $project.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
		ensureVersionEqual "$GDSwift_VERSION" "$PODSPEC_VERSION" "${project} version not equal"
		PLIST_VERSION=`defaults read  "\`pwd\`/${project}/Info.plist" CFBundleShortVersionString`
		if ! ( [[ ${GDSwift_VERSION} = *"-"* ]] || [[ "${PLIST_VERSION}" == "${GDSwift_VERSION}" ]] ) ; then
			echo "Invalid version for `pwd`/${project}/Info.plist: ${PLIST_VERSION}"
          	exit -1
		fi
	done
}

ensureNoGitChanges "Please make sure the working tree is clean. Use \`git status\` to check."
if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
	checkPlistVersions
fi

CONFIGURATIONS=(Release-Tests)

if [ "${RELEASE_TEST}" -eq 1 ]; then
	CONFIGURATIONS=(Debug Release Release-Tests)
fi

if [ "${VALIDATE_PODS}" -eq 1 ]; then
	SWIFT_VERSION=5.0 scripts/validate-podspec.sh
fi

if [ "${VALIDATE_IOS_EXAMPLE}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		for scheme in "GDSwift_Tests"
		do
			for configuration in "Debug"
			do
				gd ${scheme} ${configuration} "${DEFAULT_IOS_SIMULATOR}" build
			done
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		unsupported_target
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping iOS-Example tests ...${RESET}\n"
fi

if [ "${VALIDATE_IOS}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		#make sure all iOS tests pass
		for configuration in ${CONFIGURATIONS[@]}
		do
			gd "AllTests-iOS" ${configuration} "${DEFAULT_IOS_SIMULATOR}" test
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		unsupported_target
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping iOS tests ...${RESET}\n"
fi