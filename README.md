### Docker aarch64 (arm64, armhf) Xonotic Server

**USING: xonotic-git**

If you want to just download and run the server, pull it from hub.docker.io:

```
docker pull ballerburg9005/xonotic-server-arm64
```

Please note that Xonotic dedicated server eats like 20x times the CPU that Quake 3 dedicated server does, to do virtually just the same thing. It will probably max out the CPU with 4 players in the league of Core2Quad, Rasperri Pi 3, i5-2515, s905 and similar. Because of this, please only use beefy cutting-edge Xeon / POWER7 (or better) accelerated muscle servers on the public server list!

The following instructions assume that you are cross-compiling on your PC for some ARM box.


## Docker setup
* Use root account for all commands
* Install the following packages in your distribution: docker, qemu-user-static


## Enable buildx for docker
```
 if [[  -a ~/.docker/config.json ]]; then echo "\n\nplease add it by hand\!"; else  mkdir ~/.docker/ >& /dev/null; echo '{"experimental": "enabled"}' > ~/.docker/config.json; fi
```


## Sanity check on docker builder

Check for builders and delete them.
```
docker buildx ls
docker buildx rm default
docker buildx rm somebuilder

# run this several times if the next step doesn't work out.
systemctl restart docker
docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Now it should look like this:
```
NAME/NODE DRIVER/ENDPOINT STATUS  PLATFORMS
default * docker                  
  default default         running linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

Once it looks like this and you got arm64, you can create a new builder with the docker-container driver, which gives you more features (but don't have to). However it requires you to push the package to a registry, and you can't really save it locally anymore.

```
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
```


## Building the image

``` 
docker buildx build --platform linux/arm64 -t mylocalpkg/xonotic-server .
```



## Saving and deploying the package
 
```
docker save mylocalpkg/xonotic-server | gzip > xon.gz
scp xon.gz root@192.168.0.2:/storage/

```


## Installing and running the image

SSH into your box.

```
docker load -i /storage/xon.gz
docker run --name xonotic-server -p 26000-26010:26000-26010 -p 26000-26010:26000-26010/udp --cap-add=sys_nice -v /storage/xonotic:/root/.xonotic mylocalpkg/xonotic-server
```

Add this to /etc/rc.local for start at boot

```
docker restart xonotic-server&
```


## Configuring the server

Edit the server.cfg in /storage/xonotic/data . See Xonotic documentation: https://gitlab.com/xonotic/xonotic/-/wikis/home
