.PHONY: install-ch.protonmail.android.apk
install-ch.protonmail.android.apk: \
	var/cache/protonmail/ch.protonmail.android.apk
	$(ADB) install --user current $<

.PHONY: var/cache/protonmail/ch.protonmail.android.apk
var/cache/protonmail/ch.protonmail.android.apk:
	$(MAKE) -f Makefile.protonmail $@-if-modified

.PHONY: configure-ch.protonmail.android.apk
configure-ch.protonmail.android.apk: configure-%.apk:
	$(adb_wakeup)
	@echo "Once you configure application $*, press the enter key."
	@head -n 1
