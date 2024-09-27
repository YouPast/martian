#!/bin/bash

# Script to build iOS and macOS frameworks and create an xcframework for mars.

# Define repeated path constants
MARS_BUILD_DIR="cmake_build/iOS/iOS.out/mars.framework"
IOS_DEVICE_DIR="cmake_build/ios_device_framework/mars.framework"
IOS_SIMULATOR_DIR="cmake_build/ios_simulator_framework/mars.framework"
MACOS_FRAMEWORK_DIR="cmake_build/OSX/Darwin.out/mars.framework"
XCFRAMEWORK_OUTPUT="cmake_build/mars.xcframework"

# Change directory to the project folder
cd mars

# Step 1: Build for iOS and macOS
python3 build_ios.py 2
python3 build_osx.py 3

# Step 2: Create directories for split frameworks
mkdir -p $IOS_DEVICE_DIR
mkdir -p $IOS_SIMULATOR_DIR

# Step 3: Copy the framework contents to the respective directories
cp -R $MARS_BUILD_DIR/ $IOS_DEVICE_DIR/
cp -R $MARS_BUILD_DIR/ $IOS_SIMULATOR_DIR/

# Step 4: Extract device slice (arm64 architecture)
lipo $MARS_BUILD_DIR/mars -extract arm64 -output $IOS_DEVICE_DIR/mars

# Step 5: Extract simulator slice (x86_64 architecture)
lipo $MARS_BUILD_DIR/mars -extract x86_64 -output $IOS_SIMULATOR_DIR/mars

# Step 6: Create an xcframework combining iOS device, iOS simulator, and macOS frameworks
xcodebuild -create-xcframework \
  -framework $IOS_DEVICE_DIR \
  -framework $IOS_SIMULATOR_DIR \
  -framework $MACOS_FRAMEWORK_DIR \
  -output $XCFRAMEWORK_OUTPUT

# Step 7: Compress the xcframework for distribution
zip -r $XCFRAMEWORK_OUTPUT.zip $XCFRAMEWORK_OUTPUT
ZIP_NAME=$XCFRAMEWORK_OUTPUT.zip

# Step 8: Compute checksum using swift package manager
CHECKSUM=$(swift package compute-checksum $ZIP_NAME)

echo "XCFramework: ${ZIP_NAME}"
echo "Checksum: ${CHECKSUM}"
