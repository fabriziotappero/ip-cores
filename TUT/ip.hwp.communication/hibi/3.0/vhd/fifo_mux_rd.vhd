-------------------------------------------------------------------------------
-- Title      : HIBI fifo mux rd
-- Project    : Nocbench, Funbase
-------------------------------------------------------------------------------
-- File       : fifo_mux_rd.vhd
-- Authors    : Lasse Lehtonen
-- Company    : Tampere University of Technology
-- Created    : 2011-10-25
-- Last update: 2011-11-28
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Read side logic for double fifos
--
-- Makes two fifos look like a single fifo for the reader. Fifo 0 has higher
-- priority. This block adds additional address flits in normal mode
-- (multiplexed address and data) if high and low priority transfers get mixed
-- together. In sad mode (simultaneous addr+data), this does not happen.
-- 
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Tampere University of Technology
--
-- 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-10-25  1.0      ase     Created
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

use work.hibiv3_pkg.all;


entity fifo_mux_rd is

  generic (
    data_width_g    : integer;
    comm_width_g    : integer;
    separate_addr_g : integer;
    debug_g         : integer := 0
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    data_0_in  : in  std_logic_vector (data_width_g-1 downto 0);
    comm_0_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    av_0_in    : in  std_logic;
    one_d_0_in : in  std_logic;
    empty_0_in : in  std_logic;
    re_0_Out   : out std_logic;

    data_1_in  : in  std_logic_vector (data_width_g-1 downto 0);
    comm_1_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    av_1_in    : in  std_logic;
    one_d_1_in : in  std_logic;
    empty_1_in : in  std_logic;
    re_1_Out   : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    av_out    : out std_logic;
    one_d_Out : out std_logic;
    empty_Out : out std_logic
    );

end fifo_mux_rd;


