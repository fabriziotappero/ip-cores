if [ "$1" != "" ]; then
    if [ ! -f "$1" ]; then
	echo "Usage: ./ucecho.sh [<Firmware file>]"
	exit 1
    fi
    ../../../../java/FWLoader -c -uu $1
fi

./UCEcho
