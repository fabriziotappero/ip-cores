##############################################################################
#
# Generic project compile script
#
# $Id: compile_project.tcl 295 2009-04-01 19:32:48Z arniml $
#
# Execute from within xtclsh.
#
# Environment variables:
#   $MODULE : Name of the toplevel project
#             -> mandatory <-
#   $BLD    : Build directory where the project and all temporary files
#             are stored
#             -> optional, default is "bld" <-
#
##############################################################################

# mandatory environment variable for project name: $MODULE
if {[info exists env(MODULE)]} {
    set PROJECT $env(MODULE)
    puts "Info: Setting project name from \$MODULE: $PROJECT"
} else {
    puts "Error: Environment variable MODULE not set."
    exit 1
}

# optional environment variable for build directory: $BLD
# default is 'bld'
puts -nonewline "Info: "
if {[info exists env(BLD)]} {
    set bld $env(BLD)
    puts -nonewline "Setting build directory from \$BLD"
} else {
    set bld bld
    puts -nonewline "Setting build directory to default"
}
puts ": $bld"

cd $bld

project open $PROJECT.ise

puts "Starting design implementation..."
process run "Generate Programming File"

project close
