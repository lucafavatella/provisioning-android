.PHONY: provision-sprout
provision-sprout: \
	automatically-provision-sprout \
	manually-provision-sprout \
	;

include sprout.non_revocable_dangerous_permissions_from_qualcomm_packages.mk
include sprout.extra_non_revocable_dangerous_permissions_from_packages.mk
EXTRA_NON_REVOCABLE_PERMISSIONS_FROM_PACKAGES = \
	$(non_revocable_dangerous_permissions_from_qualcomm_packages) \
	$(extra_non_revocable_dangerous_permissions_from_packages)
# See also https://github.com/Sid127/Nokia-Debloater/blob/b9bebce63cc28a714810dae5951864d0da093fec/shell-script.sh#L111-L194
sprout_packages_to_be_disabled = \
	$(call filter_packages_by_prefix,com.hmdglobal,$(packages)) \
	com.wos.face.service
.PHONY: automatically-provision-sprout
automatically-provision-sprout: \
	disable-hmd-packages \
	automatically-provision-android-one \
	;

.PHONY: manually-provision-sprout
manually-provision-sprout: \
	manually-provision-android-one \
	;

.PHONY: is-sprout-provisioned
is-sprout-provisioned: \
	are-hmd-packages-disabled-or-enabled-correctly \
	is-android-one-provisioned \
	;

# ==== Internal Rules and Variables ====

sprout.non_revocable_dangerous_permissions_from_qualcomm_packages.mk \
	sprout.extra_non_revocable_dangerous_permissions_from_packages.mk:
	$(warning This is a development-only target: you are on your own)
	echo > $@
	$(MAKE) $@.tmp
	mv $@.tmp $@

sprout.non_revocable_dangerous_permissions_from_qualcomm_packages.mk.tmp \
	sprout.extra_non_revocable_dangerous_permissions_from_packages.mk.tmp: \
	sprout.%.mk.tmp:
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

include android-one.pre-secondary-expansion.mk

.PHONY: disable-hmd-packages
disable-hmd-packages: \
	$(patsubst %,disable-package-%,$(sprout_packages_to_be_disabled))
	$(MAKE) are-hmd-packages-disabled-or-enabled-correctly

ifneq ($(strip $(filter-out $(packages),$(sprout_packages_to_be_disabled))),)
$(warning Misconfigured package(s) to be disabled $(filter-out $(packages),$(sprout_packages_to_be_disabled)))
endif
.PHONY: are-hmd-packages-disabled-or-enabled-correctly
are-hmd-packages-disabled-or-enabled-correctly: \
	$(patsubst %,is-package-%-disabled,$(sprout_packages_to_be_disabled)) \
	;

# ---- Secondary Expansion ----

.SECONDEXPANSION:

include android-one.post-secondary-expansion.mk
