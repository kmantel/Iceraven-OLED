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
sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml

# Smali patching
sed -i 's/ff1c1b22/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali

# CSS patching
sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css

# Recompile the APK (removed --use-aapt2 flag)
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Align the APK
zipalign -v 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk apktool.jar
