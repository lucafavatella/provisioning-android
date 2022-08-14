.PHONY: configure-com.fsck.k9.apk
configure-com.fsck.k9.apk: configure-%.apk:
	$(adb_wakeup)
	@echo "Once you configure application $*, press the enter key."
	@echo "* Settings > General settings > Interaction > Confirm actions: Tick all"
	@head -n 1

