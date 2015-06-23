-------------------------------------------------------------------------------
-- Title      : Converts event in button input to a message
-- Project    : Nocbench, Funbase
-------------------------------------------------------------------------------
-- File       : button_messenger.vhd
-- Author     : Erno Salminen
-- Company    : TUT
-- Last update: 2012-02-13
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: On DE2 boards, the push buttons give active-low pulse when
--              pressed. Therefore, this unit detects falling edge. The sent
--              message is of form address+data. No decoding in data, just the
--              raw key input. Currently the destination address is set with
--              generic parameter.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-02-10  1.0      ES      First version
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity button_messenger is
  generic (
    n_buttons_g     : integer := 4;     -- less or eq to data_width_g
    data_width_g    : integer := 32;    -- in bits
    comm_width_g    : integer := 5;     -- in bits
    write_command_g : integer := 2;
    dst_addr_g      : integer           -- where to send the msg
    );                                 
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    tx_av_out   : out std_logic;
    tx_data_out : out std_logic_vector (data_width_g -1 downto 0);
    tx_comm_out : out std_logic_vector (comm_width_g -1 downto 0);
    tx_we_out   : out std_logic;
    tx_full_in  : in  std_logic;

    buttons_in : in std_logic_vector (n_buttons_g-1 downto 0)
    );

end button_messenger;



architecture rtl of button_messenger is

  -- Register for edge detection
  signal buttons_r  : std_logic_vector (n_buttons_g-1 downto 0);
  signal buttons2_r : std_logic_vector (n_buttons_g-1 downto 0);
  signal buttons3_r : std_logic_vector (n_buttons_g-1 downto 0);

  -- Simple state machine
  type   state_type is (idle, addr, data);
  signal state_r : state_type;
  
begin  -- rtl

  tx_comm_out <= std_logic_vector (to_unsigned(write_command_g, comm_width_g));


  -- Loop through 3 states, no branching
  main_p : process (clk, rst_n)
    variable falling_edge_found_v : integer := 0;

  begin  -- process main_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_av_out   <= '0';
      tx_data_out <= (others => '0');
      tx_we_out   <= '0';
      buttons_r   <= (others => '0');
      state_r     <= idle;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      buttons_r  <= buttons_in;
      buttons2_r <= buttons_r;
      buttons3_r <= buttons2_r;
      
      case state_r is
        -----------------------------------------------------------------------
        -- IDLE
        -----------------------------------------------------------------------
        when idle =>
          tx_av_out   <= '0';
          tx_data_out <= (others => '0');
          tx_we_out   <= '0';

          -- Edge detection
          falling_edge_found_v := 0;
          for i in 0 to n_buttons_g-1 loop
            if buttons2_r(i) = '0' and buttons3_r (i) = '1' then
              falling_edge_found_v := 1;
            end if;
          end loop;  -- i

          if falling_edge_found_v = 1 then  -- Falling edge
          --if buttons_in /= buttons_r then -- Any edge
            state_r <= addr;
          end if;



          ---------------------------------------------------------------------
          -- ADDR
          ---------------------------------------------------------------------
        when addr =>
          tx_av_out   <= '1';
          tx_data_out <= std_logic_vector (to_unsigned (dst_addr_g, data_width_g));
          tx_we_out   <= '1';
          if tx_full_in /= '1' then
            state_r <= data;
          end if;


          ---------------------------------------------------------------------
          -- DATA
          ---------------------------------------------------------------------
        when data =>
          tx_av_out                            <= '0';
          tx_data_out                          <= (others => '0');
          tx_data_out (n_buttons_g-1 downto 0) <= buttons_in;
          tx_we_out                            <= '1';
          if tx_full_in /= '1' then
            state_r <= idle;
          end if;
          
          
        when others =>
          state_r <= idle;
          
      end case;
      
      
    end if;
  end process main_p;

end rtl;
