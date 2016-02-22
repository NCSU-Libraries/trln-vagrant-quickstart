#!/bin/sh

if [ "$1" == "clean" ]; then
	echo "Removing downloaded binary packages"
	scripts/clean.sh
	echo "Done."
	exit 0
fi

echo "Fetching packages needed for setup and configuring puppet environment"
cd scripts
./quickstart.sh

echo "Now initializing vagrant box.  This will probably take a while!"

cd ..
vagrant up --provider=virtualbox


