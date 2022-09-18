.PHONY: install-com.dp.logcatapp.apk
install-com.dp.logcatapp.apk: \
	install-%.apk: var/cache/fdroidcl/apks/%.apk
	$(ADB) install --user current $<
	$(MAKE) -f $(cur_makefile) configure-$*.apk

.PHONY: configure-com.dp.logcatapp.apk
configure-com.dp.logcatapp.apk: configure-%.apk:
	$(MAKE) -f $(cur_makefile) \
		grant-permission-android.permission.READ_LOGS-to-$*-package
