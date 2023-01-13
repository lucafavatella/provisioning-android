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

Install [LineageOS for microG](https://lineage.microg.org),
that recommends following [the official LineageOS installation guide](https://wiki.lineageos.org/devices/alioth/install)
(see also [forum](https://forum.xda-developers.com/t/rom-official-alioth-aliothin-12-1-lineageos-19-1.4418635/)).

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
