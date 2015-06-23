-- Automatically generated file
-- Copyright 2004, Konrad Eisele<eiselekd.de>
-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.arith_cnt_comp.all;

entity arith_cnt8 is
port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    si : in  arith_cnt8_in;
    so : out arith_cnt8_out
);
end arith_cnt8;

architecture rtl of arith_cnt8 is
  
  type arith_cnt8_tmp_type is record
    so : arith_cnt8_out;
    L000_z : std_logic_vector(4-1 downto 0);
    L001_z : std_logic_vector(4-1 downto 0);
    help : std_logic_vector(8-1 downto 0);
    tmp : integer;

    dummy : std_logic;
  end record;
  type arith_cnt8_reg_type is record

    dummy : std_logic;
  end record;
  type arith_cnt8_dbg_type is record
    dummy : std_logic;
    -- pragma translate_off
    dbg : arith_cnt8_tmp_type;
    -- pragma translate_on
  end record;
  signal r, c       : arith_cnt8_reg_type;
  signal rdbg, cdbg : arith_cnt8_dbg_type;

constant ZCON : std_logic_vector(8-1 downto 0) := (others => '0');

begin  
  
  p0: process (clk, rst, r, si )
    variable v    : arith_cnt8_reg_type;
    variable t    : arith_cnt8_tmp_type;
    variable vdbg : arith_cnt8_dbg_type;
  begin 
    
    -- $(init(t:arith_cnt8_tmp_type))
    
    v := r;

    t.tmp := 0;
L0:
    for i in (8/2)-1 downto 0 loop
      t.tmp := i;
      t.help(2-1 downto 0) := si.data(((i+1)*2)-1 downto i*2);
      t.L000_z(i) := '1';
      if    not (t.help(0 downto 0) = ZCON((2/2)-1 downto 0)) then
        t.L000_z(i) := '0';
      else
        t.L000_z(i) := '1';
      end if;
    end loop;  -- i


    t.tmp := 0;
L1:
    for i in (8/4)-1 downto 0 loop
      t.tmp := i;
      t.help(4-1 downto 0) := si.data(((i+1)*4)-1 downto i*4);
      if    not (t.help(1 downto 0) = ZCON((4/2)-1 downto 0)) then
        t.L001_z(i*2) := t.L000_z(i*2);
        t.L001_z((i*2)+1) := '0';
      else 
        t.L001_z(i*2) := t.L000_z((i*2)+1);     
        t.L001_z((i*2)+1) := '1';
      end if;
    end loop;  -- i


    t.tmp := 0;
L2:
    for i in (8/8)-1 downto 0 loop
      t.tmp := i;
      t.help(8-1 downto 0) := si.data(((i+1)*8)-1 downto i*8);
      if    not (t.help(3 downto 0) = ZCON((8/2)-1 downto 0)) then
        t.so.res(1 downto 0) := t.L001_z(1 downto 0);
        t.so.res(2) := '0';
      else 
        t.so.res(1 downto 0) := t.L001_z(3 downto 2);
        t.so.res(2) := '1';
      end if;
    end loop;  -- i

    so <= t.so;
    c <= v;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  end process p0;

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


