# multi-stage docker file

### stage 1: builds xonotic in /xonotic
FROM ubuntu:latest
WORKDIR /

# follow steps here https://gitlab.com/xonotic/xonotic/-/wikis/Repository_Access
# added "zip" to apt-get list

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -yq install autoconf build-essential curl git libtool libgmp-dev libjpeg-turbo8-dev libsdl2-dev libxpm-dev xserver-xorg-dev zlib1g-dev unzip zip && \ 
  git clone git://git.xonotic.org/xonotic/xonotic.git && \
  mv xonotic xonotic-git && \
  cd xonotic-git && \
  ./all update -l best && \
  MAKEFLAGS="-j8" ./all compile -r dedicated && \
  ( rm -rf data/xonotic-music.pk3dir data/*/textures data/*/sound data/*/gfx data/*/env || true ) && \
  ( find data/ -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.jpeg' -o -iname '*.tga' -o -iname '*.png' -o -iname '*.wav' -o -iname '*.ogg' -o -iname '*.mp3' -o -iname '*.dem' \) -exec rm '{}' \; || true ) && \
  ( find data -name .git -type d -exec rm -r '{}' \; || true  ) && \
  cd data/xonotic-data.pk3dir && zip -r ../xonotic-data.pk3 . && \
  cd ../../ && \
  cd data/xonotic-maps.pk3dir && zip -r ../xonotic-maps.pk3 . && \
  cd ../../ && \
  mkdir -p /xonotic/data && \
  mv data/*.pk3 /xonotic/data && \ 
  cp -r server darkplaces/darkplaces-dedicated /xonotic/ && \
  cp -r /xonotic-git/d0_blind_id/.libs/ /xonotic/libs

### stage 2: runs xonotic server in fresh environment

FROM ubuntu:latest

COPY --from=0 /xonotic /xonotic
WORKDIR /
#COPY xonotic /xonotic
COPY --from=0 /xonotic/libs /lib/
COPY --from=0 /xonotic/libs/blind_id /bin/

WORKDIR /xonotic

RUN \ 
   apt-get update && \
   apt-get -y install libjpeg-turbo8 zlib1g

## needs pip, installs like 250MB extra dependencies 
## better manage packages on your PC, then just rsync the folder to your box

#RUN git clone https://github.com/z/xonotic-map-manager /opt/xmm && \
#    cd /opt/xmm/ && \
#    mkdir ~/.xmm && \
#    pip3 install --upgrade pip && \
#    python3 setup.py install

#COPY xmm/xmm.cfg ~/.xmm.cfg
#COPY xmm/servers.json ~/.xmm/servers.json

COPY xonotic-server.sh xonotic-server.sh


EXPOSE 26000-26010
EXPOSE 26000-26010/udp 

CMD ["./xonotic-server.sh"]

