#####################################################################
#
# First Encounter setup file
# Created by Encounter(R) RTL Compiler on 08/31/09 11:31:49
#
#####################################################################


# This script is intended for use with Encounter version 4.2 or later.
#   Multiple timing modes require Encounter version 5.2 or later.
#   CPF requires Encounter version 6.2 or later.


# Design Import
###########################################################
loadConfig /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp_io.conf
defIn /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp_io.scan.def


# Mode Setup
###########################################################
source /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp_io.mode


# The following is partial list of suggested prototyping commands.
# These commands are provided for reference only.
# Please consult the First Encounter documentation for more information.
#   Placement...
#     ecoPlace                     ;# legalizes placement including placing any cells that may not be placed
#     - or -
#     placeDesign -incremental     ;# adjusts existing placement
#     - or -
#     placeDesign                  ;# performs detailed placement discarding any existing placement
#   Optimization & Timing...
#     optDesign -preCTS            ;# performs trial route and optimization
