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

include android-one.mk
