.DEFAULT_GOAL = list-devices

ADB = adb
ADB_USER_ID = 0

# MONKEYRUNNER = $(shell brew cask info android-sdk | grep monkeyrunner | cut -d' ' -f1)
# $(dir $(patsubst %/,%,$(dir $(MONKEYRUNNER))))adb: | $(ADB)
# 	ln -s "$(word 1,$|)" "$@"

.PHONY: automatically-provision-android-one
automatically-provision-android-one: \
	install-browser \
	install-calculator \
	install-calendar \
	install-camera \
	install-clock \
	install-contacts \
	install-file-manager \
	install-gallery \
	install-keyboard \
	install-logcat \
	install-maps \
	install-media-player \
	install-messaging \
	install-notes \
	disable-google-packages \
	revoke-revocable-special-accesses-from-all-packages \
	revoke-dangerous-permissions-from-all-packages \
	disable-nfc \
	; $(info Assumption: Android One systems are similar across Original Equipment Manufacturers)

.PHONY: manually-provision-android-one
manually-provision-android-one: \
	prompt-managing-special-accesses \
	prompt-managing-default-apps \
	;

.PHONY: is-android-one-provisioned
is-android-one-provisioned: \
	are-google-packages-disabled-or-enabled-correctly \
	are-revocable-special-permissions-revoked-from-all-packages \
	is-special-access-data_saver-revoked-from-all-packages \
	are-dangerous-permissions-revoked-from-all-packages \
	; $(warning This target performs only partial checks)

# ==== Internal Rules and Variables ====

# ---- Android Variables: Packages ----

google_packages_not_to_be_disabled = \
	com.android.chrome \
	com.google.android.apps.work.oobconfig \
	com.google.android.configupdater \
	com.google.android.dialer \
	com.google.android.gms \
	com.google.android.packageinstaller
google_packages_to_be_disabled = \
	com.android.vending \
	$(filter-out $(google_packages_not_to_be_disabled),$(call filter_packages_by_prefix,com.google,$(packages)))

# ---- Android Variables: Permissions ----

revocable_special_permissions = \
	android.permission.SYSTEM_ALERT_WINDOW \
	android.permission.WRITE_SETTINGS \
	android.permission.ACCESS_NOTIFICATIONS \
	android.permission.REQUEST_INSTALL_PACKAGES \
	android.permission.CHANGE_WIFI_STATE

include android-one.non_revocable_dangerous_permissions_from_packages.mk
non_revocable_permissions_from_packages = \
	$(sort $(non_revocable_dangerous_permissions_from_packages))

# ---- Android Variables: Special Accesses ----

revocable_special_accesses = \
	data_saver

# Special Access           | Permission
# zen_access               | ? android.permission.ACCESS_NOTIFICATION_POLICY
# special_app_usage_access | ? android.permission.PACKAGE_USAGE_STATS
# enabled_vr_listeners     | ? android.permission.BIND_VR_LISTENER_SERVICE
promptable_special_accesses = \
	zen_access \
	special_app_usage_access \
	enabled_vr_listeners
# Reference: https://developer.android.com/reference/android/provider/Settings
action_for_prompting_special_access_zen_access = \
	android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS
action_for_prompting_special_access_special_app_usage_access = \
	android.settings.USAGE_ACCESS_SETTINGS
action_for_prompting_special_access_enabled_vr_listeners = \
	android.settings.VR_LISTENER_SETTINGS

# TODO: high_power_apps
# TODO: picture_in_picture
# TODO: premium_sms
# TODO: special_app_directory_access
#
# Special Access        | Permission
# device_administrators | ? android.permission.BIND_DEVICE_ADMIN
non_revocable_special_accesses = \
	device_administrators

# ---- Make Variables ----

# No built-in rules. Eases debugging.
MAKEFLAGS = -r

comma = ,
empty =
space = $(empty) $(empty)
left_brace = {
right_brace = }

strip_prefix = $(patsubst $(1)%,%,$(2))

# ---- List Devices and Other Basic Items ----

.PHONY: list-devices
list-devices: ; $(ADB) devices -l

.PHONY: list-commands
list-commands: ; $(ADB) shell cmd -l

.PHONY: list-users
list-users: ; $(ADB) shell pm list users

# ---- List Packages ----

adb_ls_packages = $(ADB) shell pm list packages $(1)
strip_package = $(call strip_prefix,package:,$(1))

