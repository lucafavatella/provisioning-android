.DEFAULT_GOAL = list-devices

ADB = adb
ADB_USER_ID = 0

# MONKEYRUNNER = $(shell brew cask info android-sdk | grep monkeyrunner | cut -d' ' -f1)
# $(dir $(patsubst %/,%,$(dir $(MONKEYRUNNER))))adb: | $(ADB)
# 	ln -s "$(word 1,$|)" "$@"

.PHONY: provision-sprout
provision-sprout: \
	automatically-provision-sprout \
	manually-provision-sprout \
	;

.PHONY: automatically-provision-sprout
automatically-provision-sprout: \
	disable-package-com.hmdglobal.app.fmradio \
	automatically-provision-android-one \
	;

.PHONY: manually-provision-sprout
manually-provision-sprout: \
	manually-provision-android-one \
	;

.PHONY: automatically-provision-android-one
automatically-provision-android-one: \
	disable-google-packages \
	revoke-revocable-special-permissions-from-all-packages \
	disable-nfc \
	; $(info Assumption: Android One systems are similar across Original Equipment Manufacturers)

.PHONY: manually-provision-android-one
manually-provision-android-one: \
	prompt-managing-special-permissions \
	prompt-managing-default-apps \
	;

# ==== Internal Rules and Variables ====

# No built-in rules. Eases debugging.
MAKEFLAGS = -r

comma = ,
empty =
space = $(empty) $(empty)
left_brace = {
right_brace = }

google_packages_not_to_be_disabled = \
	com.google.android.apps.work.oobconfig \
	com.google.android.configupdater \
	com.google.android.deskclock \
	com.google.android.dialer \
	com.google.android.gms \
	com.google.android.inputmethod.latin \
	com.google.android.packageinstaller \
	com.google.android.webview
google_packages_to_be_disabled = \
	com.android.vending \
	$(filter-out $(google_packages_not_to_be_disabled),$(call filter_packages_by_prefix,com.google,$(packages)))

strip_prefix = $(patsubst $(1)%,%,$(2))

.PHONY: list-devices
list-devices: ; $(ADB) devices -l

.PHONY: list-commands
list-commands: ; $(ADB) shell cmd -l

.PHONY: list-users
list-users: ; $(ADB) shell pm list users

# ---- List Packages ----

adb_ls_packages = $(ADB) shell pm list packages $(1)
strip_package = $(call strip_prefix,package:,$(1))

packages = $(sort $(call strip_package,$(shell $(call adb_ls_packages,))))
.PHONY: list-packages
list-packages: ; @echo $(packages)

enabled_packages = $(sort $(call strip_package,$(shell $(call adb_ls_packages,-e))))
.PHONY: list-enabled-packages
list-enabled-packages: ; @echo $(enabled_packages)

filter_packages_by_prefix = $(filter $(1) $(1).%,$(2))

.PHONY: list-packages-by-prefix-%
list-packages-by-prefix-%:
	@echo $(call filter_packages_by_prefix,$*,$(packages))

.PHONY: list-enabled-packages-by-prefix-%
list-enabled-packages-by-prefix-%:
	@echo $(call filter_packages_by_prefix,$*,$(enabled_packages))

# Second- or first-level domain.
sld = $(shell echo $(1) | cut -d. -f-2)

package_slds = $(sort $(foreach p,$(packages),$(call sld,$(p))))
.PHONY: list-package-second-level-domains
list-package-second-level-domains: ; @echo $(package_slds)

enabled_package_slds = $(sort $(foreach p,$(enabled_packages),$(call sld,$(p))))
# Second- and first-level domains.
.PHONY: list-enabled-package-second-level-domains
list-enabled-package-second-level-domains: ; @echo $(enabled_package_slds)

# ---- Disable Packages ----

.PHONY: disable-package-%
disable-package-%: ; $(ADB) shell pm disable-user --user $(ADB_USER_ID) $*

# TODO Review unnecessary `error: no devices/emulators found` if calling make on a target not requiring adb.
.PHONY: disable-google-packages
disable-google-packages: \
	$(foreach p,$(google_packages_to_be_disabled),disable-package-$(p)) \
	;

# ---- List Permissions ----

