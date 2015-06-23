-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;

package tbench_comp is

type tbench_gen_typ_in is record
   dummy : std_logic;
end record;

type tbench_gen_typ_out is record
   dummy : std_logic;
end record;

component tbench_gen
  generic (
    msg1      : string := "32 kbyte 32-bit rom, 0-ws";
    msg2      : string := "2x128 kbyte 32-bit ram, 0-ws";
    pcihost   : boolean := false;	-- be PCI host
    DISASS    : integer := 0;	        -- enable disassembly to stdout
    clkperiod : integer := 20;		-- system clock period
    romfile   : string := "soft/tbenchsoft/rom.dat";  -- rom contents
    ramfile   : string := "soft/tbenchsoft/ram.dat";  -- ram contents
    sdramfile : string := "soft/tbenchsoft/sdram.rec";  -- sdram contents
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 13;		-- rom address depth
    romtacc   : integer := 10;		-- rom access time (ns)
    ramwidth  : integer := 32;		-- ram data width (8/16/32)
    ramdepth  : integer := 15;		-- ram address depth
    rambanks  : integer := 2;		-- number of ram banks
    bytewrite : boolean := true;	-- individual byte write strobes
    ramtacc   : integer := 10		-- ram access time (ns)
  );
  port ( 
    i       : in  tbench_gen_typ_in;
    o       : out tbench_gen_typ_out
    );
end component;

component tbench_config 

end component;

end tbench_comp;