packages = \
	$(sort $(call strip_package,$(shell $(call adb_ls_packages,))))
.PHONY: list-packages
list-packages: ; @echo $(packages)

enabled_packages = \
	$(sort $(call strip_package,$(shell $(call adb_ls_packages,-e))))
.PHONY: list-enabled-packages
list-enabled-packages: ; @echo $(enabled_packages)

.PHONY: is-package-%-enabled
is-package-%-enabled: ; $(if $(filter $*,$(enabled_packages)),@true,@false)

disabled_packages = $(filter-out $(enabled_packages),$(packages))
.PHONY: list-disabled-packages
list-disabled-packages: ; @echo $(disabled_packages)

.PHONY: is-package-%-disabled
is-package-%-disabled: ; $(if $(filter $*,$(disabled_packages)),@true,@false)

filter_packages_by_prefix = $(filter $(1) $(1).%,$(2))

.PHONY: list-packages-by-prefix-%
list-packages-by-prefix-%:
	@echo $(call filter_packages_by_prefix,$*,$(packages))

.PHONY: list-enabled-packages-by-prefix-%
list-enabled-packages-by-prefix-%:
	@echo $(call filter_packages_by_prefix,$*,$(enabled_packages))

# Second- or first-level domain.
# Examples:
# ```
# $ echo com | cut -d. -f-2
# com
# $ echo com.example | cut -d. -f-2
# com.example
# $ echo com.example.third | cut -d. -f-2
# com.example
# ```
sld = $(shell echo $(1) | cut -d. -f-2)

package_slds = $(sort $(foreach p,$(packages),$(call sld,$(p))))
# Second- and first-level domains.
.PHONY: list-package-second-level-domains
list-package-second-level-domains: ; @echo $(package_slds)

enabled_package_slds = $(sort $(foreach p,$(enabled_packages),$(call sld,$(p))))
# Second- and first-level domains.
.PHONY: list-enabled-package-second-level-domains
list-enabled-package-second-level-domains: ; @echo $(enabled_package_slds)

adb_ls_packages_by_uid = $(ADB) shell pm list packages --uid $(1)
packages_by_uid = \
	$(call strip_package,$(patsubst %uid:$(1),%,$(shell $(call adb_ls_packages_by_uid,$(1)))))
.PHONY: list-packages-by-uid-%
list-packages-by-uid-%: ; @echo $(call packages_by_uid,$*)

# ---- Disable Packages ----

.PHONY: disable-package-%
disable-package-%: ; $(ADB) shell pm disable-user --user $(ADB_USER_ID) $*

.PHONY: disable-google-packages
disable-google-packages: \
	$(patsubst %,disable-package-%,$(google_packages_to_be_disabled))
	$(MAKE) are-google-packages-disabled-or-enabled-correctly

ifneq ($(strip $(filter-out $(packages),$(google_packages_to_be_disabled))),)
$(error Misconfigured package(s) to be disabled $(filter-out $(packages),$(google_packages_to_be_disabled)))
endif
ifneq ($(strip $(filter-out $(packages),$(google_packages_not_to_be_disabled))),)
$(error Misconfigured package(s) not to be disabled $(filter-out $(packages),$(google_packages_not_to_be_disabled)))
endif
.PHONY: are-google-packages-disabled-or-enabled-correctly
are-google-packages-disabled-or-enabled-correctly: \
	$(patsubst %,is-package-%-disabled,$(google_packages_to_be_disabled)) \
	$(patsubst %,is-package-%-enabled,$(google_packages_not_to_be_disabled)) \
	;

.PHONY: clear-package-com.android.chrome
clear-package-com.android.chrome: clear-package-%:
	adb shell pm clear $*

# ---- List Permissions across Packages ----

adb_ls_permissions = $(ADB) shell pm list permissions $(1)
filter_permissions = $(filter permission:%,$(1))
strip_permission = $(call strip_prefix,permission:,$(1))
ls_permissions = $(call strip_permission,$(call filter_permissions,$(shell $(call adb_ls_permissions,$(1)))))

permissions = $(sort $(call ls_permissions,-g))
.PHONY: list-permissions
list-permissions: ; @echo $(permissions)

dangerous_permissions = $(sort $(call ls_permissions,-g -d))
.PHONY: list-dangerous-permissions
list-dangerous-permissions: ; @echo $(dangerous_permissions)

