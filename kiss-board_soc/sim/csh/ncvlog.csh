#!/bin/csh -f

#ncvlog -NOLOG -WORK work \
#-DEFINE SHM \
#-DEFINE SHMNAME=\"./shm/$1\" \
#./pat/$1.v

ncvlog -NOLOG -WORK work $*

#ncelab -NOLOG -ACCESS R -TIMESCALE 1ns/1ns work.test
#ncsim -NOKEY -LOGFILE ./log/$1.log work.test

#signalscan ./shm/$1 -do ./shm/ports.do
#simvision ./shm/$1 -INPUT ./shm/ports.sv

