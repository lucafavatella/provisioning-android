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
* Ensure that the microG app,
  i.e. the `com.google.android.gms` app,
  in the app info (long press the app icon)
  has network access enabled.
  (This step [shall not](https://github.com/microg/GmsCore/issues/1861#issuecomment-1382719080) be necessary.)
* In the microG settings app,
  eye-ball that the device has status registed.
* In the microG settings app,
  eye-ball that cloud messaging has status connected.

Then:

```
make -f Makefile.alioth provision-alioth
```

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
