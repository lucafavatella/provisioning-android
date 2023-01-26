ADB = adb
ADB_USER_ID = 0

docs_pdf = com.artifex.mupdf.viewer.app
file_manager = com.simplemobiletools.filemanager.pro
logcat = com.dp.logcatapp
mail = com.fsck.k9
mail_extra = ch.protonmail.android
maps = net.osmand.plus
notes = com.simplemobiletools.notes.pro
password_manager = com.x8bit.bitwarden

.PHONY: automatically-provision-lineageos
automatically-provision-lineageos: \
	install-$(docs_pdf).apk \
	install-$(file_manager).apk \
	install-$(logcat).apk \
	install-$(mail).apk \
	install-$(mail_extra).apk \
	install-$(maps).apk \
	install-$(notes).apk \
	install-org.fdroid.fdroid.apk \
	disable-nfc \
	;

.PHONY: manually-provision-lineageos
manually-provision-lineageos: \
	install-$(password_manager).apk \
	configure-$(mail).apk \
	configure-$(mail_extra).apk \
	configure-$(password_manager).apk \
	;

.PHONY: is-lineageos-provisioned
is-lineageos-provisioned: \
	is-special-access-data_saver-granted-to-package-com.google.android.gms \
	is-package-$(mail_extra)-enabled \
	is-package-$(password_manager)-enabled \
	; $(warning This target performs only partial checks)

# ==== Internal Rules and Variables ====

# ---- Android Variables: Permissions ----

revocable_special_permissions = \
	android.permission.SYSTEM_ALERT_WINDOW \
	android.permission.WRITE_SETTINGS \
	android.permission.ACCESS_NOTIFICATIONS \
	android.permission.REQUEST_INSTALL_PACKAGES \
	android.permission.CHANGE_WIFI_STATE

# ---- Android Variables: ADB Library ----

# Reference: https://github.com/aosp-mirror/platform_frameworks_base/blob/android-9.0.0_r51/core/java/android/view/KeyEvent.java#L637-L640
adb_wakeup = $(ADB) shell input keyevent KEYCODE_WAKEUP

# ---- Make Variables ----

# No built-in rules. Eases debugging.
MAKEFLAGS = -r

cur_makefile = lineageos.pre-secondary-expansion.mk

strip_prefix = $(patsubst $(1)%,%,$(2))

# ---- List Devices and Other Basic Items ----

.PHONY: list-devices
list-devices: ; $(ADB) devices -l

# ---- List Packages ----

adb_ls_packages = $(ADB) shell pm list packages $(1)
strip_package = $(call strip_prefix,package:,$(1))

enabled_packages = \
	$(sort $(call strip_package,$(shell $(call adb_ls_packages,-e))))
.PHONY: list-enabled-packages
list-enabled-packages: ; @echo $(enabled_packages)

.PHONY: is-package-%-enabled
is-package-%-enabled: ; $(if $(filter $*,$(enabled_packages)),@true,@false)

uid_by_package = \
	$(shell $(CURDIR)/libexec/package_uid_by_package_name $(1))

# ---- Revoke Permissions ----

grant_perm_pkg_sep = -to-
grant_pkg = $(word 2,$(subst $(grant_perm_pkg_sep), ,$(1)))
grant_perm = $(word 1,$(subst $(grant_perm_pkg_sep), ,$(1)))

.PHONY: grant-permission-%-package
grant-permission-%-package:
	$(if \
		$(filter $(revocable_special_permissions),$(call grant_perm,$*)), \
		$(error Granting appop unimplemented), \
		$(ADB) shell pm grant --user $(ADB_USER_ID) $(call grant_pkg,$*) $(call grant_perm,$*))

# ---- List Special Accesses ----

data_background_whitelist_package_uids = \
	$(sort $(shell $(CURDIR)/libexec/net_background_whitelist))
.PHONY: list-data_saver-whitelist-package-uids
list-data_saver-whitelist-package-uids:
	@echo $(data_background_whitelist_package_uids)

# ---- Revoke Special Accesses: Automatic ----

.PHONY: is-special-access-data_saver-granted-to-package-%
is-special-access-data_saver-granted-to-package-%:
	$(if $(filter $(call uid_by_package,$*),$(data_background_whitelist_package_uids)),@true,@false)

# ---- Misc ----

.PHONY: disable-nfc
disable-nfc:
	$(ADB) shell svc nfc disable

# ---- Install Packages ----

include install-packages.com.dp.logcatapp.mk

include install-packages.com.fsck.k9.mk

include install-packages.ch.protonmail.android.mk

include install-packages.com.x8bit.bitwarden.mk

.PHONY: install-%.apk
install-%.apk: var/cache/fdroidcl/apks/%.apk
	$(ADB) install --user current $<

.PRECIOUS: var/cache/fdroidcl/apks/%.apk
var/cache/fdroidcl/apks/%.apk: ; $(MAKE) -f Makefile.fdroidcl $@
