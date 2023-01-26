# provisioning-android

Structure of the repository:
* `/Makefile.*`:
  Entry points for provisioning of Android devices.
  Details below.
* `/*.mk`:
  Internal files, meant to be included by `Makefile.*` files.
  Ignore these.
* `/Makefile.android-one.contacts`:
  Entry point for exporting raw contacts.
* `/lib/scrcpy/`:
  Utility for accessing GUI of Android device via USB.
  Wrapper of tool `scrcpy` in case unable to install deps natively.
* `/doc`:
  Notes.

## Provisioning of Android Devices

### alioth

Install [LineageOS for microG](https://lineage.microg.org):
* Follow the installation instructions.
  They recommend following [the official LineageOS installation guide](https://wiki.lineageos.org/devices/alioth/install)
  (see also [forum](https://forum.xda-developers.com/t/rom-official-alioth-aliothin-12-1-lineageos-19-1.4418635/)).
* Follow the post-install instructions.
  * Self-check.
  * Enable Google cloud messaging;
    this requires also registering the device to Google services.
    * ([Push notifications do not require account registration.](https://github.com/microg/GmsCore/wiki/Helpful-Information))

Then:

```
make -f Makefile.alioth provision-alioth
```

Finally:
* In the microG settings app,
  eye-ball that the device has status registed.
* In the microG settings app,
  eye-ball that cloud messaging has status connected.

### sprout

```
make -f Makefile.sprout provision-sprout
```

For documentation of published security patches please see "Nokia 6.2" at https://www.nokia.com/phones/en_int/security-updates

### Troubleshooting

#### CA certificates

##### Symptom

```
curl: (60) SSL certificate problem: certificate has expired
```

#### Treatment

Set environment variable [`SSL_CERT_FILE`](https://manpages.debian.org/testing/openssl/openssl-env.7ssl.en.html).

E.g. if you use Homebrew you may use:
```
SSL_CERT_FILE="$(brew --prefix)/etc/ca-certificates/cert.pem" make ...
```

#### Apps not receiving push messages on LineageOS for microG

From [microG wiki](https://github.com/microg/GmsCore/wiki/Helpful-Information):
> * ...
>   Push notifications do not require account registration.
> * ...
> * Apps that use Firebase Cloud Messaging must be installed after GmsCore ...
> * If you are using AdAway, make sure to put mtalk.google.com on your whitelist ...
> * If your device is having trouble registering with Firebase Cloud Messaging,
>   you may need to open the system phone app and dial `*#*#2432546#*#*` (or `*#*#CHECKIN#*#*`)
>   to manually register the device as described [here](https://github.com/microg/android_packages_apps_GmsCore/issues/439#issuecomment-433018720).
>   if typing via the keypad does not work, [check this out](https://github.com/microg/android_packages_apps_GmsCore/issues/660):
>   (execute as root)
>   `adb shell am broadcast -a android.provider.Telephony.SECRET_CODE -d android_secret_code://2432546 --receiver-include-background`

Secret code `2432546` seems confirmed running [app Secret Codes](https://f-droid.org/packages/fr.simon.marquis.secretcodes/).

> * If you tried everything above ..., try the following steps ...:
>   1. disable both cloud messaging and Google device registration and reboot
>   2. enable only Google device registration and reboot
>   3. enable Cloud messaging and reboot

From [NanoDroid](https://gitlab.com/Nanolx/NanoDroid/-/blob/feb90370c130c6255d6e920e3facceb640ce8f20/doc/Issues.md#L136-142):
>   * when restoring the ROM from a TWRP backup GCM registration for apps is sometimes broken. You may use the following command to reset GCM/FCM connection(s). App(s) will re-register when launched afterwards:
>      * `nutl -r APPID` (eg.: APPID = `com.nianticlabs.pokemongo`) or `nutl -r` (for all applications)

[i.e.](https://gitlab.com/Nanolx/NanoDroid/-/blob/feb90370c130c6255d6e920e3facceb640ce8f20/Full/system/bin/nanodroid-util#L55-57)
(this may be useless because it may be requiring root):
```
		find /data/data/${1}/shared_prefs -name com.google.android.gms.*.xml -delete
```
or:
```
		find /data/data/*/shared_prefs -name com.google.android.gms.*.xml -delete
```

Clean storage of app `com.google.android.gms`
(app mentioned in [NanoDroid re push messages](https://gitlab.com/Nanolx/NanoDroid/-/blob/feb90370c130c6255d6e920e3facceb640ce8f20/Full/system/bin/nanodroid-util#L55-57))
i.e. app "microG Services Core".

From https://developers.google.com/cloud-messaging
> The GCM server and client APIs were removed on May 29, 2019,
> and currently any calls to those APIs can be expected to fail.
>
> ...
> For equivalent functionality,
> use [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging/),
> ...

From https://github.com/microg/GmsCore/issues/1871
on 21st Jan 2023:
> MicroG appears to not be registering itself to Google anymore.

From https://github.com/microg/GmsCore/issues/1861#issuecomment-1382719080
on Jan 14th 2023:
> The root cause seems to be a missing permission.
> ... I had to manually grant the "access network" permission in the app settings.
>
> 1. Long press on the microg icon and open the app info
> 2. Click on Network and WiFi
> 3. Grant the permission to access the network
>
> IMO this is still a valid bug, the workaround shown above should not be necessary - and definitely not in a "LineageOS with Microg" ROM.
