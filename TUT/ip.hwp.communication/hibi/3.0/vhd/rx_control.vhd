-------------------------------------------------------------------------------
-- Title      : HIBI RX Control
-- Project    : Nocbench, Funbase
-------------------------------------------------------------------------------
-- File       : rx_control.vhd
-- Authors    : Lasse Lehtonen
-- Company    : Tampere University of Technology
-- Created    :
-- Last update: 2011-11-28
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Receive side control logic
-- 
-- Main function is to halt bus if getting data that doesn't fit in RX buffers.
-- Bus is also halted if configure mem is tried to be read/written and previous
-- config mem read hasn't been already replied to or this wrappper is locked
-- by exclusive lock and getting something other than exclusive commands.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Tampere University of Technology
--
-- 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-10-13  1.0      ase     Created
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



entity rx_control is
  generic (
    data_width_g     : integer;
    addr_width_g     : integer;
    id_width_g       : integer;
    cfg_addr_width_g : integer;
    cfg_re_g         : integer;
    cfg_we_g         : integer;
    separate_addr_g  : integer;
    is_bridge_g      : integer
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Bus interface
    av_in    : in  std_logic;
    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    comm_in  : in  std_logic_vector(comm_width_c-1 downto 0);
    full_out : out std_logic;

    -- IP (fifo) side interface
    data_0_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_0_out : out std_logic_vector(comm_width_c-1 downto 0);
    av_0_out   : out std_logic;
    we_0_out   : out std_logic;
    full_0_in  : in  std_logic;
    one_p_0_in : in  std_logic;

    data_1_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_1_out : out std_logic_vector(comm_width_c-1 downto 0);
    av_1_out   : out std_logic;
    we_1_out   : out std_logic;
    full_1_in  : in  std_logic;
    one_p_1_in : in  std_logic;

    -- Address decoder interface
    addr_match_in       : in std_logic;  -- data is for this IP
    id_match_in         : in std_logic;  -- Configure data is for this wrapper
    norm_cmd_in         : in std_logic;  -- '1' for normal commands
    msg_cmd_in          : in std_logic;  -- '1' for normal commands
    conf_re_cmd_in      : in std_logic;  -- '1' for conf read
    conf_we_cmd_in      : in std_logic;  -- '1' for conf write
    excl_lock_cmd_in    : in std_logic;  -- '1' for exclusive lock
    excl_data_cmd_in    : in std_logic;  -- '1' for exclusive read/write
    excl_release_cmd_in : in std_logic;  -- '1' for exclusive release

    -- Configure memory related (to cfg_mem and tx_control)
    cfg_rd_rdy_in    : in  std_logic;
    cfg_we_out       : out std_logic;
    cfg_re_out       : out std_logic;
    cfg_addr_out     : out std_logic_vector(cfg_addr_width_g-1 downto 0);
    cfg_data_out     : out std_logic_vector
    (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
    cfg_ret_addr_out : out std_logic_vector(addr_width_g-1 downto 0)
    );

end rx_control;




architecture rtl of rx_control is

  -----------------------------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------------------------
  function isBridge(constant is_bridge : integer)
    return std_logic is
  begin  -- function isBridge
    if is_bridge /= 0 then
      return '1';
    else
      return '0';
    end if;
  end function isBridge;

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant is_bridge_c : std_logic := isBridge(is_bridge_g);

  -----------------------------------------------------------------------------
  -- OUPUT REGISTERS
  -----------------------------------------------------------------------------

  -- Hibi side
  -- '1' when block can't accept incoming transfer
  signal full_out_r : std_logic;

  -- IP (fifo) side, two priorities
  signal data_0_out_r : std_logic_vector(data_width_g-1 downto 0);
  signal comm_0_out_r : std_logic_vector(comm_width_c-1 downto 0);
  signal av_0_out_r   : std_logic;
  signal we_0_out_r   : std_logic;

  signal data_1_out_r : std_logic_vector(data_width_g-1 downto 0);
  signal comm_1_out_r : std_logic_vector(comm_width_c-1 downto 0);
  signal av_1_out_r   : std_logic;
  signal we_1_out_r   : std_logic;

  -- Config mem side (cfg_mem and tx_control)
  signal cfg_we_out_r   : std_logic;
  signal cfg_re_out_r   : std_logic;
  signal cfg_addr_out_r : std_logic_vector(cfg_addr_width_g-1 downto 0);
  signal cfg_data_out_r : std_logic_vector
    (data_width_g-1-(separate_addr_g*addr_width_g) downto 0);
  signal cfg_ret_addr_out_r : std_logic_vector(addr_width_g-1 downto 0);

  -----------------------------------------------------------------------------
  -- OTHER REGISTERS
  -----------------------------------------------------------------------------

  -- '1' for the first words of config read/write
  signal cfg_re_first_r : std_logic;
  signal cfg_we_first_r : std_logic;

  -- '1' when rx_control is locked by exclusive access commands
  signal excl_locked_r : std_logic;

  -- '1' when output register to fifo should be written to fifo
  -- but fifo is full
  signal fifo_0_regs_in_use_r : std_logic;
  signal fifo_1_regs_in_use_r : std_logic;

  -- '1' when fifo side regs are being emptied
  signal fifo_0_regs_we_r : std_logic;
  signal fifo_1_regs_we_r : std_logic;
  
begin

  -----------------------------------------------------------------------------
  -- CONNECT OUTPUTS 
  -----------------------------------------------------------------------------  
  data_0_out       <= data_0_out_r;
  comm_0_out       <= comm_0_out_r;
  av_0_out         <= av_0_out_r;
  we_0_out         <= we_0_out_r;
  data_1_out       <= data_1_out_r;
  comm_1_out       <= comm_1_out_r;
  av_1_out         <= av_1_out_r;
  we_1_out         <= we_1_out_r;
  cfg_we_out       <= cfg_we_out_r;
  cfg_re_out       <= cfg_re_out_r;
  cfg_addr_out     <= cfg_addr_out_r;
  cfg_data_out     <= cfg_data_out_r;
  cfg_ret_addr_out <= cfg_ret_addr_out_r;
  full_out         <= full_out_r;

  -----------------------------------------------------------------------------
  -- SYNCHRONOUS LOGIC
  -----------------------------------------------------------------------------
  main_p : process (clk, rst_n) is

    variable full_out_v           : std_logic;
    variable cfg_re_out_v         : std_logic;
    variable cfg_we_out_v         : std_logic;
    variable we_0_out_v           : std_logic;
    variable we_1_out_v           : std_logic;
    variable fifo_0_regs_in_use_v : std_logic;
    variable fifo_1_regs_in_use_v : std_logic;
    
  begin  -- process main_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      full_out_r <= '0';

      data_0_out_r <= (others => '0');
      comm_0_out_r <= (others => '0');
      av_0_out_r   <= '0';
      we_0_out_r   <= '0';

      data_1_out_r <= (others => '0');
      comm_1_out_r <= (others => '0');
      av_1_out_r   <= '0';
      we_1_out_r   <= '0';

      cfg_we_out_r       <= '0';
      cfg_re_out_r       <= '0';
      cfg_addr_out_r     <= (others => '0');
      cfg_data_out_r     <= (others => '0');
      cfg_ret_addr_out_r <= (others => '0');

      excl_locked_r        <= '0';
      fifo_0_regs_in_use_r <= '0';
      fifo_1_regs_in_use_r <= '0';
      cfg_we_first_r       <= '0';
      cfg_re_first_r       <= '0';
      fifo_0_regs_we_r     <= '0';
      fifo_1_regs_we_r     <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge


      ------------------------------------------------------------------------
      -- Full output
      -------------------------------------------------------------------------
      -- Block will be or pretend to be full:
      -- IF getting normal command and the fifo is (/becoming) full
      -- OR getting normal command and locked by exclusive commands

      -- OR getting exclusive commands and full,
      --    only bridges pass excl_lock and excl_release
      
      -- OR being bridge and conf data to the other side
      -- OR getting conf command and previous conf mem read is not yet answered
      --    unless the previous command was conf read and this cycle is the
      --    return address

      full_out_v :=
        (((addr_match_in and norm_cmd_in and (full_1_in or one_p_1_in)) or
          (addr_match_in and norm_cmd_in and excl_locked_r) or
          (addr_match_in and msg_cmd_in and (full_0_in or one_p_0_in)) or
          (addr_match_in and msg_cmd_in and excl_locked_r) or

          (addr_match_in and excl_data_cmd_in and (full_0_in or one_p_0_in)) or
          (--is_bridge_c and -- forwanding these too
            addr_match_in
            and (excl_lock_cmd_in or excl_release_cmd_in)
            and (full_0_in or one_p_0_in)) or
          
          (is_bridge_c and addr_match_in and (conf_re_cmd_in or conf_we_cmd_in)
           and (full_0_in or one_p_0_in))
          ) and
         not full_out_r) or
        
        (id_match_in and (conf_re_cmd_in or conf_we_cmd_in)
         and not cfg_rd_rdy_in and not cfg_re_out_r);

      full_out_r <= full_out_v;

      ------------------------------------------------------------------------
      -- Configuration
      -------------------------------------------------------------------------
      -- Conf mem will be read, if not (pretending) full:
      -- IF getting read command and previous cycle was not read command
      cfg_re_out_v :=
        (id_match_in and not full_out_v and conf_re_cmd_in
         and not cfg_re_out_r);

      -- Conf mem will be written, when not full:
      -- IF getting conf write command
      cfg_we_out_v := (id_match_in and not full_out_v and conf_we_cmd_in);

      if separate_addr_g = 0 then

        cfg_we_first_r <= cfg_we_out_v and not cfg_we_first_r;
        cfg_we_out_r   <= cfg_we_first_r;

        cfg_re_first_r <= cfg_re_out_v and not cfg_re_first_r;
        cfg_re_out_r   <= cfg_re_first_r;

        -- Set conf mem address:
        -- IF conf_re or conf_we will go high next cycle
        -- ELSE keep the old value
        if (cfg_re_out_v = '1' and cfg_re_first_r = '0')
          or (cfg_we_out_v = '1' and cfg_we_first_r = '0')
        then
          cfg_addr_out_r <= data_in(cfg_addr_width_g-1 downto 0);
        end if;

        -- Set config data
        -- IF writing to conf memory
        -- ELSE keep the previous value
        if cfg_we_first_r = '1' then
          cfg_data_out_r <= data_in;
        end if;

        -- Set config return address
        -- IF previous cycle was first conf read command
        -- ELSE keep the previous value
        if cfg_re_first_r = '1' then
          cfg_ret_addr_out_r <= data_in(addr_width_g-1 downto 0);
        end if;

      else
        -- hibi in SAD mode

        cfg_we_out_r <= cfg_we_out_v;
        cfg_re_out_r <= cfg_re_out_v;

        if cfg_we_out_v = '1' then
          cfg_addr_out_r <=
            data_in(data_width_g-addr_width_g+cfg_addr_width_g-1
                    downto data_width_g-addr_width_g);
          cfg_data_out_r <= data_in(data_width_g-addr_width_g-1 downto 0);
        elsif cfg_re_out_v = '1' then
          cfg_addr_out_r <=
            data_in(data_width_g-addr_width_g+cfg_addr_width_g-1
                    downto data_width_g-addr_width_g);
          cfg_ret_addr_out_r <= data_in(addr_width_g-1 downto 0);
        end if;
        
      end if;

      ------------------------------------------------------------------------
      -- Writing to fifos
      -------------------------------------------------------------------------
      -- Write to fifo (towards IP), when not full:
      -- IF normal commands
      -- OR exclusive data commands
      -- OR brigde and conf data to forward
      -- OR bridge and exclusive lock or release command
      -- OR fifo regs contain unwritten data
      we_1_out_v :=
        (addr_match_in and not full_out_v and not full_out_r and norm_cmd_in) or
        (not full_1_in and fifo_1_regs_in_use_r);
      
      we_1_out_r <= we_1_out_v;

      we_0_out_v :=
        (addr_match_in and not full_out_v and not full_out_r and excl_data_cmd_in) or
        (addr_match_in and not full_out_v and not full_out_r and msg_cmd_in) or
        (--is_bridge_c and -- forwanding these too
          addr_match_in and not full_out_v and not full_out_r and
          (excl_lock_cmd_in or excl_release_cmd_in)) or
        (is_bridge_c and addr_match_in and not full_out_v and not full_out_r and
         (conf_re_cmd_in or conf_we_cmd_in)) or
        (not full_0_in and fifo_0_regs_in_use_r);
      
      we_0_out_r <= we_0_out_v;

      -- To mark that last cycle we_out was '1' because fifo regs were
      -- being emptied
      fifo_0_regs_we_r <= (not full_0_in and fifo_0_regs_in_use_r);
      fifo_1_regs_we_r <= (not full_1_in and fifo_1_regs_in_use_r);

      -- Update data_out, comm_out and av_out
      -- IF writing to fifo from bus
      -- ELSE They all keep their previous values
      if (we_0_out_v = '1' or we_0_out_r = '1') and fifo_0_regs_in_use_r = '0' then
        data_0_out_r <= data_in;
        comm_0_out_r <= comm_in;
        av_0_out_r   <= av_in;
      end if;

      if (we_1_out_v = '1' or we_1_out_r = '1') and fifo_1_regs_in_use_r = '0' then
        data_1_out_r <= data_in;
        comm_1_out_r <= comm_in;
        av_1_out_r   <= av_in;
      end if;

      -- IP side registers are marked as used if fifos are full but
      --  these registers contain information not yet written
      fifo_0_regs_in_use_v :=
        (we_0_out_r and not fifo_0_regs_we_r and full_out_v and not av_in) or
        (not we_0_out_v and fifo_0_regs_in_use_r);

      fifo_0_regs_in_use_r <= fifo_0_regs_in_use_v;

      fifo_1_regs_in_use_v :=
        (we_1_out_r and not fifo_1_regs_we_r and full_out_v and not av_in) or
        (not we_1_out_v and fifo_1_regs_in_use_r);

      fifo_1_regs_in_use_r <= fifo_1_regs_in_use_v;



      ------------------------------------------------------------------------
      -- Exclusive accesses
      -------------------------------------------------------------------------      
      -- Block will be locked for exclusive accesses, when not full:
      -- IF getting lock command
      -- OR if it was already locked and not getting release command
      -- ELSE old value stays

      --excl_locked_r <=
      --  (addr_match_in and not full_out_v and excl_lock_cmd_in) or
      --  (addr_match_in and not full_out_v and excl_locked_r
      --   and not excl_release_cmd_in) or
      --  ((not addr_match_in or full_out_v) and excl_locked_r);

      if (addr_match_in and
          ((not full_out_v and not full_out_r) or
           (not fifo_0_regs_in_use_r and fifo_0_regs_in_use_v))) = '1' then

        if excl_lock_cmd_in = '1' then
          excl_locked_r <= '1';
        elsif excl_release_cmd_in = '1' then
          excl_locked_r <= '0';
        end if;
        
      end if;
      
    end if;
  end process main_p;

  
  

end rtl;
