.PHONY: android androidv icon splash jks


android:
	@flutter build apk --target-platform android-arm64 --split-per-abi

androidv:
	@flutter build apk --target-platform android-arm64 --split-per-abi -v

icon:
	@flutter pub run flutter_launcher_icons:main

splash:
	@flutter pub run flutter_native_splash:create

jks:
	@keytool -genkey -v -keystore ./android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
