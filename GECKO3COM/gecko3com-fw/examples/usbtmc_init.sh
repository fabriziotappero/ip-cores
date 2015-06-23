#! /bin/sh
#
# usbtmc_init
#		a quick and dirty init script for the usbtmc_load
#               script. by christoph zimmermann <zac1@bfh.ch>
#
### BEGIN INIT INFO
# Provides:          usbtmc
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: loads the usbtmc kernel module and creates the devnodes
# Description:       http://labs.ti.bfh.ch/gecko/wiki/
### END INIT INFO
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="usbtmc init"
NAME="usbtmc"
module="usbtmc"

test -x $DAEMON || exit 1

case "$1" in
  start|restart)
        echo -n "Starting $DESC: "
        # Remove module from kernel (just in case it is still running)
	/sbin/rmmod $module 2> /dev/null

	# Install module
	/sbin/modprobe $module

	# Find major number used
	major=$(cat /proc/devices | grep USBTMCCHR | awk '{print $1}')
	echo Using major number $major

	# Remove old device files
	rm -f /dev/${module}[0-9]

	# Ceate new device files
	mknod /dev/${module}0 c $major 0
	mknod /dev/${module}1 c $major 1
	mknod /dev/${module}2 c $major 2
	mknod /dev/${module}3 c $major 3
	mknod /dev/${module}4 c $major 4
	mknod /dev/${module}5 c $major 5
	mknod /dev/${module}6 c $major 6
	mknod /dev/${module}7 c $major 7
	mknod /dev/${module}8 c $major 8
	mknod /dev/${module}9 c $major 9

	# Change access mode
	chmod 666 /dev/${module}0
	chmod 666 /dev/${module}1
	chmod 666 /dev/${module}2
	chmod 666 /dev/${module}3
	chmod 666 /dev/${module}4
	chmod 666 /dev/${module}5
	chmod 666 /dev/${module}6
	chmod 666 /dev/${module}7
	chmod 666 /dev/${module}8
	chmod 666 /dev/${module}9

        echo "$NAME."
        ;;
  stop)
	echo -n "Stopping $DESC: "
        # Remove module from kernel
	/sbin/rmmod $module
        echo "$NAME."
        ;;
  *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 1
        ;;
esac

exit 0