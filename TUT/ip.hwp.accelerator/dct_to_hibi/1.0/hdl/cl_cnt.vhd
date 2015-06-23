 -------------------------------------------------------------------------------
-- Title      : chroma/luma counter for MB
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cl_cnt.vhd
-- Author     : kulmala3
-- Created    : 16.08.2005
-- Last update: 16.08.2005
-- Description: MB is 6 8x8 blocks. 4 first are luma, then 2 are chroma.
-- then reset. chroma = '1', luma = '0'
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.08.2005  1.0      AK	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cl_cnt is
  
  generic (
    n_luma_g   : integer := 4;
    n_chroma_g : integer := 2);

  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    ena_in    : in  std_logic;
--    s_rst_n_in : in  std_logic;
    cl_out     : out std_logic
    );

end cl_cnt;


architecture rtl of cl_cnt is

  signal counter_r : integer range 0 to (n_luma_g+n_chroma_g)-1;
begin  -- rtl

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      counter_r <= 0;
      cl_out <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ena_in = '1' then
        if counter_r = (n_luma_g+n_chroma_g)-1 then
          counter_r <= 0;
        else
          counter_r <= counter_r+1;          
        end if;        
      end if;

      if counter_r < n_luma_g then
        cl_out <= '0';
      else
        cl_out <= '1';
      end if;
    end if;
  end process;

  

end rtl;