user_permissions = $(sort $(call ls_permissions,-u))
.PHONY: list-user-permissions
list-user-permissions: ; @echo $(user_permissions)

dangerous_user_permissions = \
	$(filter $(dangerous_permissions),$(user_permissions))
.PHONY: list-dangerous-user-permissions
list-dangerous-user-permissions: ; @echo $(dangerous_user_permissions)

non_dangerous_user_permissions = \
	$(filter-out $(dangerous_permissions),$(user_permissions))
# Non-dangerous user permissions cannot be revoked.
.PHONY: list-non-dangerous-user-permissions
list-non-dangerous-user-permissions: ; @echo $(non_dangerous_user_permissions)

# ---- List per-Package Permissions ----

permissions_requested_by_package = \
	$(sort $(shell $(CURDIR)/libexec/requested_permissions $(1)))
.PHONY: list-permissions-requested-by-package-%
list-permissions-requested-by-package-%:
	@echo $(call permissions_requested_by_package,$*)

permissions_granted_to_package = \
	$(sort $(shell $(CURDIR)/libexec/granted_permissions $(1)))
.PHONY: list-permissions-granted-to-package-%
list-permissions-granted-to-package-%:
	@echo $(call permissions_granted_to_package,$*)

# From https://source.android.com/devices/tech/config/perms-whitelist
# > Privileged apps are system apps that are located in a `priv-app` directory on one of the system image partitions.
privileged_permissions_for_package = \
	$(sort $(subst $(comma)$(space),$(space),$(patsubst %$(right_brace),%,$(patsubst $(left_brace)%,%,$(shell $(ADB) shell pm get-privapp-permissions $(1))))))
.PHONY: list-privileged-permissions-for-package-%
list-privileged-permissions-for-package-%:
	@echo $(call privileged_permissions_for_package,$*)

privileged_permissions_requested_by_package = \
	$(filter \
		$(call permissions_requested_by_package,$(1)), \
		$(call privileged_permissions_for_package,$(1)))
.PHONY: list-privileged-permissions-requested-by-package-%
list-privileged-permissions-requested-by-package-%:
	@echo $(call privileged_permissions_requested_by_package,$*)

# ---- Revoke Permissions ----
# See also secondary expansion.

revoke_perm_pkg_sep = -from-
revoke_pkg = $(word 2,$(subst $(revoke_perm_pkg_sep), ,$(1)))
revoke_perm = $(word 1,$(subst $(revoke_perm_pkg_sep), ,$(1)))

.PHONY: revoke-permission-%-package
revoke-permission-%-package:
	$(if \
		$(filter $(revocable_special_permissions),$(call revoke_perm,$*)), \
		$(ADB) shell appops set $(call revoke_pkg,$*) $(patsubst android.permission.%,%,$(call revoke_perm,$*)) deny, \
		$(ADB) shell pm revoke $(call revoke_pkg,$*) $(call revoke_perm,$*))

targets_for_not_revoking_non_revocable_permissions_from_packages = \
	$(patsubst %,revoke-permission-%-package, \
		$(non_revocable_permissions_from_packages) \
		$(EXTRA_NON_REVOCABLE_PERMISSIONS_FROM_PACKAGES))
ifeq ($(strip $(W)),all)
# This is slow hence protect it with conditional on environment variable `W`.
# XXX Wrap this in a target - setting conditional?
$(foreach \
	t, \
	$(non_revocable_permissions_from_packages) \
		$(EXTRA_NON_REVOCABLE_PERMISSIONS_FROM_PACKAGES), \
	$(if \
		$(filter-out \
			$(call permissions_requested_by_package,$(call revoke_pkg,$(t))), \
			$(call revoke_perm,$(t))), \
		$(error Misconfigured permission $(call revoke_perm,$(t)) not to be revoked from package $(call revoke_pkg,$(t)))))
endif
.PHONY: $(targets_for_not_revoking_non_revocable_permissions_from_packages)
$(targets_for_not_revoking_non_revocable_permissions_from_packages): \
	revoke-permission-%-package:
	$(info Ignoring revoking permission $(call revoke_perm,$*) from package $(call revoke_pkg,$*))

revoked_perm_pkg_sep = -revoked-from-
revoked_pkg = $(word 2,$(subst $(revoked_perm_pkg_sep), ,$(1)))
revoked_perm = $(word 1,$(subst $(revoked_perm_pkg_sep), ,$(1)))

