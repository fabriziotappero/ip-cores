-------------------------------------------------------------------------------
-- Title      : HIBI TX control
-- Project    : Nocbench, Funbase 
-- Description: TX controller for hibi
--
--              Arbitrates and forwards data to the bus from tx fifo (=from IP)
--              or CFG mem.
--              Reply to config mem read will only be sent at the
--              beginning of our turn, so it won't come out immediately.
--
-- File       : tx_control.vhd
-- Authors    : Antti Alhonen,
--              Lasse Lehtonen
-- Company    : Tampere University of Technology
-------------------------------------------------------------------------------
-- Last update: 2012-02-06
-- Standard   : VHDL'93
-- TO DO:
--              keep_slot_g,
--              dyn_arb_enable_c should be generic param
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
--
-- 2010-07-02  1.0      alho-nenä Created
-- Outputs data_out and fifo_re are now COMBINATORIAL. Only address has
-- to be registered because it needs to be retransferred if a transfer is
-- suspended and restarted. No retransferring is needed in case of FULL.
-- Output data mux is simple.
-- 
-- Old version had internal path of 7.0 ns + bus path of 7.8 ns on STRATIX II.
-- This version is much simpler and the combined path seems to be only 8.8 ns.
-- This version needs a version of rx_ctrl that has no combinatorial path from
-- comm_in to fifo_full.
--
-- 2010-10-13           ase       Added support for config mem reading
-- 2010-10-24           ase       Added support for SAD mode
--
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
use ieee.numeric_std.all;

use work.hibiv3_pkg.all;

entity tx_control is

  generic (
    counter_width_g : integer;
    id_width_g      : integer;
    data_width_g    : integer;
    addr_width_g    : integer;
    comm_width_g    : integer;
    n_agents_g      : integer;
    cfg_re_g        : integer;
    keep_slot_g     : integer;
    separate_addr_g : integer
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    lock_in : in std_logic;
    full_in : in std_logic;

    cfg_ret_addr_in : in std_logic_vector(addr_width_g-1 downto 0);
    cfg_data_in     : in std_logic_vector
    (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
    cfg_re_in       : in std_logic;

    curr_slot_own_in    : in std_logic;
    curr_slot_ends_in   : in std_logic;
    next_slot_own_in    : in std_logic;
    next_slot_starts_in : in std_logic;
    max_send_in         : in std_logic_vector(counter_width_g-1 downto 0);
    n_agents_in         : in std_logic_vector(id_width_g-1 downto 0);
    prior_in            : in std_logic_vector(id_width_g-1 downto 0);
    -- 0 round-robin, 1 priority, 2 combined, 3 dyn_arb (rand)
    arb_type_in         : in std_logic_vector(1 downto 0);

    av_in    : in std_logic;
    data_in  : in std_logic_vector(data_width_g-1 downto 0);
    comm_in  : in std_logic_vector(comm_width_g-1 downto 0);
    one_d_in : in std_logic;
    empty_in : in std_logic;

    av_out         : out std_logic;
    data_out       : out std_logic_vector(data_width_g-1 downto 0);
    comm_out       : out std_logic_vector(comm_width_g-1 downto 0);
    lock_out       : out std_logic;
    cfg_rd_rdy_out : out std_logic;
    re_out         : out std_logic
    );

end tx_control;


architecture rtl of tx_control is

  -- Select arbitation type.
  -- Move to this to generic parameter!
  constant dyn_arb_enable_c : integer := 1;

  -- Internal signals and registers for arbitration
  signal prior_match         : std_logic;
  signal prior               : std_logic_vector(id_width_g-1 downto 0);
  signal dyn_arb_prior       : std_logic_vector(id_width_g-1 downto 0);
  signal prior_counter_arb_r : std_logic_vector(id_width_g-1 downto 0);
  signal arb_type_r          : std_logic_vector(1 downto 0);
  signal can_write_r         : std_logic;
  signal can_write_r_r       : std_logic;
  signal new_turn            : std_logic;  -- pulse when turn starts
  signal new_turn_stay_r     : std_logic;
  signal new_turn_ack        : std_logic;
  signal new_turn_ack_r      : std_logic;
  
  constant switch_arb_c : integer := 4096;  -- how often change between prior
                                            -- and round-robin, [cycles]
  signal   switch_arb_r : integer range 0 to switch_arb_c-1;

  
  -- Retransfer needs registers for storing one word tx
  signal addr_r           : std_logic_vector(addr_width_g-1 downto 0);
  signal comm_r           : std_logic_vector(comm_width_g-1 downto 0);
  signal data_r           : std_logic_vector(data_width_g-1 downto 0);
  signal tx_interrupted_r : std_logic;  -- for separate addr
  signal retransfer       : std_logic;  -- for separate addr
  signal retransfer_r     : std_logic;  -- for separate addr

  -- Keep track what we are doing and how many have been sent
  signal writing        : std_logic;    -- writing to bus
  signal reading        : std_logic;    -- reading the FIFO
  signal reading_r      : std_logic;
  signal send_counter_r : unsigned(counter_width_g-1 downto 0);  -- #words
  signal av_out_s       : std_logic;    -- combinatorial output (must be read also)


  -- Signals for responding to confg read operations
  signal cfg_rd_rdy_r      : std_logic;
  signal cfg_rd_ack        : std_logic;
  signal last_was_cfg_rd_r : std_logic;
  signal cfg_data_in_r     : std_logic_vector
    (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);


  -- Dynamic Arbitration Algorithm is implemented with a separate component
  component dyn_arb
    generic (
      id_width_g : integer;
      n_agents_g : integer
      );
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      bus_lock_in   : in  std_logic;
      arb_agent_out : out std_logic_vector(id_width_g-1 downto 0));
  end component;

  
