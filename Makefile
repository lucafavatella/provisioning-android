ADB ?= $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)
ADB_USER_ID ?= 0

MONKEYRUNNER ?= $(shell brew cask info android-sdk | grep monkeyrunner | cut -d' ' -f1)

comma = ,
empty =
space = $(empty) $(empty)
left_brace := {
right_brace := }

.PHONY: sprout-report
sprout-report: \
	list-devices \
	list-users \
	list-package-secondary-level-domains \
	list-enabled-package-secondary-level-domains \
	list-enabled-packages \
	list-dangerous-permissions \
	;

.PHONY: sprout-provision
sprout-provision:
	-$(MAKE) -k disable-google-packages # TODO Allow error only on com.google.android.apps.work.oobconfig
	echo $(MAKE) revoke-dangerous-permissions-from-all-packages
	echo $(MAKE) revoke-privileged-permissions-from-all-packages

.PHONY: list-devices
list-devices:
	$(ADB) devices -l

.PHONY: list-commands
list-commands:
	$(ADB) shell cmd -l

.PHONY: list-users
list-users:
	$(ADB) shell pm list users

packages = $(sort $(patsubst package:%,%,$(shell $(ADB) shell pm list packages)))
.PHONY: list-packages
list-packages:
	@echo $(packages)

enabled_packages = $(sort $(patsubst package:%,%,$(shell $(ADB) shell pm list packages -e)))
.PHONY: list-enabled-packages
list-enabled-packages:
	@echo $(enabled_packages)

package_slds = $(sort $(foreach p,$(packages),$(shell echo $(p) | cut -d. -f-2)))
# Secondary and first level domains.
.PHONY: list-package-secondary-level-domains
list-package-secondary-level-domains:
	@echo $(package_slds)

enabled_package_slds = $(sort $(foreach p,$(enabled_packages),$(shell echo $(p) | cut -d. -f-2)))
# Secondary and first level domains.
.PHONY: list-enabled-package-secondary-level-domains
list-enabled-package-secondary-level-domains:
	@echo $(enabled_package_slds)

.PHONY: disable-package-%
disable-package-%:
	$(ADB) shell pm disable-user --user $(ADB_USER_ID) $*

packages_by_prefix = $(filter $(1) $(1).%,$(packages))
.PHONY: list-packages-by-prefix-%
list-packages-by-prefix-%:
	@echo $(call packages_by_prefix,$*)

# com.google.android.configupdater \
# com.google.android.dialer \
# com.google.android.inputmethod.latin \
# com.google.android.webview \
# com.google.android.packageinstaller \
.PHONY: disable-google-packages
#disable-google-packages: disable-packages-by-prefix-com.android.vending disable-packages-by-prefix-com.google ;
disable-google-packages: $(patsubst %,disable-packages-by-prefix-%, \
		com.android.vending \
		com.google.android.apps.docs \
		com.google.android.apps.googleassistant \
		com.google.android.apps.magazines \
		com.google.android.apps.maps \
		com.google.android.apps.messaging \
		com.google.android.apps.nbu.files \
		com.google.android.apps.photos \
		com.google.android.apps.restore \
		com.google.android.apps.subscriptions.red \
		com.google.android.apps.turbo \
		com.google.android.apps.wallpaper \
		com.google.android.apps.wellbeing \
		com.google.android.apps.work.oobconfig \
		com.google.android.as \
		com.google.android.backuptransport \
		com.google.android.calendar \
		com.google.android.contacts \
		com.google.android.deskclock \
		com.google.android.ext.services \
		com.google.android.ext.shared \
		com.google.android.feedback \
		com.google.android.gm \
		com.google.android.gms \
		com.google.android.gms.policy_sidecar_aps \
		com.google.android.gmsintegration \
		com.google.android.googlequicksearchbox \
		com.google.android.gsf \
		com.google.android.ims \
		com.google.android.marvin.talkback \
		com.google.android.onetimeinitializer \
		com.google.android.partnersetup \
		com.google.android.printservice.recommendation \
		com.google.android.setupwizard \
		com.google.android.syncadapters.contacts \
		com.google.android.tag \
		com.google.android.tts \
		com.google.android.youtube \
		com.google.ar.lens \
		)

permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g))))
.PHONY: list-permissions
list-permissions:
	@echo $(permissions)

dangerous_permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g -d))))
.PHONY: list-dangerous-permissions
list-dangerous-permissions:
	@echo $(dangerous_permissions)

user_permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -u))))
.PHONY: list-user-permissions
list-user-permissions:
	@echo $(user_permissions)

