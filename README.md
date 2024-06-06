# labs

```shell
iptables -I INPUT -p all -s 179.60.149.183 -j DROP
```

```shell
0 0 1 * * /usr/bin/certbot renew --force-renewal

certbot certonly --standalone -d a.com -m 'b@c.com'
```
