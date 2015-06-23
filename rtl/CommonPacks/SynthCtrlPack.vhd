-- *****************************************************************************************
-- AVR synthesis control package
-- Version 1.32 (Special version for the JTAG OCD)
-- Modified 14.07.2005
-- Designed by Ruslan Lepetenok
-- *****************************************************************************************

library	IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package SynthCtrlPack is							

-- Register file
constant CResetRegFile        : boolean := TRUE;

-- Static RAM Controller
constant CWaitStIns           : boolean := FALSE;

-- External multiplexer size
constant CExtMuxInSize        : positive := 16;

-- Top
constant CImplServModule      : boolean := FALSE;
constant CImplTmrCnt          : boolean := TRUE;
constant CImplPORTA           : boolean := TRUE;
constant CImplPORTB           : boolean := TRUE;

constant CImplUART            : boolean := TRUE;

constant CImplClockSw         : boolean := FALSE;

-- Reset generator
constant CSecondClockUsed     : boolean := FALSE;

-- Only for ASICs
constant CSynchLatchUsed      : boolean := FALSE;	

-- Memeory parameters(for the designs without external memory)
constant CPRAMSize : positive := 4*1024; -- Size of program memory(in bytes)
constant CDRAMSize : positive := 2*1024; -- Size of data memory(in bytes)

constant CUseAltera          : boolean := TRUE;

-- Special modules
constant CImplWDTUI          : boolean := FALSE;
constant CImplTC16BUI        : boolean := FALSE;
constant CImplSMBusMod       : boolean := TRUE;

constant CImplHDQ16UI        : boolean := FALSE;
constant CImplIdentifier     : boolean := FALSE;

constant CPMSynth            : boolean := TRUE;

end SynthCtrlPack;
