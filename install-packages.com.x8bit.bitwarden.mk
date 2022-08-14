.PHONY: install-com.x8bit.bitwarden.apk
install-com.x8bit.bitwarden.apk: c = org.fdroid.fdroid
# From https://github.com/bitwarden/mobile/blame/v2.3.1/README.md#L7
install-com.x8bit.bitwarden.apk: r = https://mobileapp.bitwarden.com/fdroid/
install-com.x8bit.bitwarden.apk: install-%.apk:
	$(adb_wakeup)
	$(ADB) shell am start \
		-n $(c)/.views.main.MainActivity \
		-a android.intent.action.VIEW \
		"$(r)"
	@echo "Once you add the repo and install application $*, press the enter key."
	@head -n 1
	$(MAKE) -f $(cur_makefile) is-package-$*-enabled

.PHONY: configure-com.x8bit.bitwarden.apk
configure-com.x8bit.bitwarden.apk: configure-%.apk:
	$(adb_wakeup)
	@echo "Once you configure application $*, press the enter key."
	@echo "* Settings > Unlock with Biometrics"
	@head -n 1
