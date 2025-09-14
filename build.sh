#!/bin/bash

set -e
set -x

# Decompile with Apktool (decode resources + classes)
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.12.0.jar -O apktool.jar
java -jar apktool.jar d iceraven.apk -o iceraven-patched  # -s flag removed
rm -rf iceraven-patched/META-INF

# Color patching
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css

# Error page background
sed -i 's/--background-color: #15141a/--background-color: #000000/g' iceraven-patched/assets/low_and_medium_risk_error_style.css
sed -i 's/background-color: #1c1b22/background-color: #000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' iceraven-patched/res/drawable-v23/splash_screen.xml
sed -i 's/160\.0dip/200\.0dip/g' iceraven-patched/res/drawable-v23/splash_screen.xml


color_subs=(
	's/ff1c1b22/ff000000/g'
	's/ff2b2a33/ff000000/g'
	's/ff42414d/ff15141a/g'
	's/ff52525e/ff25232e/g'
	's/ff5b5b66/ff2d2b38/g'
	's/ff2a2a2e/ff000000/g'
)

for sub in "${color_subs[@]}"; do
	sed -i ''"$sub"'' iceraven-patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
done

rm -rf iceraven-patched/assets/extensions/ads


# Recompile the APK
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk

# Align and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk

ls -la
