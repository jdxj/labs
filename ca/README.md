# CA

## 自签

```shell
$ openssl req -new -keyout private/root-ca.key -out private/req.csr -config openssl.cnf
$ openssl ca -selfsign -keyfile private/root-ca.key -in private/req.csr -config openssl.cnf
```
## 签

```shell
$ openssl req -new -keyout rabbit/key.pem -out rabbit/req.csr -config openssl.cnf
$ openssl ca -in rabbit/req.csr -config openssl.cnf
```

## 导出p12

```shell
$ openssl pkcs12 -export -clcerts -in rabbit/pub.pem -inkey rabbit/key.pem -out rabbit/pub.p12
```