-------------------------------------------------------------------------------
-- Title      : A block which reads and checks data coming via HIBI
-- Project    : 
-------------------------------------------------------------------------------
-- File       : basic_tester_rx.vhd
-- Author     : ege
-- Created    : 2010-03-30
-- Last update: 2012-02-06
--
-- Description: Reads ASCII file where each line describes reception of 1 word.
--              Each transfers needs 4 hexadecimal parameters:
--               - 4 max delay (clock cycles) after previous 
--               - expected incoming address
--               - expected incoming data value
--               - expected incoming command
--              Mismatches will be reported into stdout.
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011            1.0     ege     First version
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
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

library std;
use std.textio.all;
use work.txt_util.all;                  -- for function sgtr(std_log_vec)

use work.basic_tester_pkg.all;            -- read_conf_file()

entity basic_tester_rx is

  generic (
    conf_file_g  : string  := "";
    comm_width_g : integer := 5;
    data_width_g : integer := 0
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    done_out : out std_logic;           -- if this has finished

    -- HIBI wrapper ports
    agent_av_in    : in  std_logic;
    agent_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    agent_comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    agent_re_out   : out std_logic;
    agent_empty_in : in  std_logic;
    agent_one_d_in : in  std_logic
    );

end basic_tester_rx;


architecture rtl of basic_tester_rx is

  -- Keep reading even if cannot check the data?
  constant allow_more_data_than_in_file_c : integer := 0;

  -- State machine
  type   control_states is (read_conf, wait_data, rd_addr, rd_data, finish);
  signal curr_state_r : control_states := read_conf;

  -- Registers for parameters
  signal delay_r    : integer;
  signal dst_addr_r : integer;
  signal data_val_r : integer;
  signal comm_r     : integer;

  -- Other registers
  signal re_r            : std_logic;
  signal last_addr_r     : std_logic_vector (data_width_g-1 downto 0);
  signal cycle_counter_r : integer;     -- measure delay
  signal n_addr_r        : integer;     -- count words
  signal n_data_r        : integer;     -- count words
  signal addr_correct_r  : std_logic; 
  signal error_r         : std_logic;

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using dbg_level+Rst_Value array, the rst value may
  -- be easily set to '0'=no debug for synthesis.
  constant dbg_level_c   : integer range 0 to 3          := 0;
  constant rst_val_arr_c : std_logic_vector (6 downto 0) :=
    'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';
  -- Right now gives a lot of warnings when other than 0

  
