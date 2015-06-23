-------------------------------------------------------------------------------
-- Title      : Parametrized DP RAM for heap-sorter
-- Project    : heap-sorter
-------------------------------------------------------------------------------
-- File       : sort_dpram.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2010-05-14
-- Last update: 2011-07-06
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Wojciech M. Zabolotny
-- This file is published under the BSD license, so you can freely adapt
-- it for your own purposes.
-- Additionally this design has been described in my article:
--    Wojciech M. Zabolotny, "Dual port memory based Heapsort implementation
--    for FPGA", Proc. SPIE 8008, 80080E (2011); doi:10.1117/12.905281
-- I'd be glad if you cite this article when you publish something based
-- on my design.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-05-14  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.sorter_pkg.all;
use work.sys_config.all;

entity sort_dp_ram is

  generic
    (
      ADDR_WIDTH : natural;
      NLEVELS    : natural;
      NAME       : string := "X"
      );

  port
    (
      clk    : in  std_logic;
      addr_a : in  std_logic_vector(NLEVELS-1 downto 0);
      addr_b : in  std_logic_vector(NLEVELS-1 downto 0);
      data_a : in  T_DATA_REC;
      data_b : in  T_DATA_REC;
      we_a   : in  std_logic;
      we_b   : in  std_logic;
      q_a    : out T_DATA_REC;
      q_b    : out T_DATA_REC
      );

end sort_dp_ram;

architecture rtl of sort_dp_ram is

  signal vq_a, vq_b, tdata_a, tdata_b : std_logic_vector(DATA_REC_WIDTH-1 downto 0);
  signal reg                          : T_DATA_REC := DATA_REC_INIT_DATA;

  component dp_ram_scl
    generic (
      DATA_WIDTH : natural;
      ADDR_WIDTH : natural);
    port (
      clk    : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      data_b : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      we_a   : in  std_logic := '1';
      we_b   : in  std_logic := '1';
      q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
      q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;
  
begin

  -- Convert our data records int std_logic_vector, so that
  -- standard DP RAM may handle it
  tdata_a <= tdrec2stlv(data_a);
  tdata_b <= tdrec2stlv(data_b);

  
  i1 : if ADDR_WIDTH > 0 generate
    -- When ADDR_WIDTH is above 0 embed the real DP RAM
    -- (even though synthesis tool may still replace it with
    -- registers during optimization for low ADDR_WIDTH)
    
    q_a <= stlv2tdrec(vq_a);
    q_b <= stlv2tdrec(vq_b);

    dp_ram_1 : dp_ram_scl
      generic map (
        DATA_WIDTH => DATA_REC_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
      port map (
        clk    => clk,
        addr_a => addr_a(ADDR_WIDTH-1 downto 0),
        addr_b => addr_b(ADDR_WIDTH-1 downto 0),
        data_a => tdata_a,
        data_b => tdata_b,
        we_a   => we_a,
        we_b   => we_b,
        q_a    => vq_a,
        q_b    => vq_b);

  end generate i1;

  i2 : if ADDR_WIDTH = 0 generate
    -- When ADDR_WIDTH is 0, DP RAM should be simply replaced
    -- with a register implemented below

    p1 : process (clk)
    begin  -- process p1
      if clk'event and clk = '1' then   -- rising clock edge
        if we_a = '1' then
          reg <= data_a;
          q_a <= data_a;
          q_b <= data_a;
        elsif we_b = '1' then
          reg <= data_b;
          q_a <= data_b;
          q_b <= data_b;
        else
          q_a <= reg;
          q_b <= reg;
        end if;
      end if;
    end process p1;
    
  end generate i2;

  dbg1 : if SORT_DEBUG generate

    -- Process monitoring read/write accesses to the memory (only for debugging)
    p3 : process (clk)
      variable rline : line;
    begin  -- process p1
      if clk'event and clk = '1' then   -- rising clock edge
        if(we_a = '1' and we_b = '1') then
          write(rline, NAME);
          write(rline, ADDR_WIDTH);
          write(rline, string'(" Possible write collision!"));
          writeline(reports, rline);
        end if;

        if we_a = '1' then
          write(rline, NAME);
          write(rline, ADDR_WIDTH);
          write(rline, string'(" WR_A:"));
          wrstlv(rline, addr_a(ADDR_WIDTH-1 downto 0));
          write(rline, string'(" VAL:"));
          wrstlv(rline, tdata_a);
          writeline(reports, rline);
        end if;
        if we_b = '1' then
          write(rline, NAME);
          write(rline, ADDR_WIDTH);
          write(rline, string'(" WR_B:"));
          wrstlv(rline, addr_b(ADDR_WIDTH-1 downto 0));
          write(rline, string'(" VAL:"));
          wrstlv(rline, tdata_b);
          writeline(reports, rline);
        end if;
      end if;
    end process p3;
  end generate dbg1;
end rtl;
