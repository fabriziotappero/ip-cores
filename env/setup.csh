#!/bin/csh

####### finding the machine architecture ###########
#### we have a choice between 32-bit and 64-bit machines
### select the binaries according to the machines, by setting
### the coressponding environment variables.
#########################################
if ( -x /bin/uname ) then
  set p600_uplat = `/bin/uname -m`
else if ( -x /usr/bin/uname ) then
  set p600_uplat = `/usr/bin/uname -m`
else
  echo "**** ERROR: Failed to get path for uname on SunOS or Linux ***" 
  exit
endif
##################################################



set path = (/home/dinesha/download/sdcc/bin $path)

if (-d $TURBO8051_PROJ) then


else
   echo "TURBO8051_PROJ needs to be set"
endif