begin  -- rtl

  av_out <= av_out_s;

  -----------------------------------------------------------------------------
  -- 1. CONFIG READ, rest affecting this can be found in connect_output process
  -----------------------------------------------------------------------------
  config_read_enabled : if cfg_re_g = 1 generate

    cfg_rd_rdy_out <= cfg_rd_rdy_r;

    cfg_rd_rdy_p : process (clk, rst_n) is
      variable cfg_rd_rdy_v : std_logic;
    begin  -- process cfg_rd_rdy_p
      if rst_n = '0' then               -- asynchronous reset (active low)
        
        cfg_rd_rdy_r      <= '1';
        last_was_cfg_rd_r <= '0';
        cfg_data_in_r     <= (others => '0');
        
      elsif clk'event and clk = '1' then  -- rising clock edge

        -- Block the rx ctrl from accessing config memory until reply has been sent
        if cfg_re_in = '1' then
          cfg_rd_rdy_v  := '0';
          cfg_data_in_r <= cfg_data_in;
        elsif cfg_rd_ack = '1' then
          cfg_rd_rdy_v := '1';
        else
          cfg_rd_rdy_v := cfg_rd_rdy_r;
        end if;

        cfg_rd_rdy_r <= cfg_rd_rdy_v;

        if separate_addr_g = 0 then
          last_was_cfg_rd_r <= cfg_rd_ack;
        else
          last_was_cfg_rd_r <= writing and not cfg_rd_rdy_v and new_turn_ack;
        end if;
        
        
      end if;
    end process cfg_rd_rdy_p;

  end generate config_read_enabled;

  config_read_disabled : if cfg_re_g = 0 generate

    cfg_rd_rdy_out    <= '1';
    last_was_cfg_rd_r <= '0';
    cfg_data_in_r     <= (others => '0');
    
  end generate config_read_disabled;


  -------------------------------------------------------------------------------
  -- 2. OLD VALUE REGISTERING 
  -------------------------------------------------------------------------------
  -- Old thingys (command, address and data) are needed when a transfer
  -- got interrupted and will be restarted later

  register_olds : process (clk, rst_n)
    variable tx_interrupted_v : std_logic;
  begin
    if rst_n = '0' then                 -- asynchronous reset (active low)

      can_write_r_r    <= '0';
      new_turn_ack_r   <= '0';
      new_turn_stay_r  <= '0';
      --addr_r <= (others => '0');
      --comm_r <= (others => '0');
      --data_r <= (others => '0');
      tx_interrupted_r <= '0';
      retransfer_r     <= '0';
      reading_r        <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      reading_r <= reading;

      -- Check if the previous transfer completed
      if separate_addr_g = 1 then
        
        retransfer_r <= retransfer;

        if reading_r = '1' and can_write_r_r = '1' and full_in = '1' then
          tx_interrupted_v := '1';
        elsif retransfer_r = '1' and full_in = '0' then
          tx_interrupted_v := '0';
        else
          tx_interrupted_v := tx_interrupted_r;
        end if;

        tx_interrupted_r <= tx_interrupted_v;
        
      else
        tx_interrupted_v := '0';
      end if;

      
      -- Multiplexed mode stores all the addresses, separate addr style onyl
      -- when interrupted
      if separate_addr_g = 0 and av_in = '1' and empty_in = '0' then
        addr_r <= data_in(addr_width_g-1 downto 0);
        
      elsif separate_addr_g = 1
        and tx_interrupted_v = '0' and full_in = '0' then

        data_r <= data_in;
        comm_r <= comm_in;
        
      end if;


      can_write_r_r  <= can_write_r;
      new_turn_ack_r <= new_turn_ack;

      -- The register new_turn_stay_r gets '1' when own turn starts. It returns to '0'
      -- when it's acknowledged by rising edge of new_turn_ack.
      if new_turn = '1' then
        new_turn_stay_r <= '1';
      end if;

      if new_turn_ack = '1' and new_turn_ack_r = '0' then
        new_turn_stay_r <= '0';
      end if;

    end if;
  end process register_olds;

  -------------------------------------------------------------------------------
  -- 3. Count how many words have been sent. No effect during TDMA slot, though.
  -------------------------------------------------------------------------------
  send_counting : process (clk, rst_n)
  begin  -- process send_counting
    if rst_n = '0' then                 -- asynchronous reset (active low)
      send_counter_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if writing = '1' and curr_slot_own_in = '0' then
        send_counter_r <= send_counter_r +1;
      else
        send_counter_r <= (others => '0');
      end if;
    end if;
  end process send_counting;

  -------------------------------------------------------------------------------
  -- 4. CHECK IF IT'S OUR TURN OR NOT
  -------------------------------------------------------------------------------
  -- Register can_write_r is up when it's our turn and we can take the bus
  evaluate_can_write : process (clk, rst_n)
  begin  -- process evaluate_can_write
    if rst_n = '0' then                 -- asynchronous reset (active low)    
      can_write_r <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge      

      can_write_r <= '0';

      if curr_slot_own_in = '1' then
        -- Own TDMA slot
        can_write_r <= '1';
        
      elsif can_write_r = '1' then
        -- We already have the turn, check if it ends or not
        can_write_r <= '1';

        -- Own turn ends, if max #words sent, own slot ends, another wrapper's
        -- slot starts, or 
        if (send_counter_r >= unsigned(max_send_in (counter_width_g-1 downto 0))
            and (av_out_s = '0' or separate_addr_g = 1))  -- 
          or ((curr_slot_own_in = '1' and curr_slot_ends_in = '1')  -- tdma slot ends
              or (next_slot_own_in = '0' and next_slot_starts_in = '1'))
          or (lock_in = '1' and writing = '0')  -- someone takes it
          or writing = '0'              -- we stop using it for some reason
        then
          can_write_r <= '0';
        end if;
        
      elsif prior_match = '1' and lock_in = '0' then
        -- We got a turn through competition reserving.
        if can_write_r = '0' and can_write_r_r = '0' then
          -- This condition prevents us from taking the bus again right away
          -- when we lost it.
          can_write_r <= '1';
        end if;
        
      end if;

    end if;
  end process evaluate_can_write;


  new_turn <= can_write_r and not can_write_r_r;

  -------------------------------------------------------------------------------
  -- 5. OUTPUT DATA MUX AND CONTROL
  -- 5a) MULTIPLEXED ADDRESS AND DATA BUSES
  -----------------------------------------------------------------------------
  norm_connect_output : if separate_addr_g = 0 generate
    
    connect_output : process (empty_in, new_turn, new_turn_stay_r, av_in,
                              comm_in, can_write_r, data_in, addr_r, full_in,
                              last_was_cfg_rd_r, cfg_rd_rdy_r, cfg_ret_addr_in,
                              cfg_data_in_r, new_turn_ack_r)
    begin

      new_turn_ack <= '0';              -- defaults
      cfg_rd_ack   <= '0';
      writing      <= '0';
      reading      <= '0';
      lock_out     <= '0';

      if cfg_rd_rdy_r = '0' and can_write_r = '1'
        and (new_turn = '1' or new_turn_stay_r = '1') then
        -- Send the config return address

        -- This branch should be optimized away when cfg_re_g == 0
        --  as condition will always be false

        av_out_s                          <= '1';
        comm_out                          <= MSG_WRNP_c;
        data_out                          <= (others => '0');
        data_out(addr_width_g-1 downto 0) <= cfg_ret_addr_in;

        if full_in = '0' then
          lock_out     <= '1';
          reading      <= '0';
          writing      <= '1';
          new_turn_ack <= '1';
        end if;
        
      elsif cfg_rd_rdy_r = '0' and new_turn_ack_r = '1'
        and can_write_r = '1' then
        -- Send the read config data

        -- This branch should be optimized away when cfg_re_g == 0
        --  as condition will always be false

        av_out_s <= '0';
        comm_out <= MSG_WRNP_c;
        data_out <= cfg_data_in_r;

        if full_in = '0' then
          reading    <= '0';
          writing    <= '1';
          cfg_rd_ack <= '1';
          lock_out   <= '1';
        end if;
        
      elsif empty_in = '0' and can_write_r = '1'
        and (new_turn = '1' or new_turn_stay_r = '1' or last_was_cfg_rd_r = '1')
      then
        -- We want to send some data, and we just* got our turn
        -- First we always send address
        
        --  *Reply to config read may have been sent already, if cfg_re_g == 1


        if full_in = '0' then
          writing      <= '1';
          lock_out     <= '1';
          new_turn_ack <= not last_was_cfg_rd_r;  -- don't ack if not necessary
        end if;

        if av_in = '1' then
          -- We have a new address in FIFO
          data_out <= data_in;
          if full_in = '0' then
            reading <= '1';
          end if;
        else
          -- Retransfer the old address from register, don't read fifo.
          data_out                          <= (others => '0');
          data_out(addr_width_g-1 downto 0) <= addr_r;
          reading                           <= '0';
        end if;

        av_out_s <= '1';
        comm_out <= comm_in;

        
      elsif empty_in = '0' and can_write_r = '1' then
        -- Just transfer the data.
        if full_in = '0' then
          writing  <= '1';
          lock_out <= '1';
          reading  <= '1';
        end if;

        data_out <= data_in;
        av_out_s <= av_in;
        comm_out <= comm_in;
        
      else
        -- Nothing to transfer.
        writing  <= '0';
        data_out <= (others => '0');
        lock_out <= '0';
        comm_out <= (others => '0');
        av_out_s <= '0';
        reading  <= '0';
        
        
      end if;
    end process connect_output;

  end generate norm_connect_output;

  -----------------------------------------------------------------------------
  -- 5. OUTPUT DATA MUX AND CONTROL
  -- 5b) SEPARATED ADDRESS AND DATA BUSES
  -----------------------------------------------------------------------------
  sad_connect_output : if separate_addr_g = 1 generate
    
    sad_connect_output : process (empty_in, new_turn, new_turn_stay_r, av_in,
                                  comm_in, can_write_r, data_in,
                                  full_in, last_was_cfg_rd_r, cfg_rd_rdy_r,
                                  cfg_ret_addr_in, cfg_data_in_r,
                                  tx_interrupted_r, data_r, comm_r)
    begin

      new_turn_ack <= '0';              -- defaults
      cfg_rd_ack   <= '0';
      retransfer   <= '0';
      writing      <= '0';
      lock_out     <= '0';
      reading      <= '0';

      if last_was_cfg_rd_r = '1' and full_in = '0' then
        cfg_rd_ack <= '1';
      end if;

      if cfg_rd_rdy_r = '0' and can_write_r = '1'
        and (new_turn = '1' or new_turn_stay_r = '1') then
        -- Send config return address

        -- This branch should be optimized away when cfg_re_g == 0
        --  as condition will always be false

        av_out_s <= '1';

        comm_out                                                  <= MSG_WRNP_c;
        data_out(data_width_g-1 downto data_width_g-addr_width_g) <=
          cfg_ret_addr_in;
        data_out(data_width_g-addr_width_g-1 downto 0) <=
          cfg_data_in_r;

        if full_in = '0' then
          reading      <= '0';
          writing      <= '1';
          new_turn_ack <= '1';
          lock_out     <= '1';
        end if;
        
      elsif (empty_in = '0' or tx_interrupted_r = '1') and can_write_r = '1'
        and (new_turn = '1' or new_turn_stay_r = '1' or last_was_cfg_rd_r = '1')
      then
        -- We want to send, and we just* got our turn
        --  *Reply to config read may have been sent already, if cfg_re_g == 1

        if full_in = '0' then
          writing      <= '1';
          lock_out     <= '1';
          new_turn_ack <= not last_was_cfg_rd_r;  -- don't ack if not necessary
        end if;

        if tx_interrupted_r = '1' then
          -- We need to retransfer the previous data(incl. addr)
          data_out <= data_r;
          comm_out <= comm_r;
          if full_in = '0' then
            reading    <= '0';
            retransfer <= '1';
          end if;
        else
          data_out <= data_in;
          comm_out <= comm_in;
          if full_in = '0' then
            reading <= '1';
          end if;
        end if;

        av_out_s <= '1';
        

      elsif empty_in = '0' and can_write_r = '1' then
        -- Just transfer the data.        
        data_out <= data_in;
        av_out_s <= av_in;
        comm_out <= comm_in;

        if full_in = '0' then
          writing  <= '1';
          lock_out <= '1';
          reading  <= '1';
        end if;
        
      else
        -- Nothing to transfer.
        writing  <= '0';
        data_out <= (others => '0');
        lock_out <= '0';
        comm_out <= (others => '0');
        av_out_s <= '0';
        reading  <= '0';
        
        
      end if;
    end process sad_connect_output;

  end generate sad_connect_output;

  re_out <= reading;

  -------------------------------------------------------------------------------
  -- 6. ARBITRATION SCHEMES
  -------------------------------------------------------------------------------

  -- Process Count_Priorities:
  -- Arbitration type depends port on arb_type_in:
  -- round-robin ("00"), priority ("01") and
  -- prior+round-robin ("10").
  -- Dynamic arbitration ("11") is done in a separate entity.
  Count_Priorities : process (clk, rst_n)
  begin  -- process Count_Priorities
    if rst_n = '0' then                 -- asynchronous reset (active low)
      prior_counter_arb_r <= (others => '0');
      switch_arb_r        <= 0;
      arb_type_r          <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Assign internal arb_type-register according to ctrl-signal coming from
      -- cfg_mem. 
      if arb_type_in = "00" then
        -- round-robin
        arb_type_r <= "00";
        
      elsif arb_type_in = "01" then
        -- priority, actually 01
        arb_type_r <= "01";

      elsif arb_type_in = "10" then
        -- prior+roundrob, "10"

        if switch_arb_r = switch_arb_c - 1 then
          switch_arb_r <= 0;
          arb_type_r   <= "0" & not arb_type_r (0);
          
        else
          switch_arb_r <= switch_arb_r + 1;
          arb_type_r   <= arb_type_r;          
        end if;
        
      else
        arb_type_r <= "11";
      end if;  -- arb_type_in


      -- Increase priority_counter when bus is idle
      if lock_in = '0' and arb_type_r /= "11" then
        
        if prior_counter_arb_r = n_agents_in (id_width_g-1 downto 0) then
          -- Priorities rollover and start from 1 (zero is not allowed)
          prior_counter_arb_r <= std_logic_vector(to_unsigned(1, id_width_g));
        else
          prior_counter_arb_r <= std_logic_vector(unsigned(prior_counter_arb_r) +1);
        end if;

        
      else
        -- real arbitration types. now only prior + round rob
        if arb_type_r = "00" then
          -- In round-robin, priority remains the samem when
          -- bus reserved, 
          prior_counter_arb_r <= prior_counter_arb_r;

        elsif arb_type_r = "01" then
          -- In priority, priority counter starts over from 1 when bus gets reserved
          prior_counter_arb_r <= std_logic_vector(to_unsigned(1, id_width_g));

        else
          -- "lottery"
          -- counter is assigned below in separate process (inside if-generate)
          --          prior_counter_arb_r <= arb_agent_r;
        end if;
        
      end if;  -- lock & arb_type
    end if;  --rst_n      

  end process Count_Priorities;

  -- This component randomizes who gets the turn. Number of
  -- lottery tickets changes dynamically so that active units get more.
  -- This can be disabled to minimize area.
  dyn : if dyn_arb_enable_c = 1 generate
    dyn_arb_1 : dyn_arb
      generic map (
        id_width_g => id_width_g,
        n_agents_g => n_agents_g
        )
      port map (
        clk           => clk,
        rst_n         => rst_n,
        bus_lock_in   => lock_in,
        arb_agent_out => dyn_arb_prior
      );

  -- Select either counter value or one from dyn_arb
  assign_priocount : process (dyn_arb_prior, arb_type_in, prior_counter_arb_r)
    begin  -- process assign priocount
      if arb_type_in = "11" then
        prior <= dyn_arb_prior;
      else
        prior <= prior_counter_arb_r;
      end if;
    end process assign_priocount;
  end generate dyn;

  -- Check if own priority matches (=own turn begins)
  Check_Prior : process (prior_in, prior)
  begin
    if prior = prior_in (id_width_g-1 downto 0) then
      prior_match <= '1';
    else
      prior_match <= '0';
    end if;
  end process Check_Prior;


  notdyn : if dyn_arb_enable_c /= 1 generate
    assert arb_type_in /= "11"
      report "ERROR! ARB TYPE RANDOM BUT DYN ARB ENABLE = 0"
      severity failure;
    prior <= prior_counter_arb_r;
  end generate notdyn;


end rtl;
