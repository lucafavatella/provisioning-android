ADB ?= $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)
ADB_USER_ID ?= 0

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

.PHONY: disable-google-packages
disable-google-packages: disable-packages-by-prefix-com.android.vending disable-packages-by-prefix-com.google ;
#com.android.vending com.google.android.apps.docs com.google.android.apps.googleassistant com.google.android.apps.magazines com.google.android.apps.maps com.google.android.apps.messaging com.google.android.apps.nbu.files com.google.android.apps.photos com.google.android.apps.restore com.google.android.apps.subscriptions.red com.google.android.apps.turbo com.google.android.apps.wallpaper com.google.android.apps.wellbeing com.google.android.apps.work.oobconfig com.google.android.as com.google.android.backuptransport com.google.android.calendar com.google.android.configupdater com.google.android.contacts com.google.android.deskclock com.google.android.dialer com.google.android.ext.services com.google.android.ext.shared com.google.android.feedback com.google.android.gm com.google.android.gms com.google.android.gms.policy_sidecar_aps com.google.android.gmsintegration com.google.android.googlequicksearchbox com.google.android.gsf com.google.android.ims com.google.android.inputmethod.latin com.google.android.marvin.talkback com.google.android.onetimeinitializer com.google.android.packageinstaller com.google.android.partnersetup com.google.android.printservice.recommendation com.google.android.setupwizard com.google.android.syncadapters.contacts com.google.android.tag com.google.android.tts com.google.android.webview com.google.android.youtube com.google.ar.lens

permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g))))
.PHONY: list-permissions
list-permissions:
	@echo $(permissions)

dangerous_permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g -d))))
.PHONY: list-dangerous-permissions
list-dangerous-permissions:
	@echo $(dangerous_permissions)

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
