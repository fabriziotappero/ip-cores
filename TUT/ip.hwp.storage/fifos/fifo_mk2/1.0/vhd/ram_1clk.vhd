-------------------------------------------------------------------------------
-- Title      : Single clock one port RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ram_1clk.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-01-13
-- Last update: 2012-06-14
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Basic one port RAM with one clock, new data on read-during-write
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-13  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram_1clk is
  
  generic (
    data_width_g : positive;
    addr_width_g : positive;
    depth_g      : positive;
    out_reg_en_g : natural);

  port (
    clk        : in  std_logic;
    wr_addr_in : in  std_logic_vector(addr_width_g-1 downto 0);
    rd_addr_in : in  std_logic_vector(addr_width_g-1 downto 0);
    we_in      : in  std_logic;
    data_in    : in  std_logic_vector(data_width_g-1 downto 0);
    data_out   : out std_logic_vector(data_width_g-1 downto 0));

end entity ram_1clk;


architecture rtl of ram_1clk is

  type ram_type is array (0 to depth_g-1)
    of std_logic_vector(data_width_g-1 downto 0);

  signal ram_r       : ram_type := (others => (others => '0'));
  signal read_addr_r : integer range 0 to depth_g-1;
  
begin  -- architecture rtl

  ram_p : process (clk) is
  begin  -- process ram_p
    if clk'event and clk = '1' then     -- rising clock edge

      if we_in = '1' then
        ram_r(to_integer(unsigned(wr_addr_in))) <= data_in;
      end if;

      if out_reg_en_g = 1 then
        read_addr_r <= to_integer(unsigned(rd_addr_in));
      end if;      
      
    end if;
  end process ram_p;

  out_reg_en_1: if out_reg_en_g = 1 generate
    data_out <= ram_r(read_addr_r);    
  end generate out_reg_en_1;

  out_reg_en_0: if out_reg_en_g = 0 generate
    data_out <= ram_r(to_integer(unsigned(rd_addr_in)));
  end generate out_reg_en_0;
  

end architecture rtl;
