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

export PROJECT_DIR=<local dir>/t400
export MAKEFILES=$PROJECT_DIR/sw/verif/include/Makefile
