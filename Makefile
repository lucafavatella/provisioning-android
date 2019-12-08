.DEFAULT_GOAL = list-devices

.PHONY: provision-sprout
provision-sprout: \
	disable-package-com.hmdglobal.app.fmradio \
	provision-android-one \
	;

.PHONY: provision-android-one
provision-android-one: \
	disable-google-packages \
	revoke-special-permissions-from-all-packages \
	; $(info Assumption: Android One systems are similar across Original Equipment Manufacturers)

ADB = $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)
ADB_USER_ID = 0

# MONKEYRUNNER = $(shell brew cask info android-sdk | grep monkeyrunner | cut -d' ' -f1)
# $(dir $(patsubst %/,%,$(dir $(MONKEYRUNNER))))adb: | $(ADB)
# 	ln -s "$(word 1,$|)" "$@"

# ==== Internal Rules and Variables ====

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

comma = ,
empty =
space = $(empty) $(empty)
left_brace = {
right_brace = }

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
.PHONY: list-package-secondary-level-domains
list-package-secondary-level-domains: ; @echo $(package_slds)

enabled_package_slds = $(sort $(foreach p,$(enabled_packages),$(call sld,$(p))))
# Second- and first-level domains.
.PHONY: list-enabled-package-secondary-level-domains
list-enabled-package-secondary-level-domains: ; @echo $(enabled_package_slds)

# ---- Disable Packages ----

.PHONY: disable-package-%
disable-package-%: ; $(ADB) shell pm disable-user --user $(ADB_USER_ID) $*

.PHONY: disable-google-packages
disable-google-packages: \
	$(foreach p,$(google_packages_to_be_disabled),disable-package-$(p)) \
	;

# ---- List Permissions ----

adb_ls_permissions = $(ADB) shell pm list permissions $(1)
strip_permission = $(call strip_prefix,permission:,$(1))

permissions = $(sort $(call strip_permission,$(shell $(call adb_ls_permissions,-g))))
.PHONY: list-permissions
list-permissions: ; @echo $(permissions)

special_permissions = \
	android.permission.SYSTEM_ALERT_WINDOW \
	android.permission.WRITE_SETTINGS
.PHONY: list-special-permissions
list-special-permissions: ; @echo $(special_permissions)

# ---- Revoke Permissions ----

.PHONY: revoke-special-permissions-from-package-%
revoke-special-permissions-from-package-%:
	{ echo ".PHONY: all" \
		&& echo "all: \\" \
		&& for P in $(special_permissions); do \
			echo "	revoke-permission-$${P:?}-from-package \\"; \
		done \
		&& echo "	;" \
		&& echo \
		&& echo ".PHONY: revoke-permission-%-from-package" \
		&& echo "revoke-permission-%-from-package:" \
		&& echo "	$(ADB) shell pm revoke $* \$$*" \
		; } \
	| $(MAKE) -f -

.PHONY: revoke-special-permissions-from-all-packages
revoke-special-permissions-from-all-packages:
	-$(MAKE) -k $(foreach p,$(packages),revoke-special-permissions-from-package-$(p))

dangerous_permissions = $(sort $(call strip_permission,$(shell $(call adb_ls_permissions,-g -d))))
.PHONY: list-dangerous-permissions
list-dangerous-permissions: ; @echo $(dangerous_permissions)

user_permissions = $(sort $(call strip_permission,$(shell $(call adb_ls_permissions,-u))))
.PHONY: list-user-permissions
list-user-permissions: ; @echo $(user_permissions)

dangerous_user_permissions = $(filter $(user_permissions),$(dangerous_permissions))
.PHONY: list-dangerous-user-permissions
list-dangerous-user-permissions: ; @echo $(dangerous_user_permissions)

.PHONY: revoke-dangerous-permissions-from-package-%
revoke-dangerous-permissions-from-package-%:
	{ echo "all:" && for P in $(dangerous_permissions); do echo "	$(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -

# From https://source.android.com/devices/tech/config/perms-whitelist
# > Privileged apps are system apps that are located in a `priv-app` directory on one of the system image partitions.
privileged_permissions_by_package = $(sort $(subst $(comma)$(space),$(space),$(patsubst %$(right_brace),%,$(patsubst $(left_brace)%,%,$(shell $(ADB) shell pm get-privapp-permissions $(1))))))
.PHONY: list-privileged-permissions-%
list-privileged-permissions-%: ; @echo $(call privileged_permissions_by_package,$*)

.PHONY: revoke-privileged-permissions-from-package-%
revoke-privileged-permissions-from-package-%:
	{ echo "all:" && for P in { $(MAKE) -s list-privileged-permissions-$*; }; do echo "	echo $(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -
