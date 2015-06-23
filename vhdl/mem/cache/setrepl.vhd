-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.int.all;
use work.cache_config.all;
use work.cache_comp.all;

entity setrepl is
  generic (
    SETSIZE      : integer := 1;
    SETSIZE_logx : integer := 1;
    SETREPL_TYPE : cfg_repl_type := cfg_repl_rnd 
  );
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    setfree : in std_logic_vector(SETSIZE-1 downto 0);
    setlock : in std_logic_vector(SETSIZE-1 downto 0);
    useset : in std_logic;
    locked : out std_logic;
    free   : out std_logic;
    setrep_free : out std_logic_vector(SETSIZE_logx-1 downto 0);
    setrep_repl : out std_logic_vector(SETSIZE_logx-1 downto 0)
    );
end setrepl;

architecture rtl of setrepl is

  type setrepl_tmp_type is record
    locked : std_logic;
    free   : std_logic;
    setrep_free : integer;
    setrep_repl : integer;
  end record;
  type setrepl_reg_type is record
    repl_rnd_cnt      : std_logic_vector(SETSIZE_logx-1 downto 0);
  end record;
  type setrepl_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : setrepl_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : setrepl_reg_type;
  signal rdbg, cdbg : setrepl_dbg_type;
  
  constant GDCL_SET_ZERO : std_logic_vector(SETSIZE-1 downto 0) := (others => '0');
  constant GDCL_SET_ONE : std_logic_vector(SETSIZE-1 downto 0) := (others => '1');

begin  

  p0: process (clk, rst, r, setfree, setlock, useset )
    variable v    : setrepl_reg_type;
    variable t    : setrepl_tmp_type;
    variable vdbg : setrepl_dbg_type;
  begin 

    -- $(init(t:setrepl_tmp_type))
    v := r;

    t.free := '0';
    t.locked := '0';
    if SETSIZE = 1 then
      t.setrep_repl := 0;
    else
      t.setrep_repl := lin_convint(r.repl_rnd_cnt);
    end if;
    t.setrep_free := 0;
    if setfree = GDCL_SET_ZERO then
      t.free := '0';
      if setlock = GDCL_SET_ONE then
        t.locked := '1';
      else
        if setlock(t.setrep_repl) = '1' then
L2:       for i in SETSIZE-1 downto 0 loop
            if setlock(i) = '1' then
              t.setrep_repl := i;
              exit L2;
            end if;
          end loop;  -- i
        end if;
        if useset = '1' then
          lin_incdec(r.repl_rnd_cnt, v.repl_rnd_cnt,'1','1');
        end if;
      end if;
    else
      t.free := '1';
L1:   for i in SETSIZE-1 downto 0 loop
        if setfree(i) = '1' then
          t.setrep_free := i;
          exit L1;
        end if;
      end loop;  -- i
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.repl_rnd_cnt := (others => '0');
    end if;
    
    c <= v;

    locked <= t.locked;
    free <= t.free;
    setrep_free <= std_logic_vector(conv_unsigned(t.setrep_free,SETSIZE_logx));
    setrep_repl <= std_logic_vector(conv_unsigned(t.setrep_repl,SETSIZE_logx));
    
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
