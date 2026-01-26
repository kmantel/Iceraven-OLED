#!/bin/bash
set -e

echo "=== Starting build process ==="

# Download Apktool
echo "Downloading Apktool..."
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.12.0.jar -O apktool.jar
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
  echo "  Patching values-night/colors.xml..."
  sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
  echo "  ✓ values-night/colors.xml patched"
else
  echo "  ⚠ values-night/colors.xml not found, skipping"
fi

if [ -f iceraven-patched/res/values/colors.xml ]; then
  echo "  Patching values/colors.xml..."
  sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
  echo "  ✓ values/colors.xml patched"
else
  echo "  ⚠ values/colors.xml not found, skipping"
fi

if [ -f iceraven-patched/assets/extensions/readerview/readerview.css ]; then
  echo "  Patching readerview.css..."
  sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
  sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css
  echo "  ✓ readerview.css patched"
else
  echo "  ⚠ readerview.css not found, skipping"
fi

# Smali patching
echo "Patching smali files..."
if ls iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali 1> /dev/null 2>&1; then
  sed -i 's/ff1c1b22/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  echo "✓ Smali files patched"
else
  echo "⚠ PhotonColors.smali not found, skipping"
fi

# Drawable patching
echo "Patching drawable..."
if [ -f iceraven-patched/res/drawable-v23/splash_screen.xml ]; then
  echo "  Patching splash_screen.xml..."
  sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' iceraven-patched/res/drawable-v23/splash_screen.xml
  sed -i 's/160\.0dip/200\.0dip/g' iceraven-patched/res/drawable-v23/splash_screen.xml
  echo "  ✓ splash_screen.xml patched"
else
  echo "  ⚠ splash_screen.xml not found, skipping"
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
