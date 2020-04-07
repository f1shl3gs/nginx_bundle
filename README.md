## Nginx Bundle
It's a bundle of sources for build nginx, but it is not another Openresty.

## Build

```shell script
make 
```
the default prefix is `/usr/local/nginx`, 
but you can set nginx prefix manully by
```shell script
make PREFIX=/path/to/your/prefix
```

then you'll get a executable shell file looks like
`nginx_1.X.X_2020.01.02.run`

## Install or Update
1. cp the `nginx_xxxx.run` file to your machine
 and run it with super privileges(as root)
 
 ```shell script
sudo ./nginx_xxxx_xxxx.run
```

## Control
service unit file or init script is contained in the package,
and the service will start after boot by default,
you cat start/stop nginx
```shell script
systemctl [start|stop] nginx
```
or 
```shell script
service nginx [start|stop]
```