begin  -- rtl

  agent_re_out <= re_r;

  main : process (clk, rst_n)
    file conf_data_file : text open read_mode is conf_file_g;

    -- The read values from file are stored into these
    variable delay_v    : integer;
    variable dst_ag_v   : integer;
    variable data_val_v : integer;
    variable cmd_v      : integer;

  begin  -- process main
    
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      curr_state_r    <= read_conf;
      last_addr_r     <= (others => rst_val_arr_c (dbg_level_c * 1));
      cycle_counter_r <= 0;
      re_r            <= '0';
      done_out        <= '0';

      n_addr_r       <= 0;
      n_data_r       <= 0;
      addr_correct_r <= '0';
      error_r        <= '0';

      delay_v    := 0;
      dst_ag_v   := 0;
      data_val_v := 0;
      cmd_v      := 0;

    elsif clk'event and clk = '1' then  -- rising clock edge

      case curr_state_r is
        
        when read_conf =>
          -- Read the file to see what data should arrive next
          
          if endfile(conf_data_file) then
            curr_state_r   <= finish;
            re_r           <= '1';
            addr_correct_r <= '0';
            error_r        <= '0';
            assert false report "End of the configuration file reached"
              severity note;
          else
            read_conf_file (
              delay        => delay_v,
              dest_agent_n => dst_ag_v,
              value        => data_val_v,
              cmd          => cmd_v,
              conf_dat     => conf_data_file);

            delay_r         <= delay_v;
            dst_addr_r      <= dst_ag_v;
            data_val_r      <= data_val_v;
            comm_r          <= cmd_v;
            error_r         <= '0';
            re_r            <= '0';
            cycle_counter_r <= 0;
            curr_state_r    <= wait_data;

            if dst_ag_v /= 0 then
              addr_correct_r <= '0';
              -- else keep the the old value  
            end if;            
          end if;  -- endfile
          

        when wait_data =>

          if agent_empty_in = '0' then
            if agent_av_in = '1' then
              curr_state_r <= rd_addr;
            else
              if addr_correct_r = '1' then
                curr_state_r <= rd_data;
              else
                error_r      <= '1';
                assert false
                  report "Data received but addr could not be checked"
                  severity warning;
                curr_state_r <= read_conf;
              end if;
            end if;
            re_r <= '1';
            
          else
            re_r <= '0';
          end if;

          -- Increment the delay counter
          cycle_counter_r <= cycle_counter_r +1;

          
        when rd_addr =>

          -- Check the incoming address: a) no change, b) as in file
          addr_correct_r <= '1';        -- default that may be overriden

          if dst_addr_r = 0 then
            -- Assume that addr has not changed
            
            if agent_data_in /= last_addr_r then
              addr_correct_r <= '0';
              error_r        <= '1';

              assert false
                report "Addr does not match. Expected "
                & str(to_integer(signed(last_addr_r)))
                & " but got " & str(to_integer(unsigned(agent_data_in)))
                severity warning;

            end if;

            
          elsif dst_addr_r /= -1 then
            --  Expected addr was given in the file

            if to_integer(unsigned(agent_data_in)) /= dst_addr_r then
              addr_correct_r <= '0';
              error_r        <= '1';

              assert false
                report "Addr does not match. Expected 0d"
                & str(dst_addr_r) & " but got 0d"
                & str(to_integer(unsigned(agent_data_in)))
                severity warning;

            end if;
          end if;

          -- Check the incoming command
          if comm_r /= -1 then

            if to_integer(unsigned(agent_comm_in)) /= comm_r then
              error_r <= '1';
              
              assert false
                report "Comm does not match  Expected 0d"
                & str(comm_r) & " but got 0d"
                & str(to_integer(unsigned(agent_comm_in)))
                severity warning;
            end if;
          end if;

          last_addr_r     <= agent_data_in;
          n_addr_r        <= n_addr_r +1;
          cycle_counter_r <= cycle_counter_r +1;

          if agent_empty_in = '0' then
            re_r         <= '1';
            curr_state_r <= rd_data;
          else
            re_r         <= '0';
            curr_state_r <= wait_data;
          end if;
          

        when rd_data =>
          if agent_empty_in = '0' then
            
            re_r         <= '0';
            n_data_r     <= n_data_r +1;
            curr_state_r <= read_conf;

            -- Check
            --  a) if data arrived before wait time has expired
            if delay_r /= -1 then

              if delay_r < cycle_counter_r then
                error_r <= '1';

                assert false
                  report "Data arrived too late. Expected duration "
                  & str(delay_r) & " cycles, but it took "
                  & str(cycle_counter_r) & " cycles."
                  severity warning;
              end if;
            end if;

            --  b) if value is as expected
            if data_val_r /= -1 then
              if to_integer(signed(agent_data_in)) /= data_val_r then
                error_r <= '1';

                assert false
                  report "Wrong data value.  Expected 0d"
                  & str(data_val_r) & " but got 0d"
                  & str(to_integer(unsigned(agent_data_in)))
                  severity warning;
              end if;
            end if;

            --  c) command is as expected
            if comm_r /= -1 then

              if to_integer(unsigned(agent_comm_in)) /= comm_r then
                error_r <= '1';

                assert false
                  report "Comm does not match  Expected 0d"
                  & str(comm_r) & " but got 0d"
                  & str(to_integer(unsigned(agent_comm_in)))
                  severity warning;
              end if;
            end if;
            
          end if;
          

        when finish =>
          -- Notify that we're done.
          done_out        <= '1';
          cycle_counter_r <= 0;
          delay_r         <= 0;
          dst_addr_r      <= 0;
          data_val_r      <= 0;
          comm_r          <= 0;
          re_r            <= '1';

          if allow_more_data_than_in_file_c = 1 then
            -- Keep reading and counting if some data still arrives
            -- but cannot check anything

            if agent_empty_in = '0' and re_r = '1' then
              if agent_av_in = '1' then
                n_addr_r    <= n_addr_r +1;
                last_addr_r <= agent_data_in;
              else
                n_data_r <= n_data_r +1;
              end if;
            end if;
          else
            -- There should not be anymore data
            if agent_empty_in = '0' then
              error_r <= '1';
              assert false report "Unexpected data arrives"
                severity warning;
            end if;
                        
          end if;

        when others => null;
      end case;                         -- curr_state_r

    end if;                             -- rst_n / clk'event
  end process main;  

end rtl;
