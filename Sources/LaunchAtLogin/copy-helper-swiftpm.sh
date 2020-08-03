#!/bin/bash

HELPER_CHECKSUM="4842fa690b83d96d509dad6763571125e4a2ae2dcf8f858f88518486816a5598"
HELPER_CHECKSUM_RUNTIME="ceef772a05157e9b64e40fb022d19e6462e371f9d69d1dbd3c1e64096bde535d"

verlte() {
	[  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

if verlte "10.14.4" "$MACOSX_DEPLOYMENT_TARGET"; then
	helper_name="LaunchAtLoginHelper"
	checksum="$HELPER_CHECKSUM"
else
	helper_name="LaunchAtLoginHelper-with-runtime"
	checksum="$HELPER_CHECKSUM_RUNTIME"
fi

package_resources_path="$BUILT_PRODUCTS_DIR/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources"

helper_path="$package_resources_path/$helper_name.zip"

contents_path="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH"
login_items="$contents_path/Library/LoginItems"
login_helper_path="$login_items/LaunchAtLoginHelper.app"

rm -rf "$login_helper_path"
mkdir -p "$login_items"

# Verify SHA256 checksum of LaunchAtLoginHelper
zip_checksum="$(shasum -a 256 "$helper_path" | awk '{print $1}')"

if [[ "$zip_checksum" != "$checksum" ]]; then
	echo "Wrong checksum of LaunchAtLoginHelper"
	exit 1
fi

unzip "$helper_path" -d "$login_items/"

defaults write "$login_helper_path/Contents/Info" CFBundleIdentifier -string "$PRODUCT_BUNDLE_IDENTIFIER-LaunchAtLoginHelper"

if [[ -n $CODE_SIGN_ENTITLEMENTS ]]; then
	codesign --force --entitlements="$package_resources_path/LaunchAtLogin.entitlements" --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$login_helper_path"
else
	codesign --force --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
fi

if [[ $CONFIGURATION == "Release" ]]; then
	rm -rf "$contents_path/Resources/LaunchAtLogin_LaunchAtLogin.bundle"
fi
