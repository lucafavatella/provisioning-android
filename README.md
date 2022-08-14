# provisioning-android

## alioth

Install [LineageOS](https://wiki.lineageos.org/devices/alioth/install) (see also [forum](https://forum.xda-developers.com/t/rom-official-alioth-aliothin-12-1-lineageos-19-1.4418635/)).

## sprout

```
make -f sprout.mk provision-sprout
```

For documentation of published security patches please see "Nokia 6.2" at https://www.nokia.com/phones/en_int/security-updates

## Troubleshooting

### CA certificates

#### Symptom

```
curl: (60) SSL certificate problem: certificate has expired
```

#### Treatment

Set environment variable [`SSL_CERT_FILE`](https://manpages.debian.org/experimental/openssl/openssl-env.7ssl.en.html).

E.g. if you use Homebrew you may use:
```
SSL_CERT_FILE="$(brew --prefix)/etc/ca-certificates/cert.pem" make ...
```
