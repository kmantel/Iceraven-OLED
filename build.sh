#!/bin/bash
set -e

# Check if required APK exists
if [ ! -f "iceraven.apk" ]; then
    echo "Error: iceraven.apk not found in current directory!"
    exit 1
fi

# Decompile with Apktool (decode resources + classes)
echo "Downloading apktool..."
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.12.0.jar -O apktool.jar

echo "Decompiling APK..."
java -jar apktool.jar d iceraven.apk -o iceraven-patched --force

# Color patching
echo "Applying patches..."
rm -rf iceraven-patched/META-INF

# Check if files exist before patching
if [ -f "iceraven-patched/res/values-night/colors.xml" ]; then
    sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
    sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
    sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
fi

if [ -f "iceraven-patched/res/values/colors.xml" ]; then
    sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
fi

if [ -f "iceraven-patched/assets/extensions/readerview/readerview.css" ]; then
    sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
    sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css
fi

# Smali patching - find and patch all matching files
echo "Patching smali files..."
find iceraven-patched -name "PhotonColors.smali" -type f | while read file; do
    sed -i 's/ff1c1b22/ff15141a/g' "$file"
    sed -i 's/ff2b2a33/ff000000/g' "$file"
    sed -i 's/ff42414d/ff15141a/g' "$file"
    sed -i 's/ff52525e/ff15141a/g' "$file"
done

# drawable patching
if [ -f "iceraven-patched/res/drawable-v23/splash_screen.xml" ]; then
    sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' iceraven-patched/res/drawable-v23/splash_screen.xml
    sed -i 's/160\.0dip/200\.0dip/g' iceraven-patched/res/drawable-v23/splash_screen.xml
fi

# Recompile the APK
echo "Recompiling APK..."
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Check if zipalign is available
echo "Aligning APK..."
if command -v zipalign >/dev/null 2>&1; then
    zipalign -p 4 iceraven-patched.apk iceraven-patched-aligned.apk
    mv iceraven-patched-aligned.apk iceraven-patched-signed.apk
else
    echo "Warning: zipalign not found. Skipping alignment step."
    mv iceraven-patched.apk iceraven-patched-signed.apk
fi

# Clean up
echo "Cleaning up..."
rm -rf iceraven-patched apktool.jar

echo "Build complete! Output: iceraven-patched-signed.apk"
