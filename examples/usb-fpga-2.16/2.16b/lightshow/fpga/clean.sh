#!/bin/bash

# This files / directories will be removed
rms="fpga.hw *.cache *.data/wt *.runs/.jobs *.runs/synth_*/* *.runs/impl_*/*"
# This files / directories in *.srcs/sources_*/ip/*/ will be removed
ip_rms="_tmp log.txt */docs */example_design */user_design/log.txt"
# Files with this extensions are not removed
keepext="vhd v xdc ucf bit bin"

# This sould not be edited.
list_files() {
    if [ "$2" != "" ]; then
	echo "$1"
	for i in $2; do
	    echo "  $i"
	done
    fi
}

check_ext() {
    f=${1##*.}
    for e in $keepext; do
	if [ "$e" = "$f" ]; then
	    return 0
	fi
    done
    return 1
}

rmfiles=""
keepfiles=""
rmdirs=""
for i in $ip_rms; do
    for j in *.srcs/sources_*/ip/*/$i; do
	if [ -d "$j" ]; then
	    rmdirs+=" $j"
	fi
	if [ -f "$j" ]; then
	    if check_ext "$j"; then
		keepfiles+=" $j"
	    else
		rmfiles+=" $j"
	    fi
	fi
    done
done    

for j in $rms; do
    if [ -d "$j" ]; then
	rmdirs+=" $j"
    fi
    if [ -f "$j" ]; then
        if check_ext "$j"; then
    	    keepfiles+=" $j"
	else
	    rmfiles+=" $j"
	fi
    fi
done

list_files "This files will NOT be removed:" "$keepfiles"
list_files "This directories will be removed:" "$rmdirs"
list_files "This files will be removed:" "$rmfiles"

if [ "$rmfiles" == "" -a "$rmdirs" == "" ]; then
    c="yes"
else    
    echo -n 'Confirm this by entering "yes": '
    read c
fi
    
if [ "$c" == "yes" ]; then
    rm -fr  *.runs/impl_*/.* 2>/dev/null
    rm -fr  *.runs/synth_*/.* 2>/dev/null
    [ "$rmfiles" != "" ] && rm $rmfiles
    [ "$rmdirs" != "" ] && rm -r $rmdirs
    exit 0
fi    
exit 1
