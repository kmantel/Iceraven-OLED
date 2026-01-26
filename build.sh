#!/bin/bash
set -e

# Decompile with Apktool (decode resources + classes)
wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.12.1/apktool_2.12.1.jar -O apktool.jar
java -jar apktool.jar d iceraven.apk -o iceraven-patched

# Remove META-INF
rm -rf iceraven-patched/META-INF
# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml

# Smali patching
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali_classes2/mozilla/components/ui/colors/PhotonColors.smali

# Recompile the APK (removed --use-aapt2 flag)
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Align the APK
zipalign -v 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk apktool.jar
