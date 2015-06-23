-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;

entity testmod is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  testmod_typ_in;
    o       : out testmod_typ_out
    );
end testmod;

architecture rtl of testmod is

  type testmod_tmp_type is record
    o       : testmod_typ_out;
  end record;
  type testmod_reg_type is record
    dummy      : std_logic;
  end record;
  type testmod_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : testmod_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : testmod_reg_type;
  signal rdbg, cdbg : testmod_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : testmod_reg_type;
    variable t    : testmod_tmp_type;
    variable vdbg : testmod_dbg_type;
  begin 
    
    -- $(init(t:testmod_tmp_type))
    
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