# XXX Review. Doc mentions `allow, ignore, deny, or default`
is_revocable_special_permission_granted_to_package = \
	$(ADB) shell appops get $(1) $(patsubst android.permission.%,%,$(2)) | grep -q -e allow
.PHONY: is-permission-%-package
is-permission-%-package:
	$(if \
		$(filter $(revocable_special_permissions),$(call revoked_perm,$*)), \
		! $(call is_revocable_special_permission_granted_to_package,$(call revoked_pkg,$*),$(call revoked_perm,$*)), \
		$(if \
			$(filter $(call revoked_perm,$*),$(call permissions_granted_to_package,$(call revoked_pkg,$*))), \
			@false, \
			@true))

.PHONY: revoke-dangerous-permissions-from-all-packages
revoke-dangerous-permissions-from-all-packages: \
	$(patsubst %,revoke-dangerous-permissions-from-package-%,$(packages)) \
	;

.PHONY: are-dangerous-permissions-revoked-from-all-packages
are-dangerous-permissions-revoked-from-all-packages: \
	$(patsubst %,are-dangerous-permissions-revoked-from-package-%,$(packages)) \
	;

permissions_not_granted_to_package = \
	$(filter-out \
		$(call permissions_granted_to_package,$(1)), \
		$(call permissions_requested_by_package,$(1)))
.PHONY: list-dangerous-permissions-revoked-from-package-%
list-dangerous-permissions-revoked-from-package-%:
	@echo $(filter \
		$(dangerous_permissions), \
		$(call permissions_not_granted_to_package,$*))

.PHONY: long-list-dangerous-permissions-revoked-from-package-%
long-list-dangerous-permissions-revoked-from-package-%:
	@X="$$($(MAKE) -s list-dangerous-permissions-revoked-from-package-$*)" \
		&& { test -z "$${X?}" \
			|| printf "%b %b:\n\t%b\n" \
				"Dangerous permissions revoked from package" \
				"$*" \
				"$${X:?}"; }

.PHONY: list-dangerous-permissions-revoked-from-enabled-packages
list-dangerous-permissions-revoked-from-enabled-packages: \
	$(patsubst %,long-list-dangerous-permissions-revoked-from-package-%,$(enabled_packages)) \
	;

.PHONY: revoke-privileged-permissions-from-all-packages
revoke-privileged-permissions-from-all-packages: \
	$(patsubst %,revoke-privileged-permissions-from-package-%,$(packages)) \
	;

android-one.non_revocable_dangerous_permissions_from_packages.mk:
	$(warning This is a development-only target: you are on your own)
	echo > $@
	$(MAKE) $@.tmp
	mv $@.tmp $@

android-one.non_revocable_dangerous_permissions_from_packages.mk.tmp: \
	android-one.%.mk.tmp:
	$(MAKE) -s list-devices # Make usage of make option `-k` more robust by attempting to detect the most common error - i.e. `adb` - before and after the make invocation.
	# Sample exception line: `Security exception: Non-System UID cannot revoke system fixed permission android.permission.GET_ACCOUNTS for package android`
	{ printf "%b\n" '$* = \\' \
		&& { $(MAKE) -k revoke-dangerous-permissions-from-all-packages 2>&1 \
			| grep -B 1 -e '^Security exception: Non-System UID cannot revoke system fixed permission [^[:space:]]* for package [^[:space:]]*$$' \
			| grep -e '^adb' | sed 's/^adb shell pm revoke \([^[:space:]]*\) \([^[:space:]]*\)$$/	\2-from-\1 \\/' \
		; } \
		&& printf "%b\n" '\t' \
	; } > $@
	$(MAKE) -s list-devices

# ---- List Special Accesses ----

