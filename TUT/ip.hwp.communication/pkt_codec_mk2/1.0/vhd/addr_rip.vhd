-------------------------------------------------------------------------------
-- Title      : Address flit ripper / replacer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : addr_rip.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-10-12
-- Last update: 2011-12-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-- Converts the addresses received from NoC to IP. All transfers start with NoC
-- address which can be optionally followed by (memory-mapped original) address.
-- This unit rips (removes) the NoC address flit, if wanted. Moreover, this can
-- replace the network address with original address (2nd flit). Or this doesn't
-- do a thing but just forwards everything to IP.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-12  1.0      lehton87        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity addr_rip is
  
  generic (
    cmd_width_g    : positive;          -- in bits
    data_width_g   : positive;          -- in bits
    addr_flit_en_g : natural;           -- Is there an address in 2nd flit?
    rip_addr_g     : natural            -- Enable removing the NoC address
    );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    net_cmd_in    : in  std_logic_vector(cmd_width_g-1 downto 0);
    net_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    net_stall_out : out std_logic;
    ip_cmd_out    : out std_logic_vector(cmd_width_g-1 downto 0);
    ip_data_out   : out std_logic_vector(data_width_g-1 downto 0);
    ip_stall_in   : in  std_logic
    );
end addr_rip;


architecture rtl of addr_rip is

  signal was_addr_r : std_logic;
  
begin  -- rtl


  -- Check if NoC address was received
  addr_check_p : process (clk, rst_n)
  begin  -- process addr_check_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      was_addr_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if net_cmd_in = "01" then
        was_addr_r <= '1';
      else
        was_addr_r <= '0';
      end if;
    end if;
  end process addr_check_p;

  ip_data_out   <= net_data_in;
  net_stall_out <= ip_stall_in;


  -- 1. Do not forward NoC address to IP.
  rip : if rip_addr_g = 1 generate
    
    -- Give the second flit as address to the IP
    replace : if addr_flit_en_g = 1 generate

      m1 : process (net_cmd_in, was_addr_r)
      begin  -- process m
        if net_cmd_in = "01" then
          ip_cmd_out <= "00";
        elsif was_addr_r = '1' then
          ip_cmd_out <= "01";
        else
          ip_cmd_out <= net_cmd_in;
        end if;
      end process m1;
    end generate replace;

    -- NoC addr is followed by data. Don't give any address to IP.
    dont_replace : if addr_flit_en_g = 0 generate
      m2: process (net_cmd_in)
      begin  -- process m2
        if net_cmd_in = "01" then
          ip_cmd_out <= "00";
        else
          ip_cmd_out <= net_cmd_in;
        end if;
      end process m2;
    end generate dont_replace;
  end generate rip;


  
  -- 2. Forward NoC address to IP.
  dont_rip : if rip_addr_g = 0 generate
    
    -- Give both the NoC addr and 2nd addr flit to IP
    replace1 : if addr_flit_en_g = 1 generate
      m3 : process (net_cmd_in, was_addr_r)
      begin  -- process m
        if net_cmd_in = "01" then
          ip_cmd_out <= "01";
        elsif was_addr_r = '1' then
          ip_cmd_out <= "01";
        else
          ip_cmd_out <= net_cmd_in;
        end if;
      end process m3;
    end generate replace1;

    -- Everything goes straight through to the IP
    dont_replace1 : if addr_flit_en_g = 0 generate
      ip_cmd_out <= net_cmd_in;
    end generate dont_replace1;
  end generate dont_rip;

end rtl;
