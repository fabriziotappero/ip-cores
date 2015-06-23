#!/bin/sh

echo "*idn?" > /dev/usbtmc1

BOARD=$(cat /dev/usbtmc1)

if [ "$?" = 0 ]; 
then
    kdialog --caption="GECKO3COM" \
	--msgbox "Welcome to the GECKO3COM configuration tool\n Ready to configure board:\n$BOARD" \
	--title "Ready"
    
    FILE=$(kdialog --getopenfilename :label1 "*.bit" --caption "GECKO3COM" \
	--title "Select FPGA *bit file to download")
    if [ "$?" = 0 ]; 
    then
	
	dcopRef=$(kdialog --progressbar "Configuring FPGA..."  --caption="GECKO3COM" 10)

	echo -n "fpga:conf " > /tmp/fpga_conf.dat
	cat "$FILE" >> /tmp/fpga_conf.dat

	dcop $dcopRef setProgress 2

	cp /tmp/fpga_conf.dat /dev/usbtmc1 | dcop $dcopRef setProgress 8

	dcop $dcopRef close

	if [ "$?" = 0 ]; 
	then
	    
	    echo "fpga:done?" > /dev/usbtmc1
	    RESULT=$(cat /dev/usbtmc1)
	    
	    if [ "$?" = 0 ] && [ "$RESULT" = 1 ]; 
	    then
		kdialog --msgbox "Successfully configured!" --title "Finished" --caption="GECKO3COM";
	    else
		kdialog --error "FPGA is not done.\nConfiguration failed!" --caption="GECKO3COM"

		usbtmc_ioctl 1 clear
		echo "*idn?" > /dev/usbtmc1;
	    fi;
	else
	    kdialog --error "Failed to configure FPGA" --caption="GECKO3COM"
	    usbtmc_ioctl 1 clear
	    echo "*idn?" > /dev/usbtmc1;
	fi

	rm /tmp/fpga_conf.dat;
    fi;

else
    kdialog --sorry "No FPGA board found!" --caption="GECKO3COM"
    usbtmc_ioctl 1 clear
    echo "*idn?" > /dev/usbtmc1;
fi;


