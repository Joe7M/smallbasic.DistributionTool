#!/bin/bash

################################################################################
# This script installs android-sdk. Download latest android-sdk for Linux from #
# https://developer.android.com/studio/index.html#command-tools                #
# and unpack to this directory. Then start this installation script.           #
################################################################################

# Do copy paste according to 
# https://developer.android.com/studio/command-line/sdkmanager 
# $OWD is set by AppImage

mkdir $OWD/android-sdk
mkdir $OWD/android-sdk/cmdline-tools
mv $OWD/cmdline-tools $OWD/android-sdk/cmdline-tools/latest 

# Install all necessary packages

$OWD/android-sdk/cmdline-tools/latest/bin/sdkmanager --install "build-tools;33.0.0"
$OWD/android-sdk/cmdline-tools/latest/bin/sdkmanager --install "platforms;android-33"
$OWD/android-sdk/cmdline-tools/latest/bin/sdkmanager --install "platform-tools"
