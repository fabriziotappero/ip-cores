# --------------------------------------------------------------------------
# Author:   Jonathon W. Donaldson
# Rev-Mod:  $Id: impact_opt.cmd,v 1.1 2008-11-07 00:52:52 jwdonal Exp $
#
# Description: This is the batch file command set for the iMPACT tool.
# --------------------------------------------------------------------------

setMode -bscan
setCable -p auto
identify
assignfile -p 3 -file results/lq057q3dc02_top.bit
program -p 3
quit
