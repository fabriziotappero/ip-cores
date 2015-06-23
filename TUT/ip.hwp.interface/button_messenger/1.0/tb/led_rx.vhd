-------------------------------------------------------------------------------
-- Title      : A block that turns leds on and off. Controlled by writing one
--              byte which will then go directly to led outputs.
-- Project    : Nocbench, Funbase
-------------------------------------------------------------------------------
-- File       : led_Rx.vhd
-- Author     : ege
-- Created    : 2012-02-10
-- Last update: 2012-02-10
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-02-10  1.0      ES      First version
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity led_rx is

  generic (
    comm_width_g : integer := 5;
    data_width_g : integer := 0
    );
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    leds_out : out std_logic_vector(7 downto 0);

    -- HIBI wrapper ports
    agent_av_in    : in  std_logic;
    agent_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_re_out   : out std_logic;
    agent_empty_in : in  std_logic;
    agent_one_d_in : in  std_logic
    );

end led_rx;


architecture rtl of led_rx is


begin  -- rtl
  main : process (clk, rst_n)

  begin  -- process main
    
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      agent_re_out <= '1';
      leds_out     <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      agent_re_out <= '1';

      if agent_empty_in = '0' and agent_av_in = '0' then
        leds_out <= agent_data_in (7 downto 0);
      end if;

    end if;
  end process main;
  

end rtl;
