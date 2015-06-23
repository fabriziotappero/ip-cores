-- Copyright (C) 2012
-- Ashwin A. Mendon
--
-- This file is part of SATA2 core.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.  

----------------------------------------------------------------------------------------
-- ENTITY:  sata_core 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description:  The SATA core implements the Command, Transport and Link Layers of 
--               the SATA protocol and provides a Physical Layer Wrapper for the GTX 
--               transceivers. The Physical Layer Wrapper also includes an Out of Band
--               Signaling (OOB) controller state machine which deals with initialization
--               and synchronization of the SATA link. It can interface with SATA 2
--               Winchester style Hard Disks as well as Flash-based Solid State Drives
                                                       
--               The core provides a simple interface to issue READ/WRITE sector commands.
--               The DATA interface is 32-bit FIFO like.
--               A 150 MHz input reference clock is needed for the GTX transceivers.
--               The output data is delivered 4 bytes @ 75 MHz (user output clock) 
--               for a theoretical peak bandwidth of 300 MB/s (SATA 2).
--               
--              
-- PORTS: 
      			-- Command, Control and Status --
 
--           ready_for_cmd          :  When asserted, SATA core is ready to execute new command.
--                                     This signal goes low after new_cmd is asserted.                    
--                                     It also serves as the command done signal    
-- 	     new_cmd                :  Asserted for one clock cycle to start a request        
--           cmd_type               :  "01" for READ request and "10" for WRITE request	          
--           sector_count           :  Number of sectors requested by user 
--           sector_addr            :  Starting address of request
      			
                         -- Data and User Clock --

--           sata_din               :  Data from user to Write to Disk  
--           sata_din_we            :  Write Enable to SATA Core when FULL is low 
--           sata_core_full         :  SATA Core Full- de-assert WE 
--   	     sata_dout              :  Data output from SATA Core
--           sata_dout_re           :  Read Enable from SATA asserted when EMPTY is low 
--           sata_core_empty        :  SATA Core Empty- de-assert RE
--           SATA_USER_DATA_CLK_IN  :  SATA Core Write Clock  
--           SATA_USER_DATA_CLK_OUT :  SATA Core Read Clock
--           sata_timer             :  SATA core timer output to check performance 
                         
                          --PHY Signals--
--           CLKIN_150              :  150 Mhz input reference clock for the GTX transceivers
--           reset                  :  Resets GTX and SATA core; can be tied to a software reset

--           LINKUP                 :  Indicates Link Initialization done (OOB) and SATA link is up 
        
             --GTX transmit/receive pins: Connected to the FMC_HPC pins on a ML605 board         
--           TXP0_OUT, TXN0_OUT, RXP0_IN, RXN0_IN                		
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sata_core is
  generic(
    CHIPSCOPE           : boolean := false;
    DATA_WIDTH          : natural := 32
       );
  port(
    -- ChipScope ILA / Trigger Signals
    sata_rx_frame_ila_control  : in  std_logic_vector(35 downto 0);
    sata_tx_frame_ila_control  : in  std_logic_vector(35 downto 0);
    sata_phy_ila_control       : in  std_logic_vector(35 downto 0);
    oob_control_ila_control    : in  std_logic_vector(35 downto 0);
    cmd_layer_ila_control      : in  std_logic_vector(35 downto 0);
    scrambler_ila_control      : in  std_logic_vector(35 downto 0);
    descrambler_ila_control    : in  std_logic_vector(35 downto 0);
    ---------------------------------------
    -- SATA Interface -----
      -- Command, Control and Status --
    ready_for_cmd         : out std_logic;
    new_cmd               : in  std_logic;
    cmd_type	          : in  std_logic_vector(1 downto 0);
    sector_count          : in  std_logic_vector(31 downto 0);
    sector_addr           : in  std_logic_vector(31 downto 0);
      -- Data and User Clock --
    sata_din               : in  std_logic_vector(31 downto 0); 
    sata_din_we            : in  std_logic; 
    sata_core_full         : out std_logic;
    sata_dout              : out std_logic_vector(31 downto 0); 
    sata_dout_re           : in  std_logic;
    sata_core_empty        : out std_logic;
    SATA_USER_DATA_CLK_IN  : in std_logic; 
    SATA_USER_DATA_CLK_OUT : out std_logic; 

    -- Timer --
    sata_timer            : out std_logic_vector(31 downto 0);

         -- PHY Signals
    -- Clock and Reset Signals
    CLKIN_150             : in  std_logic;
    reset                 : in  std_logic;

    LINKUP                : out std_logic;
    TXP0_OUT              : out std_logic;
    TXN0_OUT              : out std_logic;
    RXP0_IN               : in std_logic;
    RXN0_IN               : in std_logic;		
    PLLLKDET_OUT_N        : out std_logic;
    DCMLOCKED_OUT         : out std_logic
);
end sata_core;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture BEHAV of sata_core is

  -- Sata Phy
  signal sata_user_clk        : std_logic;
  --signal GTXRESET            : std_logic;
  signal LINKUP_i             : std_logic; 
  -- Sata Phy

  signal REFCLK_PAD_P_IN_i   : std_logic;
  signal REFCLK_PAD_N_IN_i   : std_logic;
 
  -- COMMAND LAYER / LINK LAYER SIGNALS  
  signal ll_ready_for_cmd_i         : std_logic;
  signal sata_ready_for_cmd_i       : std_logic;
  signal ll_cmd_start               : std_logic;
  signal ll_cmd_type                : std_logic_vector(1 downto 0);
  signal ll_dout                    : std_logic_vector(31 downto 0);
  signal ll_dout_we                 : std_logic;
  signal ll_din                     : std_logic_vector(31 downto 0);
  signal ll_din_re                  : std_logic;
  signal sector_count_int           : integer;

 -- User FIFO signals
  signal user_din_re          : std_logic;
  signal user_fifo_dout       : std_logic_vector(31 downto 0);
  signal user_fifo_full       : std_logic;
  signal user_fifo_prog_full  : std_logic;
  signal user_fifo_empty      : std_logic;

  signal write_fifo_full_i    : std_logic;
  signal read_fifo_empty      : std_logic;
    

