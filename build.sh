#!/bin/bash
set -e

echo "=== Starting build process ==="

# Download Apktool from GitHub releases (more reliable)
echo "Downloading Apktool..."
wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O apktool.jar || {
  echo "Failed to download from GitHub, trying BitBucket..."
  wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O apktool.jar
}
echo "✓ Apktool downloaded"

# Decompile with Apktool
echo "Decompiling APK..."
java -jar apktool.jar d iceraven.apk -o iceraven-patched
echo "✓ APK decompiled"

# Remove META-INF
echo "Removing META-INF..."
rm -rf iceraven-patched/META-INF
echo "✓ META-INF removed"

# Color patching
echo "Patching colors..."
if [ -f iceraven-patched/res/values-night/colors.xml ]; then
  sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
  echo "✓ values-night/colors.xml patched"
fi

if [ -f iceraven-patched/res/values/colors.xml ]; then
  sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
  echo "✓ values/colors.xml patched"
fi

if [ -f iceraven-patched/assets/extensions/readerview/readerview.css ]; then
  sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
  sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css
  echo "✓ readerview.css patched"
fi

# Smali patching
echo "Patching smali files..."
find iceraven-patched -path "*/smali*/mozilla/components/ui/colors/PhotonColors.smali" -exec sed -i 's/ff1c1b22/ff15141a/g' {} + 2>/dev/null || true
find iceraven-patched -path "*/smali*/mozilla/components/ui/colors/PhotonColors.smali" -exec sed -i 's/ff2b2a33/ff000000/g' {} + 2>/dev/null || true
find iceraven-patched -path "*/smali*/mozilla/components/ui/colors/PhotonColors.smali" -exec sed -i 's/ff42414d/ff15141a/g' {} + 2>/dev/null || true
find iceraven-patched -path "*/smali*/mozilla/components/ui/colors/PhotonColors.smali" -exec sed -i 's/ff52525e/ff15141a/g' {} + 2>/dev/null || true
echo "✓ Smali files patched"

# Drawable patching
if [ -f iceraven-patched/res/drawable-v23/splash_screen.xml ]; then
  echo "Patching splash_screen.xml..."
  sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' iceraven-patched/res/drawable-v23/splash_screen.xml
  sed -i 's/160\.0dip/200\.0dip/g' iceraven-patched/res/drawable-v23/splash_screen.xml
  echo "✓ splash_screen.xml patched"
fi

# Recompile the APK
echo "Recompiling APK..."
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk
echo "✓ APK recompiled"

# Align the APK
echo "Aligning APK..."
zipalign -v 4 iceraven-patched.apk iceraven-patched-signed.apk
echo "✓ APK aligned"

# Clean up
echo "Cleaning up..."
rm -rf iceraven-patched iceraven-patched.apk apktool.jar
echo "✓ Cleanup complete"

echo "=== Build process completed successfully ==="
