#!/bin/bash
set -e

# Download Apktool
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.12.0.jar -O apktool.jar

# Decompile with Apktool (decode resources + classes)
java -jar apktool.jar d iceraven.apk -o iceraven-patched

# Color patching
rm -rf iceraven-patched/META-INF
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css

# Smali patching
sed -i 's/ff1c1b22/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff2b2a33/ff000000/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff42414d/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
sed -i 's/ff52525e/ff15141a/g' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali

# Drawable patching (only if file exists)
if [ -f iceraven-patched/res/drawable-v23/splash_screen.xml ]; then
  sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' iceraven-patched/res/drawable-v23/splash_screen.xml
  sed -i 's/160\.0dip/200\.0dip/g' iceraven-patched/res/drawable-v23/splash_screen.xml
fi

# Recompile the APK
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Align the APK
zipalign -v 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk apktool.jar