dangerous_user_permissions = $(filter $(user_permissions),$(dangerous_permissions))
.PHONY: list-dangerous-user-permissions
list-dangerous-user-permissions:
	@echo $(dangerous_user_permissions)

# From https://source.android.com/devices/tech/config/perms-whitelist
# > Privileged apps are system apps that are located in a `priv-app` directory on one of the system image partitions.
privileged_permissions_by_package = $(sort $(subst $(comma)$(space),$(space),$(patsubst %$(right_brace),%,$(patsubst $(left_brace)%,%,$(shell $(ADB) shell pm get-privapp-permissions $(1))))))
.PHONY: list-privileged-permissions-%
list-privileged-permissions-%:
	@echo $(call privileged_permissions_by_package,$*)

.PHONY: revoke-dangerous-permissions-from-package-%
revoke-dangerous-permissions-from-package-%:
	{ echo "all:" && for P in $(dangerous_permissions); do echo "	$(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -

.PHONY: revoke-dangerous-permissions-from-all-packages
revoke-dangerous-permissions-from-all-packages: $(foreach p,$(packages),revoke-dangerous-permissions-from-package-$(p)) ;

.PHONY: revoke-privileged-permissions-from-package-%
revoke-privileged-permissions-from-package-%:
	{ echo "all:" && for P in { $(MAKE) -s list-privileged-permissions-$*; }; do echo "	echo $(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -

.PHONY: revoke-privileged-permissions-from-all-packages
revoke-privileged-permissions-from-all-packages: $(foreach p,$(packages),revoke-privileged-permissions-from-package-$(p)) ;

.SECONDEXPANSION:

.PHONY: disable-packages-by-prefix-%
disable-packages-by-prefix-%: $$(foreach p,$$(call packages_by_prefix,$$*),disable-package-$$(p)) ;


# As per Android 9, the 14 items of the screen "Settings > Apps & notifications > Special app access" are defined in
# https://github.com/aosp-mirror/platform_packages_apps_settings/blob/android-cts-9.0_r10/res/xml/special_access.xml
# e.g.
# Device admin apps -> android:key="device_administrators" android:fragment="com.android.settings.DeviceAdminSettings"
# Modify system setings -> android:key="write_settings_apps"
# Premium SMS access -> android:key="premium_sms"
# Unrestricted data -> android:key="data_saver"
# Install unknown apps -> android:key="manage_external_sources"
# Usage access -> android:key="special_app_usage_access"
# Directory access -> android:key="special_app_directory_access"
# Wi-Fi control -> android:key="change_wifi_state"
# ```
# $ curl -LsSf https://raw.githubusercontent.com/aosp-mirror/platform_packages_apps_settings/android-cts-9.0_r10/res/xml/special_access.xml | grep '\(android:key\|android:fragment\|settings:keywords\)='
#         android:key="special_app_access_screen"
#         android:key="high_power_apps"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_ignore_optimizations">
#         android:key="device_administrators"
#         android:fragment="com.android.settings.DeviceAdminSettings" />
#         android:key="system_alert_window"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_system_alert_window">
#         android:key="zen_access"
#         android:fragment="com.android.settings.notification.ZenAccessSettings" />
#         android:key="write_settings_apps"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_write_settings">
#         android:key="notification_access"
#         android:fragment="com.android.settings.notification.NotificationAccessSettings" />
#         android:key="picture_in_picture"
#         android:fragment="com.android.settings.applications.appinfo.PictureInPictureSettings"
#         settings:keywords="@string/picture_in_picture_keywords" />
#         android:key="premium_sms"
#         android:fragment="com.android.settings.applications.PremiumSmsAccess" />
#         android:key="data_saver"
#         android:fragment="com.android.settings.datausage.UnrestrictedDataAccess" />
#         android:key="manage_external_sources"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_install_other_apps">
#         android:key="special_app_usage_access"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_write_settings">
#         android:key="enabled_vr_listeners"
#         android:fragment="com.android.settings.applications.VrListenerSettings"
#         settings:keywords="@string/keywords_vr_listener">
#         android:key="special_app_directory_access"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_directory_access">
#         android:key="change_wifi_state"
#         android:fragment="com.android.settings.applications.manageapplications.ManageApplications"
#         settings:keywords="@string/keywords_change_wifi_state">
# ```

# Strings associated to the android:key are defined in https://github.com/aosp-mirror/platform_packages_apps_settings/blob/android-cts-9.0_r10/res/values/strings.xml#L8824
# e.g.
# Search for `change_wifi_state`, find also <string name="change_wifi_state_title">Wi-Fi control</string>