# As per Android 9,
# the 14 items of the screen "Settings > Apps & notifications > Special app access" are defined in `special_access.xml`.
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
# The strings associated to the `android:key` keys in the `special_access.xml` seem to be defined in
# https://raw.githubusercontent.com/aosp-mirror/platform_packages_apps_settings/android-9.0.0_r51/res/values/strings.xml
#
# The permissions are defined in `AndroidManifest.xml`.
#
# Some permissions are labelled as `appop`, and seem to be able to be revoked by `adb shell appops set ... ... deny`.
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
#
# Summary from `special_access.xml` to `AndroidManifest.xml`:
# ```
# high_power_apps              - ?
# device_administrators        - ? BIND_DEVICE_ADMIN
# system_alert_window          - SYSTEM_ALERT_WINDOW
# zen_access                   - ?
# write_settings_apps          - WRITE_SETTINGS
# notification_access          - ACCESS_NOTIFICATIONS
# picture_in_picture           - ?
# premium_sms                  - ? SEND_SMS
# data_saver                   - USE_DATA_IN_BACKGROUND
# manage_external_sources      - REQUEST_INSTALL_PACKAGES
# special_app_usage_access     - ? PACKAGE_USAGE_STATS
# enabled_vr_listeners         - ?
# special_app_directory_access - ?
# change_wifi_state            - CHANGE_WIFI_STATE
# ```
revocable_special_permissions = \
	android.permission.SYSTEM_ALERT_WINDOW \
	android.permission.WRITE_SETTINGS \
	android.permission.ACCESS_NOTIFICATIONS \
	android.permission.SEND_SMS \
	android.permission.USE_DATA_IN_BACKGROUND \
	android.permission.REQUEST_INSTALL_PACKAGES \
	android.permission.CHANGE_WIFI_STATE
.PHONY: list-revocable-special-permissions
list-revocable-special-permissions: ; @echo $(revocable_special_permissions)

promptable_special_permissions = \
	android.permission.PACKAGE_USAGE_STATS
.PHONY: list-promptable-special-permissions
list-promptable-special-permissions: ; @echo $(promptable_special_permissions)

non_revocable_special_permissions = \
	android.permission.BIND_DEVICE_ADMIN
.PHONY: list-non-revocable-special-permissions
list-non-revocable-special-permissions: ; @echo $(non_revocable_special_permissions)

special_permissions = \
	$(revocable_special_permissions) \
	$(promptable_special_permissions) \
	$(non_revocable_special_permissions)
.PHONY: list-special-permissions
list-special-permissions: ; @echo $(special_permissions)

requested_permissions_by_package = $(sort $(shell $(CURDIR)/libexec/requested_permissions $(1)))
.PHONY: list-requested-permissions-by-package-%
list-requested-permissions-by-package-%:
	@echo $(call requested_permissions_by_package,$*)

adb_ls_permissions = $(ADB) shell pm list permissions $(1)
filter_permissions = $(filter permission:%,$(1))
strip_permission = $(call strip_prefix,permission:,$(1))

permissions = $(sort $(call strip_permission,$(call filter_permissions,$(shell $(call adb_ls_permissions,-g)))))
.PHONY: list-permissions
list-permissions: ; @echo $(permissions)

dangerous_permissions = $(sort $(call strip_permission,$(call filter_permissions,$(shell $(call adb_ls_permissions,-g -d)))))
.PHONY: list-dangerous-permissions
list-dangerous-permissions: ; @echo $(dangerous_permissions)

user_permissions = $(sort $(call strip_permission,$(call filter_permissions,$(shell $(call adb_ls_permissions,-u)))))
.PHONY: list-user-permissions
list-user-permissions: ; @echo $(user_permissions)

dangerous_user_permissions = $(filter $(user_permissions),$(dangerous_permissions))
.PHONY: list-dangerous-user-permissions
list-dangerous-user-permissions: ; @echo $(dangerous_user_permissions)

# From https://source.android.com/devices/tech/config/perms-whitelist
# > Privileged apps are system apps that are located in a `priv-app` directory on one of the system image partitions.
privileged_permissions_by_package = $(sort $(subst $(comma)$(space),$(space),$(patsubst %$(right_brace),%,$(patsubst $(left_brace)%,%,$(shell $(ADB) shell pm get-privapp-permissions $(1))))))
.PHONY: list-privileged-permissions-%
list-privileged-permissions-%: ; @echo $(call privileged_permissions_by_package,$*)

# ---- Revoke Permissions ----

