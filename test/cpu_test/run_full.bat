@rem run.bat -- Run the program on the b51 simulator, with BCD opcodes 
@rem implemented.
@rem Note we use the 'full' version of the opcode test object file, and set
@rem the simulator up to implement optional opcodes.

@rem Path to the simulator executable.
@set B51=..\..\tools\b51\bin\b51.exe

@rem Launch with no arguments: run to completion (endless loop).
%B51% --hex=./bin/tb51_all.hex --bcd %1 %2 %3
