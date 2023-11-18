# CA

## openssl相关命令介绍

生成私钥

```bash
$ openssl genrsa -out pri_key.pem
```

生成证书请求

```bash
# "-new"表示新生成一个新的证书请求文件
# "-key"指定私钥文件
# "-out"指定输出文件
# 运行后进入交互, 填一些信息
$ openssl req -new -key pri_key.pem -out req1.csr

# 不指定私钥会自动生成, 但是会被要求指定密码加密私钥
$ openssl req -new -out req3.csr
# 使用"-nodes"选项禁止加密私钥文件
$ openssl req -new -out req3.csr -nodes
# "-keyout"选项指定私钥保存路径
$ openssl req -new -out req3.csr -nodes -keyout myprivkey.pem

# 自动生成私钥时, 指定私钥算法和长度
$ openssl req -newkey rsa:2048 -out req3.csr -nodes -keyout myprivkey.pem
```

查看证书请求

```bash
# "-in"选项指定的是证书请求文件
# "-text"选项表示以文本格式输出证书请求文件的内容
# 将"-text"和"-noout"结合使用，则只输出证书请求的文件头部分
# -subjec 只输出subject部分的内容
# "-pubkey"输出证书请求文件中的公钥内容
$ openssl req -in req1.csr
```

指定请求文件签名时使用的算法

```bash
$ openssl req -new -key pri_key.pem -out req2.csr -md5
# 查看支持的算法
$ openssl dgst -list
```

验证请求文件

```bash
# 不想输出证书请求，使用"-noout"选项
$ openssl req -verify -in req1.csr
```

## 自签证书(根CA)

```bash
# 使用openssl req自签署证书时，需要使用"-x509"选项
# 由于是签署证书请求文件，所以可以指定"-days"指定所颁发的证书有效期
$ openssl req -x509 -key pri_key.pem -in req1.csr -out CA1.crt -days 365
```

跳过生成证书请求的步骤, 直接自签

```bash
$ openssl req -new -x509 -key pri_key.pem -out CA1.crt -days 365
```

## 使用配置文件自签

```shell
$ openssl req -new -keyout private/root-ca.key -out private/req.csr -config openssl.cnf
$ openssl ca -selfsign -keyfile private/root-ca.key -in private/req.csr -config openssl.cnf
```
## 为其他证书请求签名

```shell
$ openssl req -new -keyout rabbit/key.pem -out rabbit/req.csr -config openssl.cnf
$ openssl ca -in rabbit/req.csr -config openssl.cnf
```

## 导出p12

```shell
$ openssl pkcs12 -export -clcerts -in rabbit/pub.pem -inkey rabbit/key.pem -out rabbit/pub.p12
```
