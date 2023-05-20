## Instructions

From https://faq.whatsapp.com/618575946635920/?cms_platform=android

> # How to restore your chat history
>
> To ensure that your chats are backed up before restoring them on a new Android device:
> 1. Open WhatsApp > More options > Settings > Chats > Chat Backup.
> 2. Choose the Google Account that you want your chats backed up to.
>    You can also create a local backup on your device.
> 3. Tap BACK UP.
>
> ...
>
> ## Restore from a local backup
>
>
> If you want to use a local backup, you'll need to transfer the files to the phone ...
>
> To restore your backup:
> 1. Download a file manager app.
> 2. In the file manager app, navigate to your local storage or sdcard > WhatsApp > Databases.
>    If your data isn't stored on an SD card, you might see "internal storage" or "main storage" instead.
>    Copy the most recent backup file to the local storage's Databases folder of your new device.
> 3. Install and open WhatsApp, then verify your number.
> 4. Tap RESTORE when prompted to restore your chats and media from the local backup.
>
> Note:
> * Your phone will store up to the last seven days worth of local backup files.
> * Local backups will be automatically created every day at 2:00 AM and saved as a file in your phone.
> * If your data isn't stored in the `/sdcard/WhatsApp/` folder, you might see "internal storage" or "main storage" folders.
>
> ## Restore a less recent local backup
>
> If you want to restore a local backup that isn't the most recent one, you'll need to do the following:
> 1. Download a file manager app.
> 2. In the file manager app, navigate to your local storage or sdcard > WhatsApp > Databases.
>    If your data isn't stored on the SD card, you might see "internal storage" or "main storage" instead.
> 3. Rename the backup file you want to restore from `msgstore-YYYY-MM-DD.1.db.crypt12` to `msgstore.db.crypt12`.
>    It's possible that an earlier backup might be on an earlier protocol, such as `crypt9` or `crypt10`.
>    Don't change the number of the crypt extension.
> 4. Uninstall and reinstall WhatsApp.
> 5. Tap RESTORE when prompted.

## Notes

The location where the backup is stored is not permitted on non-rooted devices.
And WhatsApp is not debuggable so `run-as com.whatsapp` does not work.
At least until Android 11, backup the whole app
(file name seems [constrained to `backup.ab`)](https://stackoverflow.com/questions/34482042/adb-backup-does-not-work#comment89950275_34482042):

```
adb backup -f backup.ab -noapk com.whatsapp
```

From https://android.stackexchange.com/questions/28296/how-to-fully-backup-non-rooted-devices/28315#28315
```
adb backup [-f <file>] [-apk|-noapk] [-obb|-noobb] [-shared|-noshared] [-all] [-system|nosystem] [-keyvalue|-nokeyvalue] [<packages...>]
```

Ensure that app `com.android.backupconfirm` is enabled:
```
adb shell pm enable com.android.backupconfirm
```

The resulting backup is 47B so recent com.whatsapp may be preventing backups.
