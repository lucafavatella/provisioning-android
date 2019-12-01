ADB = $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)
ADB_USER_ID = 0

MONKEYRUNNER = $(shell brew cask info android-sdk | grep monkeyrunner | cut -d' ' -f1)
$(dir $(patsubst %/,%,$(dir $(MONKEYRUNNER))))adb: | $(ADB)
	ln -s "$(word 1,$|)" "$@"

comma = ,
empty =
space = $(empty) $(empty)
left_brace = {
right_brace = }

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
	-$(MAKE) -k disable-google-packages

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

packages_by_prefix = $(filter $(1) $(1).%,$(packages))
.PHONY: list-packages-by-prefix-%
list-packages-by-prefix-%:
	@echo $(call packages_by_prefix,$*)

enabled_packages_by_prefix = $(filter $(1) $(1).%,$(enabled_packages))
.PHONY: list-enabled-packages-by-prefix-%
list-enabled-packages-by-prefix-%:
	@echo $(call enabled_packages_by_prefix,$*)

# Secondary or first level domain.
sld = $(shell echo $(1) | cut -d. -f-2)
package_slds = $(sort $(foreach p,$(packages),$(call sld,$(p))))
.PHONY: list-package-secondary-level-domains
list-package-secondary-level-domains:
	@echo $(package_slds)

enabled_package_slds = $(sort $(foreach p,$(enabled_packages),$(call sld,$(p))))
# Secondary and first level domains.
.PHONY: list-enabled-package-secondary-level-domains
list-enabled-package-secondary-level-domains:
	@echo $(enabled_package_slds)

.PHONY: disable-package-%
disable-package-%:
	$(ADB) shell pm disable-user --user $(ADB_USER_ID) $*

google_packages_not_to_be_disabled = \
	com.google.android.apps.work.oobconfig \
	com.google.android.configupdater \
	com.google.android.dialer \
	com.google.android.inputmethod.latin \
	com.google.android.webview \
	com.google.android.packageinstaller
google_packages_to_be_disabled = \
	com.android.vending \
	$(filter-out $(google_packages_not_to_be_disabled),$(call packages_by_prefix,com.google))
.PHONY: disable-google-packages
disable-google-packages: $(foreach p,$(google_packages_to_be_disabled),disable-package-$(p)) ;

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

.PHONY: revoke-privileged-permissions-from-package-%
revoke-privileged-permissions-from-package-%:
	{ echo "all:" && for P in { $(MAKE) -s list-privileged-permissions-$*; }; do echo "	echo $(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -

.PHONY: revoke-special-app-access
revoke-special-app-access:
	$(MONKEYRUNNER) lib/$@.py

# -- 8< ----

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



# https://developer.android.com/training/testing/espresso/setup#analytics
# adb shell am instrument -e disableAnalytics true


# https://developer.android.com/training/testing/ui-automator#ui-automator-apis
# https://github.com/xiaocong/uiautomator
# https://github.com/openatx/uiautomator2
# https://developer.android.com/training/testing/ui-testing/uiautomator-testing
# https://developer.android.com/training/testing/ui-automator
# UIAutomator vs Espresso: https://stackoverflow.com/questions/31076228/android-testing-uiautomator-vs-espresso/31080906#31080906
# https://github.com/appium/appium-espresso-driver
# https://github.com/appium/appium-uiautomator2-driver

# https://developer.android.com/studio/test/monkeyrunner

# https://dustingram.com/articles/2010/06/18/automated-control-of-an-android-device-with-python/

# https://pypi.org/project/cerium/


# https://github.com/ffujiawei/cerium/blob/f6e06e0dcf83a0bc924828e9d6cb81383ed2364f/cerium/androiddriver.py#L577
# https://cerium.readthedocs.io/en/latest/user/quickstart.html#interact-with-applications

https://bitbucket.org/zgoda/androidery/src/master/ - 2018
https://github.com/dtmilano/AndroidViewClient/ - 2019
https://github.com/ffujiawei/cerium - Jan 2019

https://stackoverflow.com/questions/27256911/any-faster-way-to-dump-ui-hierarchy

https://github.com/openatx/uiautomator2 (forked from `xiaocong/uiautomator`) needs https://github.com/openatx/android-uiautomator-server/
# > [UIAutomator](http://developer.android.com/tools/testing/testing_ui.html) is a
# > great tool to perform Android UI testing, but to do it, you have to write java
# > code, compile it, install the jar, and run. It's a complex steps for all
# > testers...
# > 
# > This project is to build a light weight jsonrpc server in Android device, so
# > that we can just write PC side script to write UIAutomator tests.
# > 
# > ...
# > 
# > # How to use
# > 
# > ```python
# > from uiautomator import device as d
# > 
# > d.screen.on()
# > d(text="Settings").click()
# > d(scrollable=True).scroll.vert.forward()
# > ```
# > 
# > Refer to python wrapper library [uiautomator](https://github.com/xiaocong/uiautomator).
# > 

https://github.com/swind/uiautomator (forked from `xiaocong/uiautomator`, and replaces ADB client with Python implementation) needs https://github.com/Swind/android-uiautomator-server
