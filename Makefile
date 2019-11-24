ADB ?= $(shell brew cask info android-platform-tools | grep adb | cut -d' ' -f1)

comma = ,
empty =
space = $(empty) $(empty)
left_brace := {
right_brace := }

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

permissions = $(sort $(patsubst permission:%,%,$(filter permission:%,$(shell $(ADB) shell pm list permissions))))
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

.SECONDEXPANSION:

.PHONY: disable-packages-by-prefix-%
disable-packages-by-prefix-%: $$(foreach p,$$(call packages_by_prefix,$$*),disable-package-$$(p)) ;
