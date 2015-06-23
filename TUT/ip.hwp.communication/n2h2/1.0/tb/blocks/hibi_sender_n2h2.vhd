-------------------------------------------------------------------------------
-- Title      : A block which sends data to HIBI
-- Project    : 
-------------------------------------------------------------------------------
-- File       : hibi_sender_n2h2.vhd
-- Author     : kulmala3
-- Created    : 13.01.2005
-- Last update: 2011-11-11
-- Description: This blocks creates traffic for the HIBI block.
--              Reads a configraution file, where each line has 3 integers:
--              dest_agent delay_cycles num_of_words
--
--              This is derived from a block "hibi_sender" but modified for
--              testing Nios-to-HIBI2 (n2h2).
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 13.01.2005  1.0      AK      Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.tb_n2h2_pkg.all;               -- incl. e.g. const array "addresses"

entity hibi_sender_n2h2 is
  
  generic (
    --data_1_g     : string  := "";       -- obsolete?
    conf_file_g  : string  := "";
    own_number_g : integer := 0;        -- 1-4
    comm_width_g : integer := 5;
    n_dest_g : integer := 3;
    data_width_g : integer := 0);

  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    pause_in  : in  std_logic;
    pause_ack : out std_logic;
    done_out  : out std_logic;          -- if this has finished

    -- HIBI WRAPPER PORTS
    agent_av_out    : out std_logic;
    agent_data_out  : out std_logic_vector(data_width_g-1 downto 0);
    agent_comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    agent_empty_out : out std_logic;
    agent_re_in     : in  std_logic

    -- note that this only sends, so these signals are removed
    --    agent_empty_in : in  std_logic;
    --    agent_one_d_in : in  std_logic;
    --    agent_re_out   : out std_logic;
    --    agent_av_in    : in  std_logic;
    --    agent_comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    --    agent_data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    -- aren't needed
    );

end hibi_sender_n2h2;


