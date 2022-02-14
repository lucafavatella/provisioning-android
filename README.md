# provisioning-android

## sprout

```
make provision-sprout
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
