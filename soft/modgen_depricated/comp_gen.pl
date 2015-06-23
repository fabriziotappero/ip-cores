#!/usr/bin/perl

if ($#ARGV != 0) {
    die("Call: comp_gen.pl <name>\n");
}

$name  = $ARGV[0];
$iface = $ARGV[1];
$var   = $ARGV[2];

$print =<<ENDCOMP;
-- \$(lic)
-- \$(help_generic)
-- \$(help_local)

library ieee;
use ieee.std_logic_1164.all;

entity %name% is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  %name%_typ_in;
    o       : out %name%_typ_out
    );
end %name%;

architecture rtl of %name% is

  type %name%_tmp_type is record
    o       : %name%_typ_out;
  end record;
  type %name%_reg_type is record
    dummy      : std_logic;
  end record;
  type %name%_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : %name%_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : %name%_reg_type;
  signal rdbg, cdbg : %name%_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : %name%_reg_type;
    variable t    : %name%_tmp_type;
    variable vdbg : %name%_dbg_type;
  begin 
    
    -- \$(init(t:%name%_tmp_type))
    
    v := r;
    
    -- reset
    if ( rst = '0' ) then
    end if;
    
    c <= v;
    
    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  
    
  end process p0;
    
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;
  
end rtl;
ENDCOMP

$print =~ s/%name%/$name/gi;
$print =~ s/%iface%/$iface/gi;
$print =~ s/%var%/$var/gi;

print ($print);