-- USER FIFO DECLARATION
  component user_fifo
	port (
	rst: IN std_logic;
	wr_clk: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	wr_en: IN std_logic;
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	full: OUT std_logic;
	prog_full: OUT std_logic;
	empty: OUT std_logic);
  end component;

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin

  --- User Logic Fifo for writing data ---
  USER_FIFO_i : user_fifo
   		port map (
			rst => reset,
			wr_clk => SATA_USER_DATA_CLK_IN,
			din => sata_din,
			wr_en => sata_din_we,
			rd_clk => sata_user_clk,
			dout => user_fifo_dout,
			rd_en => user_din_re,
			full => user_fifo_full,
			prog_full => user_fifo_prog_full,
			empty => user_fifo_empty);

   -- SATA Core Output Signals
   ready_for_cmd    <= sata_ready_for_cmd_i;      
   --sata_core_full   <= write_fifo_full_i;
   sata_core_full   <= user_fifo_prog_full;
   sata_core_empty  <= read_fifo_empty;
   SATA_USER_DATA_CLK_OUT  <= sata_user_clk;
   LINKUP           <= LINKUP_i; 
-----------------------------------------------------------------------------
  -- Command Layer Instance
-----------------------------------------------------------------------------

  COMMAND_LAYER_i : entity work.command_layer
    generic map
    (
      CHIPSCOPE        => CHIPSCOPE 
    )
    port map
    (
      -- ChipScope Signal
      cmd_layer_ila_control  => cmd_layer_ila_control,
      -- Clock and Reset Signals
      sw_reset             => reset,
      clk                  => sata_user_clk,
      
      new_cmd              => new_cmd,
      cmd_done	           => sata_ready_for_cmd_i,
      cmd_type	           => cmd_type,
      sector_count         => sector_count,
      sector_addr          => sector_addr,
      user_din             => user_fifo_dout, 
      user_din_re_out      => user_din_re,
      user_dout            => sata_dout,
      user_dout_re         => sata_dout_re,
      write_fifo_full      => write_fifo_full_i,
      user_fifo_empty      => user_fifo_empty,
      user_fifo_full       => user_fifo_prog_full,
      sector_timer_out       => sata_timer,

    -- Signals from/to Link Layer
      ll_ready_for_cmd     => ll_ready_for_cmd_i, 
      ll_cmd_start	   => ll_cmd_start, 
      ll_cmd_type	   => ll_cmd_type, 
      ll_dout              => ll_dout, 
      ll_dout_we           => ll_dout_we, 
      ll_din               => ll_din, 
      ll_din_re            => ll_din_re 
    );

 ------------------------------------------
  -- Sata Link Layer Module Instance
  ------------------------------------------
  sector_count_int  <=  conv_integer(sector_count);

  SATA_LINK_LAYER_i: entity work.sata_link_layer 
  generic map(
    CHIPSCOPE           => CHIPSCOPE, 
    DATA_WIDTH          => DATA_WIDTH          
       )
  port map(
    -- Clock and Reset Signals
    CLKIN_150             => CLKIN_150,              
    sw_reset             => reset,
    -- ChipScope ILA / Trigger Signals
    sata_rx_frame_ila_control  => sata_rx_frame_ila_control  ,
    sata_tx_frame_ila_control  => sata_tx_frame_ila_control  ,
    oob_control_ila_control    => oob_control_ila_control,
    sata_phy_ila_control       => sata_phy_ila_control,
    scrambler_ila_control => scrambler_ila_control,
    descrambler_ila_control => descrambler_ila_control,
    ---------------------------------------
    -- Ports from/to User Logic
    read_fifo_empty      => read_fifo_empty, 
    write_fifo_full      => write_fifo_full_i,
    GTX_RESET_IN	 => reset,	  
    sector_count         => sector_count_int,
    sata_user_clk_out     => sata_user_clk,
    -- Ports from/to Command Layer 
    ready_for_cmd_out    => ll_ready_for_cmd_i, 
    new_cmd_in           => ll_cmd_start,
    cmd_type             => ll_cmd_type,
    sata_din             => ll_dout,
    sata_din_we          => ll_dout_we, 
    sata_dout            => ll_din,
    sata_dout_re         => ll_din_re, 
    ---------------------------------------
    --  Ports to SATA PHY
    REFCLK_PAD_P_IN       => REFCLK_PAD_P_IN_i,     
    REFCLK_PAD_N_IN       => REFCLK_PAD_N_IN_i,  
    TXP0_OUT              => TXP0_OUT,
    TXN0_OUT              => TXN0_OUT,
    RXP0_IN               => RXP0_IN,
    RXN0_IN               => RXN0_IN,		
    PLLLKDET_OUT_N        => PLLLKDET_OUT_N,     
    DCMLOCKED_OUT         => DCMLOCKED_OUT,
    LINKUP_led            => LINKUP_i
      );

end BEHAV;
