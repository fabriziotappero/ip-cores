#-----------------------------------------------------------------------------#
#                                                                             #
#                         M A C R O    F I L E                                #
#                          COPYRIGHT (C) 2006                                 #
#                                                                             #
#-----------------------------------------------------------------------------#
#-
#- Title       : RUNSIM_TIMING.DO
#- Design      : MDCT Core
#- Author      : Michal Krepa
#-
#-----------------------------------------------------------------------------
#-
#- File        : RUNSIM_TIMING.DO
#- Created     : Sat Apr 12 2006
#-
#-----------------------------------------------------------------------------
#-
#-  Description : ModelSim macro for running simulation (timing)
#-
#-----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
# Start simulation                                                           #
# -------------------------------------------------------------------------- #
  do SOURCE/TESTBENCH/COMPILE_TIMING.DO
  
  vsim -t ps -sdftyp /tb_mdct/u_mdct=SYNTHESIS/PRECISION/PROJECT_1_IMPL_1/MDCT_OUT.SDF WORK.CONF_MDCT_TIMING  	
  do SOURCE/TESTBENCH/WAVE_TIM.DO

  while {[exa testend_s] == "false"} {run 1 ms}
    
# -------------------------------------------------------------------------- #
# End of simulation                                                          #
# -------------------------------------------------------------------------- #

  #quit -sim	 