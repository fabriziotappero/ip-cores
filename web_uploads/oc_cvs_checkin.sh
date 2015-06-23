#!/bin/bash
#oc_cvs_checkin.sh

echo "#!/bin/bash"
echo "# AUTOMATICALLY GENERATED SCRIPT"
echo "# Scans the cores directory, excludes the projects and subdirectories"
echo "# listed below, and generates a script which checks in all of the "
echo "# remaining files to the SVN repository"
echo "# This should be run and the output piped to a new file something like:"
echo "# ./oc_cvs_checkin.sh > checkin_script.sh"
echo "# and then probably the execute permission enabled on checkin_script.sh"

DO_CHECKIN="1"
DIRECTORY_HAS_CONTENTS="1"

echo "# Encapsulate the checkins inside this loop we can "
echo "# break out of in the event of a problem checking" 
echo "# one of them in"
echo ""
echo "# Function to check the return value of each SVN checkin"
echo "function check_svn_return_value { if [ \$? -gt 1 ]; then echo \"Error during checkins - aborting script.\"; exit 1; fi"
echo "}"
echo "ALL_DONE=\"0\""
echo "while [ \$ALL_DONE = 0 ]; do"
for PROJECT in *; do
    DO_CHECKIN="1"
    DIRECTORY_HAS_CONTENTS="1"
    if [ -d "$PROJECT" ] # Check if we're looking at a directory
    then
	# A list of projects we don't want to checkin
	#  automatically, they will be done manually
	if [ "$PROJECT" = "or1k" ]; then DO_CHECKIN="0" ; fi
	if [ "$PROJECT" = "or1k-backup" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "or1200-gct" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "or2k" ]; then DO_CHECKIN="0"; fi
	
	# The following need to be checked in to the repository
	# with a slightly different name to its directory name
	if [ "$PROJECT" = "8051" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "ac97" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "DebugInterface" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "ethmac" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "mips" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "uart" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "usb" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "miniuart2" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "video_systems" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "microriscii" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "oc54x" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "divider" ]; then DO_CHECKIN="0"; fi
	if [ "$PROJECT" = "hsca_adder" ]; then DO_CHECKIN="0"; fi
	# Bug with this project when using this script, so don't check it in
	if [ "$PROJECT" = "ae68" ]; then DO_CHECKIN="0"; fi
	
	if [ $DO_CHECKIN -gt 0 ]
	then
	    cd "$PROJECT"
	    # Now we're in the project subdirectory, we 
	    # want to checkin everything apart from the
	    # stats and lint directories
	
	
	    # This pushd and the following popd make the script 
	    # change into the right directory to do the checkin
	    # The command above runs an ls and word count (wc)
            # and strips the whitespace to determine the number
	    # of files in the directory. An empty one with just
	    # a stats dir has a value of 4, so if it's more than
	    # that, odds are we have something to checkin.
	    #if [ `ls | wc -l | sed 's/^[ ]*//'` -gt 3 ]
	    #then		
	    echo "    pushd \"$PROJECT\""
       	    #    echo "$PROJECT"
	    #else
		#DIRECTORY_HAS_CONTENTS="0"
	    #fi
	    
	    # Only go through the directory checking if
	    # there's things in there
	    #if [ $DIRECTORY_HAS_CONTENTS -gt 0 ]
	    #then
		for PROJ_FILE in *; do
		    DO_CHECKIN="1"
		    if [ "$PROJ_FILE" = "stats" ]; then DO_CHECKIN="0"; fi
		    if [ "$PROJ_FILE" = "lint" ]; then DO_CHECKIN="0"; fi
		    if [ $DO_CHECKIN -gt 0 ]
		    then
		        #Do checkin
		        #echo "#Checking in $PROJECT/$PROJ_FILE"		    
		        echo "    svn import -m \"Import from OC\" \"$PROJ_FILE\" \"http://orsoc.se:4488/svn/$PROJECT/$PROJ_FILE\""
			echo "    check_svn_return_value"
		    #else
		        #echo "#Excluding $PROJ_FILE from checkin of $PROJECT"
		    fi
		done
		# We now write out the popd to change back to the main dir
		# in the script
		echo "    popd"
		#if [ $DIRECTORY_HAS_CONTENTS -gt 0 ]; then echo "$PROJECT"; fi
	    #fi #if [ $DIRECTORY_HAS_CONTENTS -gt 0 ]
	    cd ..
	    
	#else
	    #echo "#Excluding project $PROJECT from checkin!"
	fi #if [ $DO_CHECKIN -gt 0 ]
    fi #if [ -d "$PROJECT" ]
done
echo "    ALL_DONE=\"1\""
echo "    echo \"All checkins done\""
echo "done"


