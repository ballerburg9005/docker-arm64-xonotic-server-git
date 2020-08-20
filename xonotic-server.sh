#!/bin/sh

mkdir -p ~/.xonotic/data

if ! test -f ~/.xonotic/data/server.cfg; then
	cp -r /xonotic/server ~/.xonotic/ 
	cp /xonotic/server/server.cfg ~/.xonotic/data/server.cfg
fi

rm ~/.xonotic/lock

while true; do
	nice -10 ./darkplaces-dedicated -xonotic +serverconfig
done