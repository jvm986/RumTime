#!/bin/bash

# Script to capture App Store screenshots on all required device sizes

# set -e  # Disabled to see errors

# Parse command line arguments
SKIP_CLEANUP=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-cleanup)
            SKIP_CLEANUP=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-cleanup] [--skip-tests]"
            exit 1
            ;;
    esac
done

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

echo "Starting screenshot capture process..."
echo ""

if [ "$SKIP_TESTS" = true ]; then
    echo "Skipping tests (using existing xcresult bundles)"
    echo ""
else
    for device_config in "${DEVICES[@]}"; do
        IFS='|' read -r device folder target_width target_height <<< "$device_config"

        echo "Capturing screenshots for: $device"
        echo "   Output folder: $SCREENSHOTS_DIR/$folder"

        # Create output directory
        mkdir -p "$SCREENSHOTS_DIR/$folder"

        # Run the screenshot test
        xcodebuild test \
            -project RumTime.xcodeproj \
            -scheme RumTime \
            -testPlan RumTimeUITests \
            -destination "platform=iOS Simulator,name=$device" \
            -only-testing:RumTimeUITests/RumTimeUITests/testCompleteGameFlowWithScreenshots \
            -resultBundlePath "$SCREENSHOTS_DIR/${folder}_result.xcresult" \
            2>&1 | grep -E "(Testing|Executed|FAILED)" || true

        echo "Test completed for $device"
        echo ""
    done
fi

echo ""
echo "Extracting screenshots from test results..."
echo ""

# Extract screenshots from xcresult bundles
for device_config in "${DEVICES[@]}"; do
    IFS='|' read -r device folder target_width target_height <<< "$device_config"

    RESULT_BUNDLE="$SCREENSHOTS_DIR/${folder}_result.xcresult"

    if [ -d "$RESULT_BUNDLE" ]; then
        echo "Processing: $folder"

        # Export attachments using xcresulttool
        TEMP_EXPORT_DIR="$SCREENSHOTS_DIR/${folder}_temp"
        mkdir -p "$TEMP_EXPORT_DIR"

        xcrun xcresulttool export attachments \
            --path "$RESULT_BUNDLE" \
            --output-path "$TEMP_EXPORT_DIR" 2>/dev/null

        # Parse manifest.json to get proper screenshot names
        if [ -f "$TEMP_EXPORT_DIR/manifest.json" ]; then
            # Extract attachments info and copy with clean names
            # Parse JSON to get exportedFileName and suggestedHumanReadableName pairs
            while read -r exported_file suggested_name; do
                if [ -n "$exported_file" ] && [ -n "$suggested_name" ]; then
                    # Extract clean name by removing _0_UUID suffix
                    clean_name=$(echo "$suggested_name" | sed 's/_0_[A-F0-9-]*\.png/.png/')

                    if [ -f "$TEMP_EXPORT_DIR/$exported_file" ]; then
                        echo "   Copying: $clean_name"
                        cp "$TEMP_EXPORT_DIR/$exported_file" "$SCREENSHOTS_DIR/$folder/$clean_name"
                    fi
                fi
            done < <(grep -E '"(exportedFileName|suggestedHumanReadableName)"' "$TEMP_EXPORT_DIR/manifest.json" | \
                     sed 's/.*: "\(.*\)".*/\1/' | \
                     paste -d' ' - -)
        fi

        # Clean up temp export directory
        rm -rf "$TEMP_EXPORT_DIR"

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
        if [ "$SKIP_CLEANUP" = true ]; then
            echo "   Skipping cleanup (xcresult bundle preserved)"
        else
            echo "   Cleaning up test results..."
            rm -rf "$RESULT_BUNDLE"
        fi
    fi
done

echo ""
echo "Screenshot capture complete!"
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR/"
echo "All screenshots resized to App Store requirements"
echo ""
