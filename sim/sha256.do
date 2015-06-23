#---------------------------------------------------------------------
# Project name         : SHA-256
# Project description  : Secure Hash Algorithm (SHA-256)
#
# File name            : sha256.do
#
# Design Engineer      : marsgod
# Quality Engineer     : marsgod
# Version              : 1.0
# Last modification    : 2004-05-10
#---------------------------------------------------------------------

transcript off
# ------------------------------------------------------------------- #
# Directories location
# ------------------------------------------------------------------- #

set source_dir rtl
set tb_dir     bench
set work_dir   sim/modelsim_lib

# ------------------------------------------------------------------- #
# Maping destination directory for core of model
# ------------------------------------------------------------------- #

vlib $work_dir
vmap SHA_LIB $work_dir
transcript on


# ------------------------------------------------------------------- #
# Compiling components of core
# ------------------------------------------------------------------- #

transcript off
vlog -work SHA_LIB +incdir+$source_dir $source_dir/sha256.v


# ------------------------------------------------------------------- #
# Compiling Test Bench
# ------------------------------------------------------------------- #

vlog  -work SHA_LIB $tb_dir/test_sha256.v

transcript on


# ------------------------------------------------------------------- #
# Loading the Test Bench
# ------------------------------------------------------------------- #

transcript off
vsim +nowarnTFMPC +nowarnTSCALE -t ns -lib SHA_LIB test_sha

transcript on


transcript on

do wave.do

run 1ms
