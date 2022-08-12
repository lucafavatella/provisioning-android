.DEFAULT_GOAL = list-devices

ADB = adb

.PHONY: list-devices
list-devices: ; $(ADB) devices -l