# As per Android 9,
# the 14 items of the screen "Settings > Apps & notifications >
# Special app access" are defined in `special_access.xml`.
#
# Relevant excerpts can be extracted from it by:
# ```
# $ curl -LsSf https://raw.githubusercontent.com/aosp-mirror/platform_packages_apps_settings/android-9.0.0_r51/res/xml/special_access.xml | grep '\(android:key\|android:fragment\|settings:keywords\)='
# ```
#
# The keys in such file are:
# ```
# $ curl -LsSf https://raw.githubusercontent.com/aosp-mirror/platform_packages_apps_settings/android-9.0.0_r51/res/xml/special_access.xml | grep '\(android:key\)=' | sed 's/^[[:space:]]*android:key="\([^"]*\)"[[:space:]]*$/\1/'
# special_app_access_screen
# high_power_apps
# device_administrators
# system_alert_window
# zen_access
# write_settings_apps
# notification_access
# picture_in_picture
# premium_sms
# data_saver
# manage_external_sources
# special_app_usage_access
# enabled_vr_listeners
# special_app_directory_access
# change_wifi_state
# ```
#
# The strings associated to the `android:key` keys in the
# `special_access.xml` seem to be defined in
# https://raw.githubusercontent.com/aosp-mirror/platform_packages_apps_settings/android-9.0.0_r51/res/values/strings.xml
#
# The permissions are defined in `AndroidManifest.xml`.
#
# Some permissions are labelled as `appop`, and seem to be able to be
# revoked by `adb shell appops set ... ... deny`.
# ```
# $ curl -LsSf https://raw.githubusercontent.com/aosp-mirror/platform_frameworks_base/android-9.0.0_r51/core/res/AndroidManifest.xml | grep -B 3 -i appop
#          system for creating and managing IPsec-based interfaces.
#     -->
#     <permission android:name="android.permission.MANAGE_IPSEC_TUNNELS"
#         android:protectionLevel="signature|appop" />
# --
#     <permission android:name="android.permission.SYSTEM_ALERT_WINDOW"
#         android:label="@string/permlab_systemAlertWindow"
#         android:description="@string/permdesc_systemAlertWindow"
#         android:protectionLevel="signature|preinstalled|appop|pre23|development" />
# --
#     <permission android:name="android.permission.WRITE_SETTINGS"
#         android:label="@string/permlab_writeSettings"
#         android:description="@string/permdesc_writeSettings"
#         android:protectionLevel="signature|preinstalled|appop|pre23" />
# --
#     <permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"
#         android:label="@string/permlab_requestInstallPackages"
#         android:description="@string/permdesc_requestInstallPackages"
#         android:protectionLevel="signature|appop" />
# --
#          <p>Declaring the permission implies intention to use the API and the user of the
#          device can grant permission through the Settings application. -->
#     <permission android:name="android.permission.PACKAGE_USAGE_STATS"
#         android:protectionLevel="signature|privileged|development|appop" />
# --
#          any metadata and intents attached.
#          @hide -->
#     <permission android:name="android.permission.ACCESS_NOTIFICATIONS"
#         android:protectionLevel="signature|privileged|appop" />
# --
#
#     <!-- Allows an instant app to create foreground services. -->
#     <permission android:name="android.permission.INSTANT_APP_FOREGROUND_SERVICE"
#         android:protectionLevel="signature|development|instant|appop" />
# --
#
#     <!-- Allows an application to watch changes and/or active state of app ops.
#          @hide <p>Not for use by third-party applications. -->
#     <permission android:name="android.permission.WATCH_APPOPS"
# ```

data_background_whitelist_package_uids = \
	$(sort $(shell $(CURDIR)/libexec/net_background_whitelist))
.PHONY: list-data_saver-whitelist-package-uids
list-data_saver-whitelist-package-uids:
	@echo $(data_background_whitelist_package_uids)

# ---- Revoke Special Accesses: Automatic ----
# See also secondary expansion.

.PHONY: revoke-special-access-data_saver-from-package-uid-%
revoke-special-access-data_saver-from-package-uid-%:
	$(info Removing package UID $* from data background whitelist (packages: $(call packages_by_uid,$*)))
	$(ADB) shell cmd netpolicy remove restrict-background-whitelist $*

.PHONY: revoke-special-access-data_saver-from-all-packages
revoke-special-access-data_saver-from-all-packages: \
	$(patsubst %,revoke-special-access-data_saver-from-package-uid-%,$(data_background_whitelist_package_uids)) \
	;

.PHONY: is-special-access-data_saver-revoked-from-all-packages
is-special-access-data_saver-revoked-from-all-packages:
	$(if $(data_background_whitelist_package_uids),@false,@true)

ifneq ($(strip $(filter-out $(permissions),$(revocable_special_permissions))),)
$(error Misconfigured revocable special permission(s) $(filter-out $(permissions),$(revocable_special_permissions)))
endif
.PHONY: revoke-revocable-special-permissions-from-all-packages
revoke-revocable-special-permissions-from-all-packages: \
	$(patsubst %,revoke-revocable-special-permissions-from-package-%,$(packages)) \
	;

