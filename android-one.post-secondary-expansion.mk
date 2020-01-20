# Prefer "foreach" to "patsubst" as error "No rule to make target" experienced.

# ---- Revoke Permissions (Secondary Expansion) ----

.PHONY: revoke-dangerous-permissions-from-package-%
revoke-dangerous-permissions-from-package-%: \
	$$(foreach p,$$(filter $$(call permissions_requested_by_package,$$*),$$(dangerous_permissions)),revoke-permission-$$(p)-from-$$*-package) \
	;

per_package_targets_for_not_revoking_non_revocable_permissions_from_packages = \
	$(filter \
		revoke-permission-%$(revoke_perm_pkg_sep)$(1)-package, \
		$(targets_for_not_revoking_non_revocable_permissions_from_packages))
per_package_non_revocable_permissions = \
	$(patsubst \
		revoke-permission-%-from-$(1)-package,%, \
		$(call per_package_targets_for_not_revoking_non_revocable_permissions_from_packages,$(1)))
.PHONY: are-dangerous-permissions-revoked-from-package-%
are-dangerous-permissions-revoked-from-package-%: \
	$$(foreach \
		p, \
		$$(filter-out \
			$$(call per_package_non_revocable_permissions,$$*), \
			$$(filter \
				$$(call permissions_requested_by_package,$$*), \
				$$(dangerous_permissions))), \
		is-permission-$$(p)-revoked-from-$$*-package) \
	;

# ---- Revoke Special Accesses: Automatic (Secondary Expansion) ----

.PHONY: revoke-revocable-special-permissions-from-package-%
revoke-revocable-special-permissions-from-package-%: \
	$$(foreach p,$$(filter $$(call permissions_requested_by_package,$$*),$$(revocable_special_permissions)),revoke-permission-$$(p)-from-$$*-package) \
	;

.PHONY: are-revocable-special-permissions-revoked-from-package-%
are-revocable-special-permissions-revoked-from-package-%: \
	$$(foreach p,$$(filter $$(call permissions_requested_by_package,$$*),$$(revocable_special_permissions)),is-permission-$$(p)-revoked-from-$$*-package) \
	;