architecture rtl of fifo_mux_rd is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- REGISTERS
  -----------------------------------------------------------------------------
  -- Mux must repeat the latest address when the FIFO changes and there is data
  -- coming from the FIFO. This is called addr reinjection.
  --
  -- Last address+comm flits, for reinjection if switching fifos between
  -- transmissions
  signal last_addr_0_r : std_logic_vector(data_width_g-1 downto 0);
  signal last_comm_0_r : std_logic_vector(comm_width_g-1 downto 0);
  signal last_addr_1_r : std_logic_vector(data_width_g-1 downto 0);
  signal last_comm_1_r : std_logic_vector(comm_width_g-1 downto 0);

  -- '1' if reinjection of address flit is needed
  signal reinject_0_r : std_logic;
  signal reinject_1_r : std_logic;

  -- '1' if only address flit has been sent from the corresponding fifo.
  -- Then, one must wait for data from the same fifo before changing the fifo.
  signal only_addr_read_0_r : std_logic;
  signal only_addr_read_1_r : std_logic;

  -- '0' when using fifo_0, '1' otherwise
  signal fifo_select_r : std_logic;

  -- '1' when fifo select is locked (because of exclusive data access)
  -- Lock stays on until there is a specific 'release lock' command arrives
  signal excl_locked_r : std_logic;

  -----------------------------------------------------------------------------
  -- COMBINATORIAL SIGNALS
  -----------------------------------------------------------------------------
  signal empty_out_s : std_logic;
  signal re_0_out_s  : std_logic;
  signal re_1_out_s  : std_logic;
  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- COMMON PART
  -----------------------------------------------------------------------------
  empty_out <= empty_out_s;
  re_0_out  <= re_0_out_s;
  re_1_out  <= re_1_out_s;

  -----------------------------------------------------------------------------
  -- MULTIPLEXED ADDRESS AND DATA BUSES
  -----------------------------------------------------------------------------
  normal_mode : if separate_addr_g = 0 generate

    --
    -- Decide from which FIFO, the data goes to the reader
    -- 
    main_p : process (clk, rst_n) is
      variable only_addr_read_0_v : std_logic;
      variable only_addr_read_1_v : std_logic;
      variable excl_locked_v      : std_logic;
    begin  -- process main_p
      if rst_n = '0' then               -- asynchronous reset (active low)

        fifo_select_r      <= '0';
        --last_addr_0_r      <= (others => '0');
        --last_comm_0_r      <= (others => '0');
        --last_addr_1_r      <= (others => '0');
        --last_comm_1_r      <= (others => '0');
        only_addr_read_0_r <= '0';
        only_addr_read_1_r <= '0';
        reinject_0_r       <= '0';
        reinject_1_r       <= '0';
        excl_locked_r      <= '0';
        
      elsif clk'event and clk = '1' then  -- rising clock edge

        -- Latch address flits when available
        if empty_0_in = '0' and av_0_in = '1' then
          last_addr_0_r <= data_0_in;
          last_comm_0_r <= comm_0_in;
        end if;

        if empty_1_in = '0' and av_1_in = '1' then
          last_addr_1_r <= data_1_in;
          last_comm_1_r <= comm_1_in;
        end if;


        -- Check if only address flits have been sent.
        -- One cannot change the input fifo before some data has arrived after
        -- the addr.
        only_addr_read_0_v := only_addr_read_0_r;
        only_addr_read_1_v := only_addr_read_1_r;

        if fifo_select_r = '0' then

          if reinject_0_r = '1' then
            if re_0_out_s = '1' then
              only_addr_read_0_v := '1';
            end if;
          else
            if av_0_in = '1' and re_0_out_s = '1' and empty_0_in = '0' then
              only_addr_read_0_v := '1';
            elsif av_0_in = '0' and re_0_out_s = '1' then
              only_addr_read_0_v := '0';
            end if;
          end if;

        else
          
          if reinject_1_r = '1' then
            if re_1_out_s = '1' then
              only_addr_read_1_v := '1';
            end if;
          else
            if av_1_in = '1' and re_1_out_s = '1' and empty_1_in = '0' then
              only_addr_read_1_v := '1';
            elsif av_1_in = '0' and re_1_out_s = '1' then
              only_addr_read_1_v := '0';
            end if;
          end if;
          
        end if;

        only_addr_read_0_r <= only_addr_read_0_v;
        only_addr_read_1_r <= only_addr_read_1_v;

        -- Select signal must be locked so that wrong priority data
        -- can't intervene when the right priority fifo is empty
        -- momentarily
        excl_locked_v := excl_locked_r;

        if fifo_select_r = '0' then
          if comm_0_in = EXCL_LOCK_c and re_0_out_s = '1' then
            excl_locked_v := '1';
          elsif comm_0_in = EXCL_RELEASE_c and re_0_out_s = '1' then
            excl_locked_v := '0';
          end if;
        end if;

        excl_locked_r <= excl_locked_v;

        -- Decide which fifo to use
        if excl_locked_v = '0' then
          
          if fifo_select_r = '0' then

            if only_addr_read_0_r = '0' and only_addr_read_0_v = '0' and
              ((av_0_in = '1' and one_d_0_in = '1')
               or (empty_0_in = '1'))             
              and empty_1_in = '0'
              and (av_1_in = '0' or one_d_1_in = '0') then
              fifo_select_r <= '1';
            end if;

          else

            if only_addr_read_1_r = '0' and only_addr_read_1_v = '0'
              and empty_0_in = '0'
              and (av_0_in = '0' or one_d_0_in = '0') then
              fifo_select_r <= '0';
            end if;
            
          end if;

        end if;

        -- Check the need for reinjection
        if fifo_select_r = '0' then

          if empty_1_in = '0' and av_1_in = '0' then
            reinject_1_r <= '1';
          else
            reinject_1_r <= '0';
          end if;

          if re_in = '1' then
            reinject_0_r <= '0';
          end if;
          
        else

          if empty_0_in = '0' and av_0_in = '0' then
            reinject_0_r <= '1';
          else
            reinject_0_r <= '0';
          end if;

          if re_in = '1' then
            reinject_1_r <= '0';
          end if;
          
        end if;
        

      end if;
    end process main_p;


    -- Forward combinatorially the correct data to the reader: either from one
    -- of the FIFOs, or by reinjecting the latest addr again.
    mux_p : process (fifo_select_r, data_0_in, data_1_in, comm_0_in, comm_1_in,
                     av_0_in, av_1_in, one_d_0_in, one_d_1_in, empty_0_in,
                     empty_1_in, re_in, last_addr_0_r, last_addr_1_r,
                     last_comm_0_r, last_comm_1_r, reinject_0_r,
                     reinject_1_r, empty_out_s) is
    begin  -- process mux_p

      if fifo_select_r = '0' then

        if reinject_0_r = '0' then
          data_out    <= data_0_in;
          comm_out    <= comm_0_in;
          av_out      <= av_0_in;
          one_d_out   <= one_d_0_in and not av_0_in;
          empty_out_s <= empty_0_in or (one_d_0_in and av_0_in);
          re_0_out_s  <= re_in and not (empty_0_in or (one_d_0_in and av_0_in));
          re_1_out_s  <= '0';
        else
          data_out    <= last_addr_0_r;
          comm_out    <= last_comm_0_r;
          av_out      <= '1';
          one_d_out   <= '0';
          empty_out_s <= '0';
          re_0_out_s  <= '0';
          re_1_out_s  <= '0';
        end if;
        
        
      else

        if reinject_1_r = '0' then
          data_out    <= data_1_in;
          comm_out    <= comm_1_in;
          av_out      <= av_1_in;
          one_d_out   <= one_d_1_in and not av_1_in;
          empty_out_s <= empty_1_in or (one_d_1_in and av_1_in);
          re_0_out_s  <= '0';
          re_1_out_s  <= re_in and not (empty_1_in or (one_d_1_in and av_1_in));
        else
          data_out    <= last_addr_1_r;
          comm_out    <= last_comm_1_r;
          av_out      <= '1';
          one_d_out   <= '0';
          empty_out_s <= '0';
          re_0_out_s  <= '0';
          re_1_out_s  <= '0';
        end if;
        
      end if;

      -- pragma synthesis_off
      -- pragma translate_off

      if debug_g > 0 and empty_out_s = '1' then

        data_out <= (others => 'X');
        comm_out <= (others => 'X');
        
      end if;

      -- pragma translate_on
      -- pragma synthesis_on
      
    end process mux_p;
    

  end generate normal_mode;

  -----------------------------------------------------------------------------
  -- SEPARATED ADDRESS AND DATA BUSES
  -- Actually, addr and data are concatenated into a wide data bus. This is
  -- much simpler case than above.
  -----------------------------------------------------------------------------
  sad_mode : if separate_addr_g = 1 generate

    fifo_sel_p : process (clk, rst_n) is
      variable excl_locked_v : std_logic;
    begin  -- process fifo_sel_p
      if rst_n = '0' then               -- asynchronous reset (active low)

        fifo_select_r <= '0';
        excl_locked_r <= '0';
        
      elsif clk'event and clk = '1' then  -- rising clock edge

        excl_locked_v := excl_locked_r;

        -- Select signal must be locked so that lower priority data
        -- can't intervene when the higher priority fifo is empty
        -- momentarily
        if fifo_select_r = '0' then
          if comm_0_in = EXCL_LOCK_c and re_0_out_s = '1' then
            excl_locked_v := '1';
          elsif comm_0_in = EXCL_RELEASE_c and re_0_out_s = '1' then
            excl_locked_v := '0';
          end if;
        end if;

        excl_locked_r <= excl_locked_v;

        if excl_locked_v = '0' then
          fifo_select_r <= empty_0_in;
        end if;
        
      end if;
    end process fifo_sel_p;

    -- Forward combinatorially the correct data to the reader from one
    -- of the FIFOs.
    mux_p : process (fifo_select_r, data_0_in, data_1_in, comm_0_in, comm_1_in,
                     av_0_in, av_1_in, one_d_0_in, one_d_1_in, empty_0_in,
                     empty_1_in, re_in, empty_out_s) is
    begin  -- process mux_p

      if fifo_select_r = '0' then

        data_out    <= data_0_in;
        comm_out    <= comm_0_in;
        av_out      <= av_0_in;
        one_d_out   <= one_d_0_in;
        empty_out_s <= empty_0_in;
        re_0_out_s  <= re_in and not empty_0_in;
        re_1_out_s  <= '0';
        
      else

        data_out    <= data_1_in;
        comm_out    <= comm_1_in;
        av_out      <= av_1_in;
        one_d_out   <= one_d_1_in;
        empty_out_s <= empty_1_in;
        re_0_out_s  <= '0';
        re_1_out_s  <= re_in and not empty_1_in;
        
      end if;

      -- pragma synthesis_off
      -- pragma translate_off

      if debug_g > 0 and empty_out_s = '1' then

        data_out <= (others => 'X');
        comm_out <= (others => 'X');
        
      end if;

      -- pragma translate_on
      -- pragma synthesis_on
      
    end process mux_p;
    
  end generate sad_mode;

end rtl;

