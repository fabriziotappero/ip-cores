@rem run.bat -- Run the program on the b51 simulator.

@rem Path to the simulator executable.
@set B51=..\..\tools\b51\bin\b51.exe

@rem Launch with no arguments: run to completion (endless loop).
%B51% --hex=./bin/blinker.ihx