revoke_perm_pkg_sep = -from-
revoke_pkg = $(word 2,$(subst $(revoke_perm_pkg_sep), ,$(1)))
revoke_perm = $(word 1,$(subst $(revoke_perm_pkg_sep), ,$(1)))
.PHONY: revoke-permission-%-package
revoke-permission-%-package:
	$(if \
		$(filter $(revocable_special_permissions),$(call revoke_perm,$*)), \
		$(ADB) shell appops set $(call revoke_pkg,$*) $(patsubst android.permission.%,%,$(call revoke_perm,$*)) deny, \
		$(ADB) shell pm revoke $(call revoke_pkg,$*) $(call revoke_perm,$*))

# TODO Review unnecessary `error: no devices/emulators found` if calling make on a target not requiring adb.
.PHONY: revoke-revocable-special-permissions-from-all-packages
revoke-revocable-special-permissions-from-all-packages: \
	$(foreach p,$(packages),revoke-revocable-special-permissions-from-package-$(p)) \
	;

prefix_of_target_for_prompting_special_permission = \
	prompt-managing-special-permission-

# TODO Copy key events? https://github.com/aosp-mirror/platform_frameworks_base/blob/master/core/java/android/view/KeyEvent.java#L646
action_for_prompting_special_permission_android.permission.PACKAGE_USAGE_STATS = android.settings.USAGE_ACCESS_SETTINGS
targets_for_revoking_promptable_special_permissions = \
	$(patsubst %,$(prefix_of_target_for_prompting_special_permission)%,$(promptable_special_permissions))
.PHONY: $(targets_for_revoking_promptable_special_permissions)
$(targets_for_revoking_promptable_special_permissions): \
	$(prefix_of_target_for_prompting_special_permission)%:
	$(info This target $@ requires user action)
	$(ADB) shell input keyevent KEYCODE_WAKEUP
	$(ADB) shell am start -a $(action_for_prompting_special_permission_$*)
	@echo "Once you disable special permission $* for the applications, press any key."
	head -n 1

targets_for_revoking_non_revocable_special_permissions = \
	$(patsubst %,$(prefix_of_target_for_prompting_special_permission)%,$(non_revocable_special_permissions))
.PHONY: $(targets_for_revoking_non_revocable_special_permissions)
$(targets_for_revoking_non_revocable_special_permissions): \
	$(prefix_of_target_for_prompting_special_permission)%:
	$(info This target $@ requires user action)
	@echo "You are on your own for disabling special permission $* for the applications. Once you are done, press any key."
	head -n 1

.PHONY: prompt-managing-special-permissions
prompt-managing-special-permissions: \
	$(targets_for_revoking_promptable_special_permissions) \
	$(targets_for_revoking_non_revocable_special_permissions)

.PHONY: revoke-dangerous-permissions-from-all-packages
revoke-dangerous-permissions-from-all-packages: \
	$(patsubst %,revoke-dangerous-permissions-from-package-%,$(filter-out android com.android.bluetooth com.android.cellbroadcastreceiver com.android.companiondevicemanager com.android.defcontainer com.android.emergency com.android.externalstorage com.android.location.fused com.android.mms.service com.android.nfc,$(packages))) \
	;

.PHONY: prompt-managing-default-apps
prompt-managing-default-apps:
	$(info This target $@ requires user action)
	$(ADB) shell am start -a android.settings.MANAGE_DEFAULT_APPS_SETTINGS
	@echo "You are on your own for managing default applications. Once you are done, press any key."
	head -n 1

# ---- Misc ----

.PHONY: disable-nfc
disable-nfc:
	$(ADB) shell svc nfc disable

# ---- Secondary Expansion ----

.SECONDEXPANSION:

# ---- Revoke Permissions (Secondary Expansion) ----

.PHONY: revoke-revocable-special-permissions-from-package-%
revoke-revocable-special-permissions-from-package-%: \
	$$(foreach p,$$(filter $$(call requested_permissions_by_package,$$*),$$(revocable_special_permissions)),revoke-permission-$$(p)-from-$$*-package) \
	;

.PHONY: revoke-dangerous-permissions-from-package-%
revoke-dangerous-permissions-from-package-%: \
	$$(foreach p,$$(filter $$(call requested_permissions_by_package,$$*),$$(dangerous_permissions)),revoke-permission-$$(p)-from-$$*-package) \
	;

.PHONY: revoke-privileged-permissions-from-package-%
revoke-privileged-permissions-from-package-%: \
	$$(foreach p,$$(call privileged_permissions_by_package,$$*),revoke-permission-$$(p)-from-$$*-package) \
	;

# TODO Replace usage of foreach with patsubst in cases where it is only string replacement.
