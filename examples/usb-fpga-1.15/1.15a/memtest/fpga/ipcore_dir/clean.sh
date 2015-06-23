#!/bin/bash

# This files / directories from this directory will not be removed
# Filenames with spaces or other spuid characters will be ignored
sourcefiles="*.vhd *.sh *.ise *.xco *.xise *.tcl"
subdirs="mem0 custom_part"

# This sould not be edited.
list_files() {
    if [ "$2" != "" ]; then
	echo "$1"
	for i in $2; do
	    echo "  $i"
	done
    fi
}

rmfiles=""
rmdirs=""
keepfiles=""
keepdirs=""
allfiles=`ls -A`
for f in $allfiles; do
    keep=false
    for i in $sourcefiles; do
	if [ "$i" == "$f" ]; then
	    keep=true
	fi
    done
    for i in $subdirs; do
	if [ "$i" == "$f" ]; then
	    keep=true
	fi
    done
    for i in $binfiles; do	# binfiles is set by distclean.sh
	if [ "$i" == "$f" ]; then
	    keep=false
	fi
    done
    if [ -d "$f" ]; then
	if $keep; then
 	    keepdirs+=" $f"
	else
 	    rmdirs+=" $f"
	fi
    fi
    if [ -f "$f" ]; then
	if $keep; then
 	    keepfiles+=" $f"
	else
 	    rmfiles+=" $f"
	fi
    fi
done    
    

echo
echo "Directory $PWD:"
list_files "This directories will NOT be removed:" "$keepdirs"
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
    [ "$rmfiles" != "" ] && rm $rmfiles
    [ "$rmdirs" != "" ] && rm -r $rmdirs

    for d in $subdirs; do
	if [ -x "$d/clean.sh" ]; then
	    cd $d
	    ./clean.sh || exit 1
	    cd ..
	fi
    done

    exit 0
fi    
exit 1
