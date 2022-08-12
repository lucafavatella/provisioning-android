.DEFAULT_GOAL = list-devices

ADB = adb

.PHONY: list-devices
list-devices: ; $(ADB) devices -l

# Reference: https://android.stackexchange.com/questions/176172/exporting-contacts-via-adb/241758#241758
.PHONY: dump-contacts
dump-contacts:
	$(ADB) shell content query --uri content://com.android.contacts/data
