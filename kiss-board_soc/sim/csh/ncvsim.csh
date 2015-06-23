#!/bin/csh -f

ncelab -LOGFILE -ACCESS R -TIMESCALE 1ns/1ns work.$1
ncsim -NOKEY -LOGFILE ./log/$1.log work.$1

#signalscan ./shm/$1 -do ./shm/ports.do
#simvision ./shm/$1 -INPUT ./shm/ports.sv

