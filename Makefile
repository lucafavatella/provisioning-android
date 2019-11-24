ADB ?= $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)

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
	list-dangerous-permissions \
	;

.PHONY: sprout-provision
sprout-provision:
	-$(MAKE) -k disable-google-packages # TODO Allow error only on com.google.android.apps.work.oobconfig
	#$(MAKE) revoke-dangerous-permissions-from-all-packages

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
	echo $(packages)

packages_slds = $(sort $(foreach p,$(packages),$(shell echo $(p) | cut -d. -f-2)))
# Secondary and first level domains.
.PHONY: list-package-secondary-level-domains
list-package-secondary-level-domains:
	echo $(packages_slds)

.PHONY: disable-package-%
disable-package-%:
	$(ADB) shell pm disable-user $*

packages_by_prefix = $(filter $(1) $(1).%,$(packages))

.PHONY: disable-google-packages
disable-google-packages: disable-packages-by-prefix-com.google ;

permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g))))
.PHONY: list-permissions
list-permissions:
	echo $(permissions)

dangerous_permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions -g -d))))
.PHONY: list-dangerous-permissions
list-dangerous-permissions:
	echo $(dangerous_permissions)

# From https://source.android.com/devices/tech/config/perms-whitelist
# > Privileged apps are system apps that are located in a `priv-app` directory on one of the system image partitions.
privileged_permissions_by_package = $(sort $(subst $(comma)$(space),$(space),$(patsubst %$(right_brace),%,$(patsubst $(left_brace)%,%,$(shell $(ADB) shell pm get-privapp-permissions $(1))))))
.PHONY: list-privileged-permissions-%
list-privileged-permissions-%:
	echo $(call privileged_permissions_by_package,$*)

.PHONY: revoke-dangerous-permissions-from-package-%
revoke-dangerous-permissions-from-package-%:
	{ echo "all:" && for P in $(dangerous_permissions); do echo "	echo $(ADB) shell pm revoke $* $${P:?}"; done; } | $(MAKE) -f -

.PHONY: revoke-dangerous-permissions-from-all-packages
revoke-dangerous-permissions-from-all-packages: $(foreach p,$(packages),revoke-dangerous-permissions-from-package-$(p)) ;

.SECONDEXPANSION:

.PHONY: disable-packages-by-prefix-%
disable-packages-by-prefix-%: $$(foreach p,$$(call packages_by_prefix,$$*),disable-package-$$(p)) ;
