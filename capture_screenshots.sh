#!/bin/bash

# Script to capture App Store screenshots on all required device sizes

# set -e  # Disabled to see errors

# Output directory
SCREENSHOTS_DIR="AppStoreScreenshots"
mkdir -p "$SCREENSHOTS_DIR"

# Device configurations
# Format: "Device Name|Output Folder|Target Width|Target Height"
# iPhone 6.5" requires: 1242×2688px, 2688×1242px, 1284×2778px or 2778×1284px
# iPad 13.0" requires: 2064×2752px, 2752×2064px, 2048×2732px or 2732×2048px
DEVICES=(
    "iPhone 17 Pro|iPhone_6.5|1284|2778"
    "iPad Pro 13-inch (M5)|iPad_13.0|2064|2752"
)

echo "🎬 Starting screenshot capture process..."
echo ""

for device_config in "${DEVICES[@]}"; do
    IFS='|' read -r device folder target_width target_height <<< "$device_config"

    echo "📱 Capturing screenshots for: $device"
    echo "   Output folder: $SCREENSHOTS_DIR/$folder"

    # Create output directory
    mkdir -p "$SCREENSHOTS_DIR/$folder"

    # Run the screenshot test
    xcodebuild test \
        -scheme RumTime \
        -destination "platform=iOS Simulator,name=$device" \
        -only-testing:RumTimeUITests/ScreenshotTests/testCaptureScreenshots \
        -resultBundlePath "$SCREENSHOTS_DIR/${folder}_result.xcresult" \
        2>&1 | grep -E "(Testing|Executed|FAILED)" || true

    echo "✅ Test completed for $device"
    echo ""
done

echo ""
echo "🖼️  Extracting screenshots from test results..."
echo ""

# Extract screenshots from xcresult bundles
for device_config in "${DEVICES[@]}"; do
    IFS='|' read -r device folder target_width target_height <<< "$device_config"

    RESULT_BUNDLE="$SCREENSHOTS_DIR/${folder}_result.xcresult"

    if [ -d "$RESULT_BUNDLE" ]; then
        echo "📂 Processing: $folder"

        # Find all PNG files in the xcresult bundle and copy them
        counter=1
        while IFS= read -r file; do
            if file "$file" 2>/dev/null | grep -q "PNG image"; then
                echo "   Copying screenshot: $(basename "$file") (Created: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S.%N" "$file"))"
                cp "$file" "$SCREENSHOTS_DIR/$folder/screenshot-$counter.png"
                counter=$((counter + 1))
            fi
        done < <(find "$RESULT_BUNDLE" -type f)

        # Count how many screenshots we extracted
        png_count=$(ls -1 "$SCREENSHOTS_DIR/$folder"/*.png 2>/dev/null | wc -l | tr -d ' ')
        echo "   Extracted $png_count screenshots to: $SCREENSHOTS_DIR/$folder"

        # Resize screenshots to target dimensions
        echo "   Resizing screenshots to ${target_width}x${target_height}..."
        for img in "$SCREENSHOTS_DIR/$folder"/*.png; do
            if [ -f "$img" ]; then
                sips -z "$target_height" "$target_width" "$img" > /dev/null 2>&1
            fi
        done
        echo "   ✓ Resized all screenshots"

        # Clean up the xcresult bundle
        echo "   Cleaning up test results..."
        rm -rf "$RESULT_BUNDLE"
    fi
done

echo ""
echo "✨ Screenshot capture complete!"
echo ""
echo "📁 Screenshots saved to: $SCREENSHOTS_DIR/"
echo "📱 All screenshots resized to App Store requirements"
echo ""
