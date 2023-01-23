### Docker aarch64 (arm64, armhf) Xonotic Server

**If you want to just download and run the server, pull it from [hub.docker.io](https://hub.docker.com/r/ballerburg9005/xonotic-server-arm64).**

Please note that Xonotic dedicated server eats 10x more CPU than e.g. Quake 3 server, so a Raspberry Pi 2 can only handle about 4 players at most. Cortex processors seem to be very very bad for Xonotic in terms of performance. Please contact me if you have done tests and a different ARM processor, so I can list it here for people to know what to expect.

NEW: Check out Oracle Cloud Forever Free Tier! You get 4 super beefy dedicated Ampere/ARM cores with 24GB RAM on a 600Mbit connection in an undercrowded ARM-exclusive datacenter for $0 (no hidden cost!). More playtesting is needed to be certain but so far everything checks out A+++ . Supports more than 32 players on only one core. Sounds unbelievable, but true. Don't pick the x86 option, it sometimes sucks especially on weekends. https://youtu.be/_m21FxvuQ4c?t=258


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

Once it looks like this and you got arm64, you can create a new builder with the docker-container driver, which gives you more features (but don't have to). However it requires you to push the package to a registry, and you can't really save it locally anymore. I recommend you don't do this.

```
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
```


## Selecting Xonotic Version

Edit the Dockerfile and add those two lines after "all update -l best", if they weren't already there:

```
  cd data/xonotic-data.pk3dir && git checkout tags/xonotic-v0.8.2 && cd ../../ && \
  cd gmqcc && git checkout tags/xonotic-v0.8.2 && cd .. && \
```

There are other parts as well, like darkplaces (engine) or data-maps that you can switch the same way. But it rather seems to yield disadvantages.

If you want the latest Git version, then just make sure those two lines are not there.


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


## Performance

| Model Type                        | Processor Name     | Mem used | CPU idle | players @100% | Xonotic version | Note                        |
|-----------------------------------|--------------------|----------|----------|---------------|-----------------|-----------------------------|
| Amlogic S905D                     | Cortex A53         | 400M     | 20%      | 4             | 2020, 0.8.2     |                             |

Please contact me if you have done tests and a different ARM processor, so I can list it here for people to know what to expect.


