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
.PHONY: automatically-provision-sprout
automatically-provision-sprout: \
	disable-package-com.hmdglobal.app.fmradio \
	automatically-provision-android-one \
	;

.PHONY: manually-provision-sprout
manually-provision-sprout: \
	manually-provision-android-one \
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

# ====

include android-one.mk
