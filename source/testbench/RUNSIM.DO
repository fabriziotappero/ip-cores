#-----------------------------------------------------------------------------#
#                                                                             #
#                         M A C R O    F I L E                                #
#                          COPYRIGHT (C) 2006                                 #
#                                                                             #
#-----------------------------------------------------------------------------#
#-
#- Title       : RUNSIM.DO
#- Design      : MDCT Core
#- Author      : Michal Krepa
#-
#-----------------------------------------------------------------------------
#-
#- File        : RUNSIM.DO
#- Created     : Sat Mar 5 2006
#-
#-----------------------------------------------------------------------------
#-
#-  Description : ModelSim macro for running simulation
#-
#-----------------------------------------------------------------------------


# Start simulation                                    			
  do SOURCE/TESTBENCH/MDCT_TB.DO
  
  vsim -t ps -lib WORK CONF_MDCT	
  do SOURCE/TESTBENCH/WAVE.DO

  while {[exa testend_s] == "false"} {run 1 ms}
    
# End of simulation                                                          

#quit -sim	 