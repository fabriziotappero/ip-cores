#!/bin/sh
#
# script to perform 2 steps of sc2v for input module 
# and remove temporary files
#
# usage: sc2v <filename_without_extension>
#
../bin/sc2v_step1 < $1.cpp
../bin/sc2v_step2 < $1.h > $1.sc2v
../bin/sc2v_step3 < $1.sc2v > $1.v
\rm *.sc2v
