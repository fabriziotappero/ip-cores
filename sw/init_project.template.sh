##############################################################################
#
# Template script to set up all project-specific environemt variables.
#
# Copy this script to init_project.sh and fill in your local information.
#
# This script has to be sourced from the command line!
# Do not run it as a 'usual' program, as this does not set the variables
# in the current shell process.
#
##############################################################################

export PROJECT_DIR=<local dir>/t48
export VERIF_DIR=$PROJECT_DIR/sw/verif
export SIM_DIR=$PROJECT_DIR/sim/rtl_sim

export PATH=$PATH:$PROJECT_DIR/sw
