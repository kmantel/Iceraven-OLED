#!/bin/bash

set -e
set -x

# Decompile with Apktool (decode resources + classes)
APKTOOL_VERSION="${APKTOOL_VERSION:-2.11.0}"
apktool_fi="apktool_$APKTOOL_VERSION.jar"
[[ -f "$apktool_fi" ]] || wget -q "https://github.com/iBotPeaches/Apktool/releases/download/v$APKTOOL_VERSION/apktool_$APKTOOL_VERSION.jar" -O "$apktool_fi"

java -jar "$apktool_fi" d iceraven.apk -o iceraven-patched || echo "already unpacked"  # -s flag removed
rm -rf iceraven-patched/META-INF

# Color patching
sed -i 's/<color name="fx_mobile_surface">.*/<color name="fx_mobile_surface">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_background">.*/<color name="fx_mobile_background">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' iceraven-patched/res/values/colors.xml
sed -i 's/<color name="design_snackbar_background_color">.*/<color name="design_snackbar_background_color">#ff121212<\/color>/g' iceraven-patched/res/values/colors.xml
sed -i 's/1c1b22/000000/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's/eeeeee/e3e3e3/g' iceraven-patched/assets/extensions/readerview/readerview.css
sed -i 's;</resources>;\t<color name="design_snackbar_background_color">#ff320202</color>\n</resources>;g' iceraven-patched/res/values-night/colors.xml

# Error page background
sed -i 's/--background-color: #15141a/--background-color: #000000/g' iceraven-patched/assets/low_and_medium_risk_error_style.css
sed -i 's/background-color: #1c1b22/background-color: #000000/g' iceraven-patched/assets/extensions/readerview/readerview.css

function process_splash() {
	sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' "$1"
	sed -i 's/160\.0dip/200\.0dip/g' "$1"
}
export -f process_splash

find iceraven-patched/res/drawable -name "splash_screen*.xml" -exec bash -c 'process_splash "$1"' {} \;

# Remove animations
for d in anim anim-ldrtl animator; do
	find iceraven-patched/res/"$d" -name "*.xml" -exec sed -r -i 's;android:duration="(.*?)";android:duration="0";g' {} \;
done


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
java -jar "$apktool_fi" b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK
zipalign -f 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patched.apk

ls -la

if [[ "$1" == "sign" ]]; then
	apksigner sign --ks keystore.jks --ks-pass pass:"$KEYSTORE_PASSPHRASE" --key-pass pass:"$KEY_PASSWORD" iceraven-patched-signed.apk
fi
