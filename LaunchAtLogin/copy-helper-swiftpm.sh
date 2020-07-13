#!/bin/bash

package_resources_path="$BUILT_PRODUCTS_DIR/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources"

helper_name="LaunchAtLoginHelper.app"
helper_path="$package_resources_path/$helper_name"

contents_path="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH"
login_items="$contents_path/Library/LoginItems"
login_helper_path="$login_items/$helper_name"

rm -rf "$login_helper_path"
mkdir -p "$login_items"
cp -rf "$helper_path" "$login_helper_path"

defaults write "$login_helper_path/Contents/Info" CFBundleIdentifier -string "$PRODUCT_BUNDLE_IDENTIFIER-LaunchAtLoginHelper"

if [[ -n $CODE_SIGN_ENTITLEMENTS ]]; then
    codesign --force --entitlements="$package_resources_path/LaunchAtLogin.entitlements" --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$login_helper_path"
else
    codesign --force --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
fi

if [[ $CONFIGURATION == "Release" ]]; then
    rm -rf "$contents_path/Resources/LaunchAtLogin_LaunchAtLogin.bundle"
fi
