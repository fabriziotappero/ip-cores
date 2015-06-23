REM ##########################################################################
REM # This will create the iMPACT CMD file and then run iMPACT to program    #    
REM #    the Spartan-3E device on the Starter Kit board.                     #
REM ##########################################################################
@echo setMode -bscan                                    > impact_batch_commands.cmd
@echo setCable -p auto                                 >> impact_batch_commands.cmd
@echo addDevice -position 1 -file .\first.bit  >> impact_batch_commands.cmd
@echo addDevice -position 2 -part "xcf04s"             >> impact_batch_commands.cmd
@echo addDevice -position 2 -part "xcf04s"             >> impact_batch_commands.cmd
@echo ReadIdcode -p 1                                  >> impact_batch_commands.cmd
@echo program -p 1                                     >> impact_batch_commands.cmd
@echo quit                                             >> impact_batch_commands.cmd
impact -batch impact_batch_commands.cmd
pause