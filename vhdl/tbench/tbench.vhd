-- $(lic)
-- $(help_generic)
-- $(help_local)

-- use work.tbench_config.all;

configuration tbench of tbench_config is
  for behav 
    for all:  
      tbench_gen use entity work.tbench_gen(behav) generic map ( 
        msg2 => "2x128 kbyte 32-bit ram, 2x64 Mbyte SDRAM",
 	DISASS => 1,
	ramfile => "soft/tbenchsoft/armram.dat",
        romfile => "soft/tbenchsoft/armrom.dat"  -- rom contents
      );
    end for;
  end for;
end tbench;