architecture rtl of hibi_sender_n2h2 is


  -- Use only one command: basic write operation
  constant hibi_write_c : std_logic_vector(comm_width_g-1 downto 0) := "00010";




  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using dbg_level+Rst_Value array, the rst value may
  -- be easily set to '0' for synthesis.
  constant rst_value_arr : std_logic_vector (6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';

  -- right now gives a lot of warnings when other than 0
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  
  -- This procedure reads the (opened) file. The file line structure is as follows:
  -- 1st integer: destination agent (1,2,3,4) (not own!)
  -- 2nd integer: delay cycles before sending
  -- 3rd integer: amount of data words to be sent.
  procedure read_hibi_conf_file (
    dest_agent_n  : out integer;
    delay         : out integer;
    amount        : out integer;
    file conf_dat :     text) is

    variable file_row         : line;
    variable dest_agent_n_var : integer;
    variable delay_var        : integer;
    variable amount_var       : integer;
    variable dest_ok          : boolean := false;  -- ES 2011-11-11
  begin  -- read_hibi_conf_file

    -- Loop until finding a line that is not a comment
    while dest_ok = false and not(endfile(conf_dat)) loop
      readline(conf_dat, file_row);      
      read (file_row, dest_agent_n_var, dest_ok);

      if dest_ok = FALSE then
        --Reading of the delay value failed
        --=> assume that this line is comment or empty, and skip other it
        -- assert false report "Skipped a line" severity note;
        next;                           -- start new loop interation
      end if;

      read (file_row, delay_var);
      read (file_row, amount_var);

      -- Return the values
      dest_agent_n := dest_agent_n_var;
      delay        := delay_var;
      amount       := amount_var;
    end loop;
    
  end read_hibi_conf_file;



  -- Main FSM
  type   control_states is (read_hibi_conf, wait_sending, write_hibi, wait_hibi, finish, write_addr, pause);
  signal control_r : control_states := read_hibi_conf;



  -- Fifo signals
  signal agent_comm_to_fifo : std_logic_vector (comm_width_g-1 downto 0);
  signal agent_data_to_fifo : std_logic_vector(data_width_g-1 downto 0);
  signal agent_av_to_fifo   : std_logic;
  signal data_to_fifo    : std_logic_vector (1+comm_width_g+data_width_g-1 downto 0);  --concatenated from above
  signal we_to_fifo      : std_logic;
  signal full_from_fifo  : std_logic;
  signal one_p_from_fifo : std_logic;
  
  signal re_to_fifo      : std_logic;
  signal data_from_fifo  : std_logic_vector (1+comm_width_g+data_width_g-1 downto 0);
  signal empty_from_fifo : std_logic;
  signal one_d_from_fifo : std_logic;




  -- internal
  constant data_fixed_width_c : integer := 32;
  constant n_words_output_c : integer := data_width_g/ data_fixed_width_c;
  type dest_amount_cnt_type is array (0 to n_dest_g-1) of std_logic_vector(data_fixed_width_c-1 downto 0);
  signal data_r : dest_amount_cnt_type;  -- 32 bit words always!

  signal sent_packets_r : integer;
  
begin  -- rtl

  agent_av_out   <= data_from_fifo(1+comm_width_g+data_width_g-1);
  agent_comm_out <= data_from_fifo(comm_width_g+data_width_g-1 downto data_width_g);
  agent_data_out <= data_from_fifo(data_width_g-1 downto 0);
  data_to_fifo   <= agent_av_to_fifo & agent_comm_to_fifo & agent_data_to_fifo;

  --
  -- Instead of full HIBI bus, we only need one FIFO. This component
  -- puts data to the FIFO, that will be read by the DUT.
  --
  fifo_1 : entity work.fifo
    generic map (
      data_width_g => 1+comm_width_g+data_width_g,  -- av, comm, data
      depth_g      => 10)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => data_to_fifo,
      we_in     => we_to_fifo,
      full_out  => full_from_fifo,
      one_p_out => one_p_from_fifo,
      re_in     => agent_re_in,
      data_out  => data_from_fifo,
      empty_out => agent_empty_out,
      one_d_out => one_d_from_fifo);

  --
  -- Generate transfers according to conf file
  --
  main : process (clk, rst_n)
    file conf_data_file : text open read_mode is conf_file_g;
    --    file data_file_1    : text open read_mode is data_1_g;

    variable delay_r        : integer;
    variable amount_r       : integer;
    variable dest_agent_n_r : integer;
    variable file_number_r  : integer;
    --    variable data_r         : integer;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)
      control_r          <= read_hibi_conf;
      agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
      agent_av_to_fifo   <= '0';
      agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));
      we_to_fifo         <= '0';
      done_out           <= '0';
      amount_r           := 0;
      delay_r            := 0;
      dest_agent_n_r     := 0;
      for i in 0 to n_dest_g-1 loop
        data_r(i) <= (others => '0');
      end loop;  -- i
      file_number_r  := 0;
      pause_ack      <= '0';
      sent_packets_r <= 0;
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      case control_r is
        when read_hibi_conf =>
          -- If there's still data left, we read the configuration
          -- file and act accordingly. If some delay is specified,
          -- we go and wait it (wait_sending). If delay = 0,
          -- then we send the address right away          
          if pause_in = '1' then
            control_r <= pause;
          else

            if endfile(conf_data_file) then
              control_r <= finish;
              assert false report "End of the configuration file reached" severity note;
            end if;
            read_hibi_conf_file (
              dest_agent_n => dest_agent_n_r,
              delay        => delay_r,
              amount       => amount_r,
              conf_dat     => conf_data_file);
            if delay_r = 0 then
              control_r <= write_addr;
            else
              control_r <= wait_sending;
            end if;
          end if;
            we_to_fifo         <= '0';
            agent_av_to_fifo   <= '0';
            agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
            agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));


        when wait_sending =>
          -- Let's wait the given amount of time before proceeding with sending
          delay_r := delay_r-1;
          if delay_r = 0 then
            control_r <= write_addr;
          end if;
          dest_agent_n_r := dest_agent_n_r;
          amount_r       := amount_r;--dest_agent_n_r;

        when write_addr =>
          -- When there is room in fifo, we write the address to it and then
          -- go to the state where the actual data is sent (write_hibi)
          -- Note that part of dst agent address is gotten from the array
          -- defined in separate package.
          if full_from_fifo = '0' then
            we_to_fifo         <= '1';
            agent_av_to_fifo   <= '1';
            agent_comm_to_fifo <= hibi_write_c;

            -- Addr defines not only the target, but also
            -- identifies the sender and packet number.
            -- Hence, sent addresses are always incremented by one.
            agent_data_to_fifo <= conv_std_logic_vector
                                  (addresses_c(dest_agent_n_r)
                                   + own_number_g + sent_packets_r
                                   , data_width_g);

            sent_packets_r <= sent_packets_r + 1;
            control_r <= write_hibi;
          else
            we_to_fifo         <= '0';
            agent_av_to_fifo   <= '0';
            agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
            agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));
            control_r          <= write_addr;
          end if;
          
        when write_hibi =>
          -- Outputs runnign numbers: 0,1,2...
          
          if full_from_fifo = '0' then

            for i in 0 to n_words_output_c-1 loop
              agent_data_to_fifo(data_fixed_width_c*(i+1)-1 downto data_fixed_width_c*i) <= data_r(dest_agent_n_r)+i;
              amount_r := amount_r-1;
              if amount_r = 0 then
                control_r  <= read_hibi_conf;
                we_to_fifo <= '1';
                exit;
              end if;
            end loop;  -- i
            data_r(dest_agent_n_r) <= data_r(dest_agent_n_r) + n_words_output_c;
            
            agent_av_to_fifo   <= '0';
            agent_comm_to_fifo <= hibi_write_c;

            if one_p_from_fifo = '1' then
              control_r  <= wait_hibi;
              we_to_fifo <= '0';
            end if;
            
          else
            control_r          <= wait_hibi;
            agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
            we_to_fifo         <= '0';
            agent_av_to_fifo   <= '0';
            agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));
          end if;

        when wait_hibi =>
          -- hibi was full so we wait until it becames free again
          if full_from_fifo = '0' then
            control_r  <= write_hibi;
            we_to_fifo <= '1';
            if amount_r = 0 then
              control_r <= read_hibi_conf;
            end if;
          else
            control_r  <= wait_hibi;
            we_to_fifo <= '0';
          end if;
          --          agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
          --          agent_av_to_fifo   <= '0';
          --          agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));

        when finish =>
          -- Notify that we're done.
          done_out           <= '1';
          agent_data_to_fifo <= (others => rst_value_arr(dbg_level*1));
          we_to_fifo         <= '0';
          agent_av_to_fifo   <= '0';
          agent_comm_to_fifo <= (others => rst_value_arr(dbg_level*1));
          
        when pause =>
          if pause_in = '0' then
            pause_ack <= '0';
            control_r <= read_hibi_conf;
          else
            pause_ack <= '1';
            control_r <= pause;
          end if;
        when others => null;
      end case;

      
      
    end if;
  end process main;
  

end rtl;