.PHONY: are-revocable-special-permissions-revoked-from-all-packages
are-revocable-special-permissions-revoked-from-all-packages: \
	$(patsubst %,are-revocable-special-permissions-revoked-from-package-%,$(packages)) \
	;

.PHONY: revoke-revocable-special-accesses-from-all-packages
revoke-revocable-special-accesses-from-all-packages: \
	revoke-revocable-special-permissions-from-all-packages \
	$(patsubst %,revoke-special-access-%-from-all-packages,$(revocable_special_accesses)) \
	;

# ---- Revoke Special Accesses: Manual ----

targets_for_revoking_promptable_special_accesses = \
	$(patsubst %,prompt-managing-special-access-%,$(promptable_special_accesses))
.PHONY: $(targets_for_revoking_promptable_special_accesses)
$(targets_for_revoking_promptable_special_accesses): \
	prompt-managing-special-access-%:
	$(ADB) shell input keyevent KEYCODE_WAKEUP # Reference: https://github.com/aosp-mirror/platform_frameworks_base/blob/android-9.0.0_r51/core/java/android/view/KeyEvent.java#L640
	$(ADB) shell am start -a $(action_for_prompting_special_access_$*)
	@echo "Once you disable special access $* for the applications, press any key."
	@head -n 1

targets_for_revoking_non_revocable_special_accesses = \
	$(patsubst %,prompt-managing-special-access-%,$(non_revocable_special_accesses))
.PHONY: $(targets_for_revoking_non_revocable_special_accesses)
$(targets_for_revoking_non_revocable_special_accesses): \
	prompt-managing-special-access-%:
	@echo "You are on your own for disabling special access $* for the applications. Once you are done, press any key."
	@head -n 1

.PHONY: prompt-managing-special-accesses
prompt-managing-special-accesses: \
	$(targets_for_revoking_promptable_special_accesses) \
	$(targets_for_revoking_non_revocable_special_accesses) \
	;

# ---- Misc ----

.PHONY: prompt-managing-default-apps
prompt-managing-default-apps:
	$(ADB) shell am start -a android.settings.MANAGE_DEFAULT_APPS_SETTINGS
	@echo "You are on your own for managing default applications. Once you are done, press any key."
	@head -n 1

.PHONY: disable-nfc
disable-nfc:
	$(ADB) shell svc nfc disable

.PHONY: reboot
reboot: ; $(ADB) $@

# ---- Install Packages ----

.PHONY: install-browser
install-browser: install-org.mozilla.fennec_fdroid.apk

.PHONY: install-calculator
install-calculator: install-com.simplemobiletools.calculator.apk

.PHONY: install-calendar
install-calendar: install-com.simplemobiletools.calendar.pro.apk

.PHONY: install-camera
install-camera: install-net.sourceforge.opencamera.apk

.PHONY: install-clock
install-clock: install-com.simplemobiletools.clock.apk

.PHONY: install-contacts
install-contacts: install-com.simplemobiletools.contacts.pro.apk

.PHONY: install-file-manager
install-file-manager: install-com.simplemobiletools.filemanager.pro.apk

.PHONY: install-gallery
install-gallery: install-com.simplemobiletools.gallery.pro.apk

.PHONY: install-keyboard
install-keyboard: install-com.menny.android.anysoftkeyboard.apk ;

.PHONY: install-logcat
install-logcat: install-com.dp.logcatapp.apk ;

.PHONY: install-com.dp.logcatapp.apk
install-com.dp.logcatapp.apk: install-%.apk: var/cache/fdroidcl/apks/%.apk
	adb install --user current $<
	adb shell pm grant --user $(ADB_USER_ID) $* android.permission.READ_LOGS

.PHONY: install-maps
install-maps: install-net.osmand.plus.apk

.PHONY: install-media-player
install-media-player: install-org.videolan.vlc.apk

.PHONY: install-messaging
install-messaging: install-org.smssecure.smssecure.apk

.PHONY: install-notes
install-notes: install-com.simplemobiletools.notes.pro.apk

.PHONY: install-%.apk
install-%.apk: var/cache/fdroidcl/apks/%.apk
	adb install --user current $<

var/cache/fdroidcl/apks/%.apk: ; $(MAKE) -f Makefile.fdroidcl $@
