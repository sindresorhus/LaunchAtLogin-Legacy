#!/bin/bash

if [ "${DEPLOYMENT_LOCATION}" = "YES" ]; then # this is an archive/Profile build
	build_root="${DSTROOT}"
	helper_dir="${build_root}/$CONTENTS_FOLDER_PATH/Library/LoginItems"
	origin_helper_path="${helper_dir}/LaunchAtLogin.framework/Resources/LaunchAtLoginHelper.app"
else
	build_root="${BUILT_PRODUCTS_DIR}"
	helper_dir="${build_root}/$CONTENTS_FOLDER_PATH/Library/LoginItems"
	origin_helper_path="${build_root}/$FRAMEWORKS_FOLDER_PATH/LaunchAtLogin.framework/Resources/LaunchAtLoginHelper.app"
fi

helper_path="$helper_dir/LaunchAtLoginHelper.app"

rm -rf "$helper_path"
mkdir -p "$helper_dir"
cp -rf "$origin_helper_path" "$helper_dir/"

defaults write "$helper_path/Contents/Info" CFBundleIdentifier -string "$PRODUCT_BUNDLE_IDENTIFIER-LaunchAtLoginHelper"

if [[ -n $CODE_SIGN_ENTITLEMENTS ]]; then
	codesign --force --entitlements="$CODE_SIGN_ENTITLEMENTS" --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
else
	codesign --force --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
fi

if [[ $CONFIGURATION == "Release" ]]; then
	rm -rf "$origin_helper_path"
	rm "$(dirname "$origin_helper_path")/copy-helper.sh" || true
fi
