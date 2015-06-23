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
-- ENTITY: sata_link_layer 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description: This sub-module implements the Transport and Link Layers of the SATA Protocol
--              It is the heart of the SATA Core where the major functions of sending/receiving 
--              sequences of Frame Information Structures (FIS), packing them into 
--              Frames and sending/receiving Frames are accomplished.
--              The Master FSM deals with the Transport Layer functions of sending receiving FISs
--              using the TX and RX FSMs.      
--              The TX and RX FSMs use the crc, scrambler and primitive muxes to construct and
--         	deconstruct Frames. They also implement a Frame transmission/reception protocol.
-- PORTS: 
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sata_link_layer is
  generic(
    CHIPSCOPE           : boolean := false;
    DATA_WIDTH          : natural := 32
       );
  port(
    -- Clock and Reset Signals
    --clk                   : in  std_logic;
    sw_reset              : in  std_logic;
    -- ChipScope ILA / Trigger Signals
    sata_rx_frame_ila_control : in  std_logic_vector(35 downto 0);
    sata_tx_frame_ila_control : in  std_logic_vector(35 downto 0);
    --master_fsm_ila_control    : in  std_logic_vector(35 downto 0);
    oob_control_ila_control   : in  std_logic_vector(35 downto 0);
    sata_phy_ila_control      : in  std_logic_vector(35 downto 0);
    scrambler_ila_control    : in std_logic_vector (35 downto 0);
    descrambler_ila_control    : in std_logic_vector (35 downto 0);
    ---------------------------------------
    -- Signals from/to User Logic
    sata_user_clk_out     : out std_logic;
    GTX_RESET_IN	  : in  std_logic;
    ready_for_cmd_out     : out std_logic;
    new_cmd_in            : in  std_logic;
    cmd_type	          : in  std_logic_vector(1 downto 0);
    sector_count          : in  integer;
    sata_din              : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
    sata_din_we           : in  std_logic;
    sata_dout             : out std_logic_vector(DATA_WIDTH-1 downto 0);
    sata_dout_re          : in  std_logic;
    read_fifo_empty       : out std_logic;
    write_fifo_full       : out std_logic;
    ---------------------------------------
    --  Ports from/to SATA PHY
    REFCLK_PAD_P_IN : in std_logic;     -- MGTCLKA,  clocks GTP_X0Y0-2 
    REFCLK_PAD_N_IN : in std_logic;     -- MGTCLKA 
    TXP0_OUT              : out std_logic;
    TXN0_OUT              : out std_logic;
    RXP0_IN               : in  std_logic;
    RXN0_IN               : in  std_logic;		
    PLLLKDET_OUT_N  : out std_logic;
    DCMLOCKED_OUT         : out std_logic;
    LINKUP_led            : out std_logic;
    --GEN2_led              : out std_logic;
    CLKIN_150             : in  std_logic
      );
end sata_link_layer;


-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture BEHAV of sata_link_layer is

  -------------------------------------------------------------------------------
  -- LINK LAYER
  -------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------
  -- Constants
  -------------------------------------------------------------------------------
  --Commands
  constant IDEN_DEV     : std_logic_vector(1 downto 0) := "00";
  constant READ_DMA     : std_logic_vector(1 downto 0) := "01";
  constant WRITE_DMA    : std_logic_vector(1 downto 0) := "10";
  constant SET_FEATURES : std_logic_vector(1 downto 0) := "11";
  --Primitves
  constant SYNC     : std_logic_vector(3 downto 0) := "0000";
  constant R_RDY    : std_logic_vector(3 downto 0) := "0001";
  constant R_IP     : std_logic_vector(3 downto 0) := "0010";
  constant R_OK     : std_logic_vector(3 downto 0) := "0011";
  constant R_ERR    : std_logic_vector(3 downto 0) := "0100";
  constant X_RDY    : std_logic_vector(3 downto 0) := "0101";
  constant WTRM     : std_logic_vector(3 downto 0) := "0110";
  constant HOLD     : std_logic_vector(3 downto 0) := "0111";
  constant HOLD_ACK : std_logic_vector(3 downto 0) := "1000";
  constant CONT     : std_logic_vector(3 downto 0) := "1001";

  constant SOF      : std_logic_vector(3 downto 0) := "1010";
  constant EOF      : std_logic_vector(3 downto 0) := "1011";
  constant FIS      : std_logic_vector(3 downto 0) := "1100";
  constant PRIM_SCRM : std_logic_vector(3 downto 0) := "1101";

  constant COMMAND_FIS       : std_logic_vector(15 downto 0) := conv_std_logic_vector(5, 16);   -- (6DWORDS: 5 + 1CRC)    
  --constant DATA_FIS          : std_logic_vector(15 downto 0) := conv_std_logic_vector(259, 16);  -- 260 WORDS (130DWORDS: 1FIS_TYPE + 128DATA + 1CRC)     
  constant REG_FIS_NDWORDS   : std_logic_vector(15 downto 0) := conv_std_logic_vector(6, 16);   -- (6DWORDS: 5 + 1CRC)    
  constant DATA_FIS_NDWORDS  : integer := 130;    
  constant SECTOR_NDWORDS     : integer := 128;  -- 256 WORDS / 512 Byte Sector    
  constant NDWORDS_PER_DATA_FIS : std_logic_vector(15 downto 0) := conv_std_logic_vector(2048, 16);--128*16        
  constant NDWORDS_PER_DATA_FIS_32 : std_logic_vector(31 downto 0) := conv_std_logic_vector(2048, 32);--128*16       
  constant SYNC_COUNT_VALUE  : std_logic_vector(7 downto 0)  := conv_std_logic_vector(30, 8);    -- 50  WORDS     
  -----------------------------------------------------------------------------
  -- Finite State Machine Declaration (curr and next states)
  -----------------------------------------------------------------------------
  type MASTER_FSM_TYPE is (idle, capture_dev_sign, wait_for_cmd, H2D_REG_FIS, D2H_DMA_ACT_FIS,
            H2D_DATA_FIS, D2H_REG_FIS, D2H_DATA_FIS, D2H_PIO_SETUP, dead                           
                     );
  signal master_fsm_curr, master_fsm_next : MASTER_FSM_TYPE := idle; 
  signal master_fsm_value                  : std_logic_vector (0 to 3);


  type RX_FRAME_FSM_TYPE is (idle, send_R_RDY, send_R_IP, send_HOLD_ACK, send_R_OK, 
			send_SYNC, wait_for_X_RDY, dead 
                     );
  signal rx_frame_curr, rx_frame_next  : RX_FRAME_FSM_TYPE := idle; 
  signal rx_frame_value                : std_logic_vector (0 to 3);


  type TX_FRAME_FSM_TYPE is (idle, send_X_RDY, send_SOF, send_FIS, send_EOF, send_WTRM,
                        send_SYNC, send_HOLD_ACK, send_HOLD, dead
                     );
  signal tx_frame_curr, tx_frame_next  : TX_FRAME_FSM_TYPE := idle; 
  signal tx_frame_value                : std_logic_vector (0 to 3);
  -----------------------------------------------------------------------------
  -- Finite State Machine Declaration (curr and next states)
  -----------------------------------------------------------------------------

  signal new_cmd                       : std_logic;

  signal FIS_word_count, FIS_word_count_next : std_logic_vector(0 to 15); --Counter for FIS WORD Count (WRITE)
  signal FIS_count_value, FIS_count_value_next : std_logic_vector(0 to 15);  --Counter LIMIT for FIS WORD Count (WRITE)
  signal rx_sector_count : std_logic_vector(0 to 15); --Counter for number of received sectors
  signal tx_sector_count, tx_sector_count_next : std_logic_vector(0 to 15); --Counter for number of transmitted sectors
  signal dword_count : std_logic_vector(0 to 7);     --Counter for DWORDS in each received sector 
  signal DATA_FIS_dword_count : std_logic_vector(0 to 15);     --Counter for DWORDS in each received DATA FIS 
  signal dword_count_init_value      : std_logic_vector(0 to 31);  
  signal dword_count_value           : std_logic_vector(0 to 15);  
  signal start_rx, start_tx, rx_done, tx_done : std_logic;
  signal start_rx_next, start_tx_next, rx_done_next, tx_done_next : std_logic;
  signal prim_type_rx, prim_type_tx, prim_type       : std_logic_vector (0 to 3);
  signal prim_type_rx_next, prim_type_tx_next : std_logic_vector (0 to 3);
  signal rx_tx_state_sel, rx_tx_state_sel_next : std_logic;
  signal sync_count_rx, sync_count_rx_next : std_logic_vector (0 to 7);
  signal sync_count_tx, sync_count_tx_next : std_logic_vector (0 to 7);
  signal ready_for_cmd_next              : std_logic;
  signal ready_for_cmd                   : std_logic;
  signal frame_err, frame_err_next       : std_logic;
  signal tx_err, tx_err_next : std_logic;

  signal tx_r_rdy, tx_r_ip, tx_r_ok, tx_r_err        : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_x_rdy, tx_wtrm, tx_sof, tx_eof, tx_sync  : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_hold, tx_hold_ack, tx_cont               : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_dataout                                  : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_charisk_out                  : std_logic;
  signal tx_charisk_RX_FRAME, tx_charisk_TX_FRAME: std_logic;
  signal output_mux_sel                              : std_logic_vector(0 to 3);
  signal align_en_out                                : std_logic;

  -- Primitive Detectors
  signal SYNC_det         : std_logic;       
  signal R_RDY_det        : std_logic;       
  signal R_IP_det         : std_logic;       
  signal R_OK_det         : std_logic;       
  signal R_ERR_det        : std_logic;       
  signal SOF_det          : std_logic;       
  signal EOF_det          : std_logic;       
  signal X_RDY_det        : std_logic;       
  signal WTRM_det         : std_logic;       
  signal CONT_det         : std_logic;       
  signal HOLD_det         : std_logic;       
  signal HOLD_det_r       : std_logic;       
  signal HOLD_det_r2      : std_logic;       
  signal HOLD_det_r3      : std_logic;       
  signal HOLD_det_r4      : std_logic;       
  signal HOLD_start_det   : std_logic;       
  signal HOLD_stop_det    : std_logic;       
  signal HOLD_stop_after_ALIGN_det  : std_logic;       
  signal CORNER_CASE_HOLD : std_logic;       
  signal HOLD_ACK_det     : std_logic;       
  signal ALIGN_det        : std_logic;       
  signal ALIGN_det_r      : std_logic;       
  signal ALIGN_det_r2     : std_logic;       
  signal TWO_HOLD_det     : std_logic;
  signal TWO_HOLD_det_r   : std_logic;

  -----------------------------------------------------------------------------
  -- Internal Signals
  -----------------------------------------------------------------------------
  signal sata_user_clk : std_logic;
  signal rx_datain    : std_logic_vector(0 to DATA_WIDTH-1);       
  signal rxelecidle   : std_logic;
  signal rx_charisk_in  : std_logic_vector(3 downto 0);
  -- Debugging OOB
  signal OOB_state    : std_logic_vector (0 to 7);

  signal LINKUP           : std_logic;
  signal GEN2_led_i       : std_logic;

  -- Scrambler/DeScrambler
  signal scrambler_din                   : std_logic_vector(0 to DATA_WIDTH-1);
  signal scrambler_dout                  : std_logic_vector(0 to DATA_WIDTH-1);
  signal scrambler_en, scrambler_en_r    : std_logic;
  signal scrambler_din_re, scrambler_din_re_r : std_logic;
  signal scrambler_dout_we               : std_logic;
  signal scrambler_reset                 : std_logic;
  signal scrambler_reset_after_FIS       : std_logic;
  signal descrambler_din                 : std_logic_vector(0 to DATA_WIDTH-1);
  signal descrambler_dout                : std_logic_vector(0 to DATA_WIDTH-1);
  signal descrambler_en                  : std_logic;
  signal descrambler_din_re, descrambler_din_re_r  : std_logic;
  signal descrambler_dout_we             : std_logic;
  signal descrambler_reset               : std_logic;
  signal scrambler_count                 : std_logic_vector(0 to 15);  
  signal scrambler_count_init_value      : std_logic_vector(0 to 31);  
  signal scrambler_count_value           : std_logic_vector(0 to 15);  
  signal scrambler_count_en_reg_fis      : std_logic;  
  signal scrambler_count_en_data_fis     : std_logic; 
  
  -- CRC 
  signal crc_reset                       : std_logic;
  signal crc_din                         : std_logic_vector(0 to DATA_WIDTH-1);
  signal crc_dout                        : std_logic_vector(0 to DATA_WIDTH-1);
  signal crc_dout_r                      : std_logic_vector(0 to DATA_WIDTH-1);
  signal crc_en                          : std_logic;
 
  -----------------------------------------------------------------------------
  -- Post-DeScramble Read FIFO to Command Layer 
  -----------------------------------------------------------------------------
  signal read_fifo_re      : std_logic;
  signal read_fifo_we      : std_logic;
  signal read_fifo_empty_i : std_logic;
  signal read_fifo_almost_empty : std_logic;
  signal read_fifo_full    : std_logic;
  signal read_fifo_prog_full : std_logic;
  signal read_fifo_din     : std_logic_vector(0 to DATA_WIDTH-1);
  signal read_fifo_dout    : std_logic_vector(0 to DATA_WIDTH-1);

  -----------------------------------------------------------------------------
  -- Pre-DeScramble RX FIFO from PHY Layer
  -----------------------------------------------------------------------------
  signal rx_fifo_we        : std_logic;
  signal rx_fifo_we_next   : std_logic;
  signal rx_fifo_re        : std_logic;
  signal rx_fifo_empty     : std_logic;
  signal rx_fifo_almost_empty : std_logic;
  signal rx_fifo_full      : std_logic;
  signal rx_fifo_prog_full  : std_logic;
  signal rx_fifo_din       : std_logic_vector(0 to DATA_WIDTH-1);
  signal rx_fifo_dout      : std_logic_vector(0 to DATA_WIDTH-1);
  signal rx_fifo_data_count      : std_logic_vector(0 to 9);
  signal rx_fifo_reset      : std_logic;

  -----------------------------------------------------------------------------
  -- Pre-Scramble Write FIFO from Command Layer
  -----------------------------------------------------------------------------
  signal write_fifo_we        : std_logic;
  signal write_fifo_re        : std_logic;
  signal write_fifo_empty     : std_logic;
  signal write_fifo_almost_empty  : std_logic;
  signal write_fifo_full_i    : std_logic;
  signal write_fifo_prog_full : std_logic;
  signal write_fifo_din       : std_logic_vector(0 to DATA_WIDTH-1);
  signal write_fifo_dout      : std_logic_vector(0 to DATA_WIDTH-1);

  -----------------------------------------------------------------------------
  -- Post-Scramble TX FIFO to PHY Layer 
  -----------------------------------------------------------------------------
  signal tx_fifo_re      : std_logic;
  signal tx_fifo_re_next : std_logic;
  signal tx_fifo_we      : std_logic;
  signal tx_fifo_empty   : std_logic;
  signal tx_fifo_almost_empty : std_logic;
  signal tx_fifo_full    : std_logic;
  signal tx_fifo_prog_full  : std_logic;
  signal tx_fifo_din     : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_fifo_dout    : std_logic_vector(0 to DATA_WIDTH-1);
  signal tx_fifo_data_count      : std_logic_vector(0 to 9);

  -----------------------------------------------------------------------------
  -- Replay FIFO Signals
  -----------------------------------------------------------------------------
  signal replay_buffer_clear     : std_logic;
  signal replay_buffer_clear_next: std_logic;

  -----------------------------------------------------------------------------
  -- FIFO Declarations
  -----------------------------------------------------------------------------
   component read_write_fifo
     port (
	clk: IN std_logic;
	rst: IN std_logic;
	rd_en: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	almost_empty: OUT std_logic;
	empty: OUT std_logic;
	full: OUT std_logic;
	prog_full: OUT std_logic
        );
   end component;

   component rx_tx_fifo
     port (
	clk: IN std_logic;
	rst: IN std_logic;
	rd_en: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	almost_empty: OUT std_logic;
	empty: OUT std_logic;
	full: OUT std_logic;
	prog_full: OUT std_logic;
	data_count: OUT std_logic_vector(9 downto 0)
        );
   end component;

  -----------------------------------------------------------------------------
  -- SATA PHY Declaration
  -----------------------------------------------------------------------------
   component sata_phy 
     port (
        oob_control_ila_control: in std_logic_vector(35 downto 0);
        sata_phy_ila_control  : in  std_logic_vector(35 downto 0);
	REFCLK_PAD_P_IN       : in  std_logic;     -- MGTCLKA,  clocks GTP_X0Y0-2 
	REFCLK_PAD_N_IN       : in  std_logic;	  -- MGTCLKA 
	GTXRESET_IN	      : in  std_logic;	  -- GTP initialization
        PLLLKDET_OUT_N        : out std_logic;
	TXP0_OUT              : out std_logic;
	TXN0_OUT              : out std_logic;
	RXP0_IN               : in  std_logic;
	RXN0_IN               : in  std_logic;		
	DCMLOCKED_OUT         : out std_logic;
	LINKUP                : out std_logic;
	LINKUP_led            : out std_logic;
 	sata_user_clk         : out std_logic;
 	GEN2_led              : out std_logic;
 	align_en_out          : out std_logic;
        tx_datain             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        tx_charisk_in         : in  std_logic;
	rx_dataout            : out std_logic_vector(DATA_WIDTH-1 downto 0);
	rx_charisk_out        : out std_logic_vector(3 downto 0);
        CurrentState_out      : out std_logic_vector(7 downto 0);
        rxelecidle_out        : out std_logic;
        CLKIN_150             : in  std_logic
      );
   end component;

   component sata_rx_frame_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(3  downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(7 downto 0);
      trig3   : in std_logic_vector(3 downto 0);
      trig4   : in std_logic_vector(3 downto 0);
      trig5   : in std_logic_vector(7 downto 0);
      trig6   : in std_logic_vector(31 downto 0);
      trig7   : in std_logic_vector(31 downto 0);
      trig8   : in std_logic_vector(31 downto 0);
      trig9   : in std_logic_vector(31 downto 0);
      trig10  : in std_logic_vector(31 downto 0);
      trig11  : in std_logic_vector(7 downto 0);
      trig12  : in std_logic_vector(15 downto 0);
      trig13  : in std_logic_vector(15 downto 0);
      trig14  : in std_logic_vector(15 downto 0);
      trig15  : in std_logic_vector(31 downto 0)
    );
  end component;


  component sata_tx_frame_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(3  downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(31 downto 0);
      trig4   : in std_logic_vector(3 downto 0);
      trig5   : in std_logic_vector(31 downto 0);
      trig6   : in std_logic_vector(31 downto 0);
      trig7   : in std_logic_vector(31 downto 0);
      trig8   : in std_logic_vector(15 downto 0);
      trig9   : in std_logic_vector(15 downto 0);
      trig10  : in std_logic_vector(31 downto 0);
      trig11  : in std_logic_vector(31 downto 0);
      trig12  : in std_logic_vector(31 downto 0);
      trig13  : in std_logic_vector(15 downto 0);
      trig14  : in std_logic_vector(15 downto 0);
      trig15  : in std_logic_vector(9 downto 0)
   );
  end component;

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- LINK LAYER
-------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- PROCESS: MASTER_FSM_VALUE_PROC
  -- PURPOSE: ChipScope State Indicator Signal
  -----------------------------------------------------------------------------
  MASTER_FSM_VALUE_PROC : process (master_fsm_curr) is
  begin
    case (master_fsm_curr) is
      when idle               => master_fsm_value <= x"0";
      when capture_dev_sign   => master_fsm_value <= x"1";
      when wait_for_cmd       => master_fsm_value <= x"2";
      when H2D_REG_FIS        => master_fsm_value <= x"3";
      when D2H_DMA_ACT_FIS    => master_fsm_value <= x"4";
      when H2D_DATA_FIS       => master_fsm_value <= x"5";
      when D2H_DATA_FIS       => master_fsm_value <= x"6";
      when D2H_REG_FIS        => master_fsm_value <= x"7";
      when D2H_PIO_SETUP      => master_fsm_value <= x"8";
      when dead               => master_fsm_value <= x"9";
      when others             => master_fsm_value <= x"A";
    end case;
  end process MASTER_FSM_VALUE_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: MASTER_FSM_STATE_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  MASTER_FSM_STATE_PROC : process (sata_user_clk)
  begin
    if ((sata_user_clk'event) and (sata_user_clk = '1')) then
      if (sw_reset = '1') then
        --Initializing internal signals
        master_fsm_curr         <= idle;
        FIS_count_value         <= (others => '0');
        start_rx                <= '0';
        start_tx                <= '0';
        new_cmd                 <= '0';
        ready_for_cmd           <= '0';
      else
        -- Register all Current Signals to their _next Signals
        master_fsm_curr         <= master_fsm_next;
        FIS_count_value         <= FIS_count_value_next;
        start_rx                <= start_rx_next;
        start_tx                <= start_tx_next;
        ready_for_cmd           <= ready_for_cmd_next;
        if (new_cmd_in = '1') then
            new_cmd                 <= '1';
        else
            new_cmd                 <= '0';
        end if;
      end if;
    end if;
  end process MASTER_FSM_STATE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: MASTER_FSM_LOGIC_PROC
  -- PURPOSE: Implements a Sequence of FIS transfers for sending READ/WRITE sector
  --          command. (Transport Layer) 
  -----------------------------------------------------------------------------
  MASTER_FSM_LOGIC_PROC : process (master_fsm_curr, rx_done, tx_done, tx_err, 
                                   LINKUP, new_cmd, tx_sector_count
                                   ) is
  begin
    -- Register _next to current signals
    master_fsm_next          <= master_fsm_curr;
    FIS_count_value_next     <= (others => '0');
    start_rx_next            <= start_rx;
    start_tx_next            <= start_tx;
    ---------------------------------------------------------------------------
    -- Finite State Machine
    ---------------------------------------------------------------------------
    case (master_fsm_curr) is
      
     -- x0
     when idle =>   
         if (LINKUP = '1') then
            start_rx_next    <=  '1';
            master_fsm_next  <= capture_dev_sign;
         end if;
 
     -- x1
     when capture_dev_sign =>   
         start_rx_next    <=  '0';
         if (rx_done = '1') then
            master_fsm_next  <= wait_for_cmd;
         end if;

     -- x2
     when wait_for_cmd =>   
         if (new_cmd = '1') then
            start_tx_next    <=  '1';
            master_fsm_next  <= H2D_REG_FIS;
         end if;

     -- x3
     when H2D_REG_FIS =>   
         FIS_count_value_next <= COMMAND_FIS;
         start_tx_next    <=  '0';
         if (tx_done = '1') then
            start_rx_next    <=  '1';
            case (cmd_type) is
              when IDEN_DEV =>
                master_fsm_next   <= D2H_PIO_SETUP;
              when READ_DMA =>
                master_fsm_next   <= D2H_DATA_FIS;
              when WRITE_DMA =>
                master_fsm_next   <= D2H_DMA_ACT_FIS;
              when others =>
                master_fsm_next   <= D2H_REG_FIS;
            end case;
         end if;
         if(tx_err = '1') then
            start_tx_next    <=  '1';
            master_fsm_next  <= H2D_REG_FIS;
         end if;

     -- x4
     when D2H_DMA_ACT_FIS =>   
         start_rx_next    <=  '0';
         if (rx_done = '1') then
            start_tx_next     <=  '1';
            master_fsm_next   <= H2D_DATA_FIS;
         end if;

     -- x5
     when H2D_DATA_FIS =>   
         --FIS_count_value_next <= conv_std_logic_vector(((SECTOR_NDWORDS * sector_count) + 1), 16);
         FIS_count_value_next <= (NDWORDS_PER_DATA_FIS + 1);
         start_tx_next        <=  '0';
         if ((tx_done = '1') or (tx_err = '1')) then
            start_rx_next     <=  '1';
            if (tx_sector_count >= conv_std_logic_vector(sector_count, 16)) then  
               master_fsm_next   <= D2H_REG_FIS;
            else
               master_fsm_next   <= D2H_DMA_ACT_FIS;
            end if;
         end if;

    -- x6
     when D2H_DATA_FIS =>   
         start_rx_next    <=  '0';
         if (rx_done = '1') then
            if (cmd_type = READ_DMA) then
               start_rx_next     <=  '1';
               master_fsm_next   <= D2H_REG_FIS;
            else
               master_fsm_next   <= wait_for_cmd;
            end if;
         end if;

     -- x7
     when D2H_REG_FIS =>   
         start_rx_next    <=  '0';
         if (rx_done = '1') then
            master_fsm_next   <= wait_for_cmd;
         end if;

     -- x8
     when D2H_PIO_SETUP =>   
         start_rx_next    <=  '0';
         if (rx_done = '1') then
            start_rx_next    <=  '1';
            master_fsm_next  <= D2H_DATA_FIS;
         end if;

     -- x9
     when dead =>
         master_fsm_next   <= dead;
  
     -- xA
     when others =>
         master_fsm_next   <= dead;

   end case;
 end process MASTER_FSM_LOGIC_PROC;

 ready_for_cmd_next  <= '1' when (master_fsm_curr = wait_for_cmd) else '0';
 ready_for_cmd_out   <= ready_for_cmd;

-----------------------------------------------------------------------------
-- PROCESS: RX_FRAME_VALUE_PROC
-- PURPOSE: ChipScope State Indicator Signal
-----------------------------------------------------------------------------
  RX_FRAME_VALUE_PROC : process (rx_frame_curr) is
  begin
    case (rx_frame_curr) is
      when idle               => rx_frame_value <= x"0";
      when send_R_RDY         => rx_frame_value <= x"1";
      when send_R_IP          => rx_frame_value <= x"2";
      when send_HOLD_ACK      => rx_frame_value <= x"3";
      when send_R_OK          => rx_frame_value <= x"4";
      when send_SYNC          => rx_frame_value <= x"5";
      when wait_for_X_RDY     => rx_frame_value <= x"6";
      when dead               => rx_frame_value <= x"7";
      when others             => rx_frame_value <= x"8";
    end case;
  end process RX_FRAME_VALUE_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: RX_FRAME_STATE_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  RX_FRAME_STATE_PROC : process (sata_user_clk)
  begin
    if ((sata_user_clk'event) and (sata_user_clk = '1')) then
      if (sw_reset = '1') then
        --Initializing internal signals
        rx_frame_curr           <= idle;
        sync_count_rx           <= (others => '0');
        rx_done                 <= '0';
        rx_fifo_we              <= '0';
        prim_type_rx            <= (others => '0');
        ALIGN_det_r             <= '0';
        ALIGN_det_r2            <= '0';
        HOLD_det_r              <= '0';
        HOLD_det_r2             <= '0';
        HOLD_det_r3             <= '0';
        HOLD_det_r4             <= '0';
        TWO_HOLD_det_r          <= '0';
      else
        -- Register all Current Signals to their _next Signals
        rx_frame_curr           <= rx_frame_next;
        sync_count_rx           <= sync_count_rx_next;
        rx_done                 <= rx_done_next;
        rx_fifo_we              <= rx_fifo_we_next;
        prim_type_rx            <= prim_type_rx_next;
        ALIGN_det_r             <= ALIGN_det;
        ALIGN_det_r2            <= ALIGN_det_r;
        HOLD_det_r              <= HOLD_det;
        HOLD_det_r2             <= HOLD_det_r;
        HOLD_det_r3             <= HOLD_det_r2;
        HOLD_det_r4             <= HOLD_det_r3;
        TWO_HOLD_det_r          <= TWO_HOLD_det;
      end if;
    end if;
  end process RX_FRAME_STATE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: RX_FRAME_LOGIC_PROC
  -- PURPOSE: Receive FRAME from disk and unpack the FIS 
  -----------------------------------------------------------------------------
  RX_FRAME_LOGIC_PROC : process (rx_frame_curr, sync_count_rx, ALIGN_det, HOLD_det, 
                        HOLD_stop_after_ALIGN_det,
              		SOF_det, EOF_det, HOLD_start_det, HOLD_stop_det, SYNC_det,
                        start_rx, LINKUP, rx_datain, rx_sector_count, sector_count 
                                ) is
  begin
    -- Register _next to current signals
    rx_frame_next            <= rx_frame_curr;
    sync_count_rx_next       <= sync_count_rx;
    rx_done_next             <= rx_done;
    prim_type_rx_next        <= prim_type_rx;
    rx_fifo_we_next          <= '0';
    ---------------------------------------------------------------------------
    -- Finite State Machine
    ---------------------------------------------------------------------------
    case (rx_frame_curr) is
      
     -- x0
     when idle =>   
         rx_done_next <= '0';
         prim_type_rx_next <= SYNC;
         if (start_rx = '1') then
            --if (master_fsm_curr = capture_dev_sign) then
               rx_frame_next  <= send_R_RDY;
            --else
              -- rx_frame_next  <= wait_for_X_RDY;
            --end if;
         end if;

     -- x6
     --Wait for X_RDY before sending R_RDY 
     when wait_for_X_RDY =>
         prim_type_rx_next <= SYNC;
         if (X_RDY_det = '1') then
            rx_frame_next  <= send_R_RDY;
         end if; 
 
     -- x1
     when send_R_RDY => 
     --Send R_RDY to get device signature 
         prim_type_rx_next <= R_RDY;
                       
         if (SOF_det = '1') then
            rx_frame_next  <= send_R_IP;
         end if; 

     -- x2
     when send_R_IP =>
     --Send R_IP to indicate Reception in Progress
         prim_type_rx_next <= R_IP;
                       
	 rx_fifo_we_next   <= '1';

         if (ALIGN_det = '1' or HOLD_det = '1') then
	    rx_fifo_we_next   <= '0';
         end if; 

         if (EOF_det = '1') then
	    rx_fifo_we_next   <= '0';
            rx_frame_next  <= send_R_OK;
         end if; 

         -- Check for 2 HOLD primitives followed by CONT which indicates FIS pause
         if (HOLD_start_det = '1') then
	    rx_fifo_we_next   <= '0';
            rx_frame_next  <= send_HOLD_ACK;
         end if; 

     -- x3
     when send_HOLD_ACK => 
     -- Send HOLD ACK to Acknowledge FIS pause 
         prim_type_rx_next <= HOLD_ACK;
         if (HOLD_stop_after_ALIGN_det = '1') then     
	    rx_fifo_we_next   <= '1';
            rx_frame_next  <= send_R_IP;
         end if; 
         if (HOLD_stop_det = '1') then
            rx_frame_next  <= send_R_IP;
         end if; 

     -- x4
     when send_R_OK =>
         -- Send R_OK to indicate good frame
         prim_type_rx_next <= R_OK;
                       
         if (SYNC_det = '1') then
            if (master_fsm_curr = D2H_DATA_FIS) then
               if (rx_sector_count < conv_std_logic_vector(sector_count,16)) then 
                  rx_frame_next  <= send_R_RDY;
               else    
                  rx_done_next   <= '1';
                  rx_frame_next  <= idle;
               end if;
            else 
               rx_frame_next  <= send_SYNC;
            end if;
         end if; 

     -- x5 
     when send_SYNC =>
         -- Send SYNC to indicate host idle
         prim_type_rx_next <= SYNC;
                       
         if (sync_count_rx = SYNC_COUNT_VALUE) then
            rx_done_next    <= '1';
            sync_count_rx_next <= (others => '0');
            rx_frame_next   <=  idle;
         else
            sync_count_rx_next <= sync_count_rx + 1;
         end if;

     -- x6
     when dead =>
         rx_frame_next  <= dead;

     -- x7
     when others =>
         rx_frame_next  <= dead;

   end case;
 end process RX_FRAME_LOGIC_PROC;

-- Counter for number of received sectors (used when number of RX sectors exceeds max 16 in one data FIS)
  RX_SECTOR_CNT: process(sata_user_clk) is
  begin 
       if ((sata_user_clk'event) and (sata_user_clk = '1')) then
	  if (sw_reset = '1' or new_cmd = '1') then
	        dword_count <= (others => '0');
	        rx_sector_count <= (others => '0');
	  elsif ((dword_count < (SECTOR_NDWORDS-1)) and (master_fsm_curr = D2H_DATA_FIS) and (rx_fifo_we_next = '1')) then
		dword_count <= dword_count + 1;
          elsif (dword_count = (SECTOR_NDWORDS-1)) then
	        dword_count <= (others => '0');
		rx_sector_count <= rx_sector_count + 1;
          elsif (EOF_det = '1') then
	        dword_count <= (others => '0');
	  else
		dword_count <= dword_count;
		rx_sector_count <= rx_sector_count;
          end if; 
       end if;
  end process RX_SECTOR_CNT;


    -- DATA FIS DWORD Counter for stripping off DATA FIS header and CRC
    DATA_FIS_DWORD_CNT: process(sata_user_clk) is
     begin 
       if ((sata_user_clk'event) and (sata_user_clk = '1')) then
	  if (sw_reset = '1') then
             DATA_FIS_dword_count <= (others => '0');
             dword_count_init_value <= (others => '0'); 
          elsif ((master_fsm_curr = D2H_DATA_FIS) and (DATA_FIS_dword_count < dword_count_value)) then
             if (descrambler_dout_we = '1') then
                DATA_FIS_dword_count <= DATA_FIS_dword_count + 1;
             else
                DATA_FIS_dword_count <= DATA_FIS_dword_count;
             end if;
          elsif ((DATA_FIS_dword_count = dword_count_value) and (master_fsm_curr = D2H_DATA_FIS)) then
             if(dword_count_init_value >= NDWORDS_PER_DATA_FIS_32) then
               dword_count_init_value <= (dword_count_init_value - NDWORDS_PER_DATA_FIS_32);   
             end if;
             DATA_FIS_dword_count <= (others => '0');
          else
             DATA_FIS_dword_count <= (others => '0');
          end if;

          if(new_cmd = '1') then
             dword_count_init_value <= conv_std_logic_vector((SECTOR_NDWORDS * sector_count), 32); 
             dword_count_value <= (others => '0');
          elsif(dword_count_init_value < NDWORDS_PER_DATA_FIS_32) then
             dword_count_value <= dword_count_init_value(16 to 31) + conv_std_logic_vector(1,16);
          elsif(dword_count_init_value >= NDWORDS_PER_DATA_FIS_32) then
             dword_count_value <= NDWORDS_PER_DATA_FIS + 1;
          end if;
       end if;
    end process DATA_FIS_DWORD_CNT;

  -----------------------------------------------------------------------------
  -- PROCESS: TX_FRAME_VALUE_PROC
  -- PURPOSE: ChipScope State Indicator Signal
  -----------------------------------------------------------------------------
  TX_FRAME_VALUE_PROC : process (tx_frame_curr) is
  begin
    case (tx_frame_curr) is
      when idle              => tx_frame_value <= x"0";
      when send_X_RDY        => tx_frame_value <= x"1";
      when send_SOF          => tx_frame_value <= x"2";
      when send_FIS          => tx_frame_value <= x"3";
      when send_EOF          => tx_frame_value <= x"4";
      when send_WTRM         => tx_frame_value <= x"5";
      when send_SYNC         => tx_frame_value <= x"6";
      when send_HOLD_ACK     => tx_frame_value <= x"7";
      when send_HOLD         => tx_frame_value <= x"8";
      when dead              => tx_frame_value <= x"9";
      when others            => tx_frame_value <= x"A";
    end case;
  end process TX_FRAME_VALUE_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: TX_FRAME_STATE_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  TX_FRAME_STATE_PROC : process (sata_user_clk)
  begin
    if ((sata_user_clk'event) and (sata_user_clk = '1')) then
      if (sw_reset = '1') then
        --Initializing internal signals
        tx_frame_curr           <= idle;
        sync_count_tx           <= (others => '0');
        rx_tx_state_sel         <= '0'; 
        tx_done                 <= '0';
        tx_fifo_re              <= '0';
        frame_err               <= '0';
        tx_err                  <= '0';
        replay_buffer_clear     <= '0';
        prim_type_tx            <= (others => '0');
        FIS_word_count          <= (others => '0');
        tx_sector_count         <= (others => '0');
      elsif(new_cmd = '1') then
        tx_sector_count         <= (others => '0');
      else
        -- Register all Current Signals to their _next Signals
        tx_frame_curr           <= tx_frame_next;
        sync_count_tx           <= sync_count_tx_next;
        rx_tx_state_sel         <= rx_tx_state_sel_next; 
        tx_done                 <= tx_done_next;
        tx_fifo_re              <= tx_fifo_re_next;
        frame_err               <= frame_err_next;
        tx_err                  <= tx_err_next;
        replay_buffer_clear     <= replay_buffer_clear_next;
        prim_type_tx            <= prim_type_tx_next;
        FIS_word_count          <= FIS_word_count_next;
        tx_sector_count         <= tx_sector_count_next;
      end if;
    end if;
  end process TX_FRAME_STATE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: TX_FRAME_LOGIC_PROC
  -- PURPOSE: Next State and Output Logic
  -----------------------------------------------------------------------------
  TX_FRAME_LOGIC_PROC : process (tx_frame_curr, FIS_word_count, sector_count, 
                            tx_sector_count,  
			    R_RDY_det, R_OK_det, sync_count_tx, start_tx, 
                            LINKUP, frame_err  
                                ) is
  begin
    -- Register _next to current signals
    tx_frame_next            <= tx_frame_curr;
    sync_count_tx_next       <= sync_count_tx;
    rx_tx_state_sel_next     <= rx_tx_state_sel; 
    tx_fifo_re_next          <= tx_fifo_re;
    tx_done_next             <= tx_done;
    frame_err_next           <= frame_err;
    tx_err_next              <= tx_err;
    replay_buffer_clear_next <= replay_buffer_clear;
    prim_type_tx_next        <= prim_type_tx;
    FIS_word_count_next      <= FIS_word_count;
    tx_sector_count_next     <= tx_sector_count;
    tx_charisk_TX_FRAME      <= '1'; 
    ---------------------------------------------------------------------------
    -- Finite State Machine
    ---------------------------------------------------------------------------
    case (tx_frame_curr) is
      
     -- x0
     when idle =>   
        tx_done_next              <= '0';
        tx_err_next               <= '0';
        replay_buffer_clear_next  <= '0';
        prim_type_tx_next         <= SYNC;
        FIS_word_count_next       <= (others => '0');

        if (start_tx = '1') then
           rx_tx_state_sel_next    <= '1'; 
           tx_frame_next           <= send_X_RDY;
        end if;
 
     -- x1
     when send_X_RDY => 
         -- Send X_RDY to indicate host ready to transmit
        prim_type_tx_next <= X_RDY;
        if (R_RDY_det = '1') then
            tx_frame_next  <= send_SOF;
        end if; 

     -- x2
     when send_SOF => 
     --Send SOF to indicate start of new FRAME
         prim_type_tx_next <= SOF;
         if (align_en_out = '0') then
            tx_frame_next  <= send_FIS;
         end if; 

     -- x3
     when send_FIS => 
         tx_charisk_TX_FRAME      <= '0'; 
     --Send FIS data
         prim_type_tx_next <= FIS;
         -- ALIGN primitives after 256 DWORDS
         if (align_en_out = '1' or tx_fifo_almost_empty = '1') then
           FIS_word_count_next  <= FIS_word_count;
           tx_fifo_re_next   <= '0';
         else
           FIS_word_count_next  <= FIS_word_count + '1';
           tx_fifo_re_next   <= '1';
         end if;
         -- Receive buffer empty condition
         if (HOLD_start_det = '1') then
            tx_frame_next  <= send_HOLD_ACK;
         end if;
         -- Transmit buffer empty condition
         if (tx_fifo_almost_empty = '1') then
            if (align_en_out = '0') then
               tx_charisk_TX_FRAME  <= '1'; 
               prim_type_tx_next <= HOLD;
               tx_frame_next  <= send_HOLD;
            end if;
         end if;
         -- Transmitted sector count
         if(((conv_integer(FIS_word_count) mod SECTOR_NDWORDS)=0) and (conv_integer(FIS_word_count)>0) and (align_en_out='0') and (tx_fifo_almost_empty='0')) then
            tx_sector_count_next <= tx_sector_count + 1;
         else
            tx_sector_count_next <= tx_sector_count;
         end if; 
         if ((tx_sector_count >= conv_std_logic_vector(sector_count, 16)) or (FIS_word_count >= FIS_count_value)) then
            if (align_en_out = '0') then
               tx_charisk_TX_FRAME      <= '0'; 
	       FIS_word_count_next <= (others => '0');
               tx_fifo_re_next   <= '1';
               prim_type_tx_next <= FIS;
               tx_frame_next  <= send_EOF;
            end if;
         end if; 

     -- x7
     when send_HOLD_ACK => 
     -- Send HOLD ACK to Acknowledge FIS pause 
         prim_type_tx_next <= HOLD_ACK;
         tx_fifo_re_next <= '0';
         --if (HOLD_stop_det = '1') then
         if (R_IP_det = '1') then
            tx_frame_next  <= send_FIS;
         end if; 

     -- x8
     when send_HOLD => 
     -- Send HOLD to indicate transmit buffer empty 
         prim_type_tx_next <= HOLD;
         tx_fifo_re_next <= '0';
         if (tx_fifo_empty = '0') then
            tx_frame_next  <= send_FIS;
         end if;

     -- x4
     when send_EOF => 
     --Send EOF to indicate end of FRAME
         tx_fifo_re_next <= '0';
         prim_type_tx_next <= EOF;
         if (align_en_out = '0') then
            tx_frame_next  <= send_WTRM;
         end if; 

     -- x5
     when send_WTRM => 
         -- Send WTRM to indicate Waiting for Frame Termination
         prim_type_tx_next <= WTRM;
                       
         if (R_OK_det = '1' or R_ERR_det = '1' or SYNC_det = '1') then
            if (R_ERR_det = '1' or SYNC_det = '1') then
                if (master_fsm_curr = H2D_REG_FIS) then
                   frame_err_next <= '1';
                else
                   frame_err_next <= '0';
                end if;
            end if;
            if (R_OK_det = '1') then
                replay_buffer_clear_next <= '1';
                frame_err_next <= '0';
            end if;
            tx_frame_next  <= send_SYNC;
         end if; 

     -- x6 
     when send_SYNC =>
         -- Send SYNC to indicate host idle
         prim_type_tx_next <= SYNC;
         
         if (sync_count_tx = SYNC_COUNT_VALUE) then
            sync_count_tx_next <= (others => '0');
            if (frame_err = '1') then
               tx_err_next   <= '1';
            else 
               tx_done_next  <= '1';
            end if;
            rx_tx_state_sel_next  <= '0';
            tx_frame_next   <=  idle;
         else
            sync_count_tx_next <= sync_count_tx + 1;
         end if;

     -- x8 
     when dead =>
         tx_frame_next  <= dead;

     -- x9 
     when others =>
         tx_frame_next  <= dead;

   end case;
 end process TX_FRAME_LOGIC_PROC;

-- ASYNCHRONOUS MUXES
 tx_charisk_RX_FRAME <= '1';
 --tx_charisk_TX_FRAME <= '0' when (((tx_frame_curr = send_FIS) and (tx_fifo_almost_empty = '0')) or ((tx_frame_curr=send_FIS) and 
	--		(tx_fifo_almost_empty = '1') and (master_fsm_curr = H2D_REG_FIS))) else '1';
 --tx_charisk_out      <= '0' when ((tx_frame_curr = send_FIS) or (prim_type_tx = PRIM_SCRM)) else tx_charisk_RX_FRAME when (rx_tx_state_sel = '0') else tx_charisk_TX_FRAME; 
 tx_charisk_out      <= tx_charisk_RX_FRAME when (rx_tx_state_sel = '0') else tx_charisk_TX_FRAME; 
 prim_type           <= prim_type_rx when (rx_tx_state_sel = '0') else prim_type_tx;
-- ASYNCHRONOUS MUXES

-- Primitive detection
ALIGN_det      <= '1' when (rx_datain = x"7B4A4ABC") else '0'; 
SYNC_det       <= '1' when (rx_datain = x"B5B5957C") else '0';
R_RDY_det      <= '1' when (rx_datain = x"4A4A957C") else '0';
R_IP_det       <= '1' when (rx_datain = x"5555B57C") else '0';
R_OK_det       <= '1' when (rx_datain = x"3535B57C") else '0';
R_ERR_det      <= '1' when (rx_datain = x"5656B57C") else '0';
SOF_det        <= '1' when (rx_datain = x"3737B57C") else '0';
EOF_det        <= '1' when (rx_datain = x"D5D5B57C") else '0';
X_RDY_det      <= '1' when (rx_datain = x"5757B57C") else '0';
WTRM_det       <= '1' when (rx_datain = x"5858B57C") else '0';
CONT_det       <= '1' when (rx_datain = x"9999AA7C") else '0';
HOLD_det       <= '1' when (rx_datain = x"D5D5AA7C") else '0';
HOLD_start_det <= '1' when (((TWO_HOLD_det_r = '1') and (CONT_det = '1'))  or (CORNER_CASE_HOLD = '1')) else '0';
TWO_HOLD_det   <= '1' when ((rx_datain = x"D5D5AA7C") and (HOLD_det_r = '1')) else '0';
HOLD_stop_det  <= '1' when ((rx_datain = x"D5D5AA7C") and (ALIGN_det_r = '0') and (TWO_HOLD_det = '0')) else '0';
HOLD_stop_after_ALIGN_det  <= '1' when ((HOLD_det_r = '1') and (ALIGN_det_r2 = '1') and (ALIGN_det_r = '0') and (TWO_HOLD_det = '0')) or ((TWO_HOLD_det_r = '1') and (CONT_det = '0'))  else '0';
-- Corner Case
-- ALIGN primitives are received between two HOLD primitives or between 2 HOLD and a CONT primitive 
CORNER_CASE_HOLD <= '1' when ((CONT_det = '1') and (HOLD_det_r4 = '1')) else '0';


-- SATA Primitives 
-- SYNC
tx_sync  <= x"B5B5957C";

 -- R_RDY
tx_r_rdy <= x"4A4A957C";

-- R_OK
tx_r_ok  <= x"3535B57C";

-- R_ERR
tx_r_err <= x"5656B57C";

-- R_IP
tx_r_ip  <= x"5555B57C";

-- X_RDY 
tx_x_rdy <= x"5757B57C";

-- CONT 
tx_cont  <= x"9999AA7C";

-- WTRM 
tx_wtrm  <= x"5858B57C";

-- SOF 
tx_sof   <= x"3737B57C";

-- EOF 
tx_eof   <= x"D5D5B57C";

-- HOLD 
tx_hold  <= x"D5D5AA7C";

-- HOLD_ACK 
tx_hold_ack  <= x"9595AA7C";

-- Output Mux
OUTPUT_MUX_i: entity work.mux_161 
generic map 
    (
      DATA_WIDTH => 32
    )
port map 
  (
    a  => tx_sync,
    b  => tx_r_rdy,
    c  => tx_r_ip,
    d  => tx_r_ok,
    e  => tx_r_err,
    f  => tx_x_rdy,
    g  => tx_wtrm,
    h  => tx_hold,
    i  => tx_hold_ack,
    j  => tx_cont,
    k  => tx_sof,
    l  => tx_eof,
    m  => tx_fifo_dout,
    --n  => tx_prim_scrm,
    n  => (others => '0'),
    o  => (others => '0'),
    p  => (others => '0'),
    sel=> output_mux_sel,
    output=> tx_dataout
  );

  output_mux_sel <= prim_type; 

-------------------------------------------------------------------------------
-- LINK LAYER
-------------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Pre-DeScramble RX FIFO from PHY Layer
---------------------------------------------------------------------------
    rx_fifo_din <= rx_datain;
    rx_fifo_re  <= descrambler_din_re_r; 
    rx_fifo_reset <= sw_reset or descrambler_reset;     
     
    RX_FIFO : rx_tx_fifo
	port map (
           clk    => sata_user_clk,
           rst    => rx_fifo_reset,
           rd_en  => rx_fifo_re,
	   din    => rx_fifo_din,
	   wr_en  => rx_fifo_we_next,
	   dout   => rx_fifo_dout,
	   almost_empty  => rx_fifo_almost_empty,
	   empty  => rx_fifo_empty,
	   full   => rx_fifo_full,
	   prog_full   => rx_fifo_prog_full,
           data_count => rx_fifo_data_count
	);

---------------------------------------------------------------------------
-- DESCRAMBLER 
---------------------------------------------------------------------------
    --descrambler_din(0 to 15)  <= rx_fifo_dout(16 to 31);
    --descrambler_din(16 to 31) <= rx_fifo_dout(0 to 15);
    descrambler_din     <= rx_fifo_dout;
    descrambler_en      <= not(rx_fifo_almost_empty);
    descrambler_reset   <= '1' when ((start_rx='1') or ((rx_frame_curr = send_R_OK) and (SYNC_det = '1'))) else '0';

    DESCRAMBLER_i: entity work.scrambler 
        generic map(
    	   CHIPSCOPE    => FALSE 
        )
  	port map(
        -- Clock and Reset Signals
    	   clk          => sata_user_clk,
           reset        => descrambler_reset,
    	-- ChipScope ILA / Trigger Signals
           scrambler_ila_control => descrambler_ila_control,
    	---------------------------------------
    	-- Signals from/to Sata Link Layer FIFOs
           prim_scrambler => '0',
           scrambler_en   => descrambler_en,
   	   din_re         => descrambler_din_re, 
    	   data_in        => descrambler_din,
    	   data_out       => descrambler_dout, 
    	   dout_we        => descrambler_dout_we 
       );

---------------------------------------------------------------------------
-- Post-DeScramble Read FIFO to Command Layer 
---------------------------------------------------------------------------
    read_fifo_din <= descrambler_dout;
    read_fifo_we  <= descrambler_dout_we when ((master_fsm_curr = D2H_DATA_FIS) and (DATA_FIS_dword_count > 0) and (DATA_FIS_dword_count < dword_count_value)) else '0';
     
    READ_FIFO_i : read_write_fifo
	port map (
           clk    => sata_user_clk,
           rst    => sw_reset,
           rd_en  => read_fifo_re,
	   din    => read_fifo_din,
	   wr_en  => read_fifo_we,
	   dout   => read_fifo_dout,
	   almost_empty  => read_fifo_almost_empty,
	   empty  => read_fifo_empty_i,
	   full   => read_fifo_full,
	   prog_full  => read_fifo_prog_full
	);
    -- Data Output to Command Layer
    sata_dout     <= read_fifo_dout;
    -- Input from Command Layer
    read_fifo_re  <= sata_dout_re;

    read_fifo_empty <= read_fifo_empty_i;
---------------------------------------------------------------------------
-- Pre-Scramble Write FIFO from Command Layer
---------------------------------------------------------------------------
    write_fifo_we   <= sata_din_we;
    write_fifo_din  <= sata_din;
    write_fifo_full <= write_fifo_prog_full;
    --write_fifo_re   <= scrambler_din_re_r when (scrambler_en = '1') else '0';
    write_fifo_re   <= scrambler_din_re_r when ((scrambler_en='1') and (scrambler_count_en_reg_fis='1')) or ((scrambler_count < scrambler_count_value) and (scrambler_count_en_data_fis = '1') and (write_fifo_empty = '0')) else '0';

    WRITE_FIFO_i : read_write_fifo
	port map (
           clk    => sata_user_clk,
           rst    => sw_reset,
	   din    => write_fifo_din,
	   wr_en  => write_fifo_we,
	   dout   => write_fifo_dout,
           rd_en  => write_fifo_re,
	   almost_empty  => write_fifo_almost_empty,
	   empty  => write_fifo_empty,
	   full   => write_fifo_full_i,
	   prog_full   => write_fifo_prog_full
	);

---------------------------------------------------------------------------
-- CRC 
---------------------------------------------------------------------------
    crc_reset   <=  scrambler_reset;
    crc_en      <=  scrambler_dout_we; 
    crc_din     <=  write_fifo_dout;

    CRC_i : entity work.crc
      generic map (
         CHIPSCOPE => FALSE
      )
      port map (
        clk        => sata_user_clk,
        reset      => crc_reset,
        --crc_ila_control => crc_ila_control,
        crc_en     => crc_en,
        data_in    => crc_din,
        data_out   => crc_dout
      );

---------------------------------------------------------------------------
-- SCRAMBLER 
---------------------------------------------------------------------------
    REGISTER_PROCESS : process(sata_user_clk) is
      begin
        if sata_user_clk'event and sata_user_clk = '1' then
          if sw_reset = '1' then
             scrambler_din_re_r     <= '0';
             descrambler_din_re_r   <= '0';
             crc_dout_r             <= (others => '0');
          else
             scrambler_din_re_r     <= scrambler_din_re;
             descrambler_din_re_r   <= descrambler_din_re;
             crc_dout_r             <= crc_dout;
          end if;
        end if;
      end process REGISTER_PROCESS;


    scrambler_count_en_reg_fis   <= '1' when (master_fsm_curr = H2D_REG_FIS) else '0';
    scrambler_count_en_data_fis  <= '1' when ((master_fsm_curr = H2D_DATA_FIS) or ((master_fsm_curr = D2H_DMA_ACT_FIS) and (tx_sector_count > 0)))  else '0';

    -- To disable scrambler after the REG FIS
    SCRAMBLER_CNT: process(sata_user_clk) is
     begin 
       if ((sata_user_clk'event) and (sata_user_clk = '1')) then
	  if (sw_reset = '1') then
	      scrambler_count <= (others => '0');
              scrambler_count_init_value <= (others => '0'); 
              scrambler_count_value <= (others => '0');
              scrambler_reset_after_FIS <= '0';
	  elsif ((scrambler_count < (REG_FIS_NDWORDS)) and (scrambler_count_en_reg_fis = '1')) then
	      scrambler_count <= scrambler_count + 1;
	  elsif ((scrambler_count < scrambler_count_value) and (scrambler_count_en_data_fis = '1') and (tx_fifo_we = '1') and (write_fifo_empty = '0')) then
              scrambler_count <= scrambler_count + 1;
	      if (scrambler_count = NDWORDS_PER_DATA_FIS) then
                 scrambler_reset_after_FIS <= '1'; 
              end if;
	  elsif (( scrambler_count = (NDWORDS_PER_DATA_FIS+1)) and (scrambler_count_en_data_fis = '1')) then
              scrambler_count_init_value <= (scrambler_count_init_value - NDWORDS_PER_DATA_FIS_32);   
	      scrambler_count <= (others => '0');
              scrambler_reset_after_FIS <= '0'; 
     	  else
	      scrambler_count <= scrambler_count;
          end if;

          if (scrambler_reset = '1') then
	      scrambler_count <= (others => '0');
              scrambler_reset_after_FIS <= '0'; 
          end if;

          if(new_cmd = '1') then
             scrambler_count_init_value <= conv_std_logic_vector((SECTOR_NDWORDS * sector_count), 32); 
             scrambler_count_value <= (others => '0');
          elsif(scrambler_count_init_value < NDWORDS_PER_DATA_FIS_32) then
             scrambler_count_value <= scrambler_count_init_value(16 to 31) + conv_std_logic_vector(1,16);
          elsif(scrambler_count_init_value >= NDWORDS_PER_DATA_FIS_32) then
             scrambler_count_value <= NDWORDS_PER_DATA_FIS + 1;
          end if;
       end if;
    end process SCRAMBLER_CNT;


    scrambler_reset <= (sw_reset or new_cmd or scrambler_reset_after_FIS or (tx_done and scrambler_count_en_reg_fis)) ;
    scrambler_din   <=  crc_dout_r when ((scrambler_count = REG_FIS_NDWORDS) and (scrambler_count_en_reg_fis = '1')) or ((scrambler_count = scrambler_count_value) and (scrambler_count_en_data_fis = '1')) else write_fifo_dout;
    scrambler_en    <= not(write_fifo_empty) when (((scrambler_count_en_reg_fis = '1') and (scrambler_count < REG_FIS_NDWORDS)) 
--or ((scrambler_count_en_data_fis = '1') and (scrambler_count = NDWORDS_PER_DATA_FIS) and (tx_fifo_prog_full = '1'))
or ((scrambler_count_en_data_fis = '1') and (scrambler_count = (scrambler_count_value - '1'))))
else not(write_fifo_almost_empty) when ((scrambler_count_en_data_fis = '1') and (scrambler_count < scrambler_count_value) and (tx_fifo_prog_full = '0')) 
else '0'; 
   -- Corner Case: tx_fifo_almost_full goes high when (scrambler_count = NDWORDS_PER_DATA_FIS)  
 
    SCRAMBLER_i: entity work.scrambler 
        generic map(
    	   CHIPSCOPE    => FALSE 
        )
  	port map(
        -- Clock and Reset Signals
    	   clk          => sata_user_clk,
           reset        => scrambler_reset,
    	-- ChipScope ILA / Trigger Signals
           scrambler_ila_control => scrambler_ila_control,
    	---------------------------------------
    	-- Signals from/to Sata Link Layer FIFOs
           prim_scrambler => '0',
           scrambler_en   => scrambler_en,
   	   din_re         => scrambler_din_re, 
    	   data_in        => scrambler_din,
    	   data_out       => scrambler_dout, 
    	   dout_we        => scrambler_dout_we 
       );

   ---------------------------------------------------------------------------
   -- Post-Scramble TX FIFO to PHY Layer 
   ---------------------------------------------------------------------------
    -- Input Signals from User Logic
    tx_fifo_din            <= scrambler_dout;
    tx_fifo_we             <= scrambler_dout_we; 
        
    TX_FIFO: rx_tx_fifo
	port map (
	   clk    => sata_user_clk,
	   rst    => sw_reset,
	   rd_en  => tx_fifo_re,
	   din    => tx_fifo_din,
	   wr_en  => tx_fifo_we,
	   dout   => tx_fifo_dout,
           almost_empty  => tx_fifo_almost_empty,
           empty  => tx_fifo_empty,
	   full   => tx_fifo_full,
	   prog_full  => tx_fifo_prog_full,
           data_count => tx_fifo_data_count
	);

  ---------------------------------------------------------------------------
  --  Sata Phy Instantiation   
  ---------------------------------------------------------------------------
    SATA_PHY_i : sata_phy 
     port map (
        oob_control_ila_control=>  oob_control_ila_control,
        sata_phy_ila_control   =>  sata_phy_ila_control,
	REFCLK_PAD_P_IN        =>  REFCLK_PAD_P_IN  ,  
	REFCLK_PAD_N_IN        =>  REFCLK_PAD_N_IN  ,  
	GTXRESET_IN            =>  GTX_RESET_IN         , 
	PLLLKDET_OUT_N         =>  PLLLKDET_OUT_N , 
	TXP0_OUT               =>  TXP0_OUT,
	TXN0_OUT               =>  TXN0_OUT,
	RXP0_IN                =>  RXP0_IN ,
	RXN0_IN                =>  RXN0_IN ,		
	DCMLOCKED_OUT          =>  DCMLOCKED_OUT,
	LINKUP                 =>  LINKUP   ,
	LINKUP_led             =>  LINKUP_led ,
        sata_user_clk          =>  sata_user_clk ,    
 	GEN2_led	       =>  GEN2_led_i ,	 
 	align_en_out	       =>  align_en_out,	 
        tx_datain	       =>  tx_dataout,
        tx_charisk_in	       =>  tx_charisk_out,
	rx_dataout	       =>  rx_datain,
	rx_charisk_out	       =>  rx_charisk_in,
        CurrentState_out       =>  OOB_state,
        rxelecidle_out         =>  rxelecidle,      
        CLKIN_150              =>  CLKIN_150 
     );
     
     sata_user_clk_out         <= sata_user_clk;
      
 -----------------------------------------------------------------------------
 -- ILA Instantiations
 -----------------------------------------------------------------------------
 chipscope_gen_ila : if (CHIPSCOPE) generate
   SATA_RX_FRAME_ILA_i : sata_rx_frame_ila
    port map (
      control  => sata_rx_frame_ila_control,
      clk      => sata_user_clk,
      trig0    => rx_frame_value,
      trig1    => tx_dataout,
      trig2    => sync_count_rx,
      trig3    => master_fsm_value,
      trig4    => rx_charisk_in,
      trig5    => OOB_state,
      trig6    => rx_datain,
      trig7    => rx_fifo_dout,
      trig8    => read_fifo_din,
      trig9    => read_fifo_dout,
      trig10(0) => SOF_det,
      trig10(1) => EOF_det,
      trig10(2) => X_RDY_det,	  
      trig10(3) => WTRM_det, 
      trig10(4) => HOLD_start_det, 
      trig10(5) => HOLD_stop_det,
      trig10(6) => SYNC_det,
      trig10(7) => CONT_det,
      trig10(8) => ALIGN_det,
      trig10(9) => new_cmd,
      trig10(10) => start_rx,
      trig10(11) => rx_done,
      trig10(12) => descrambler_dout_we,
      trig10(13) => tx_charisk_out,
      trig10(14) => sw_reset, 
      trig10(15) => LINKUP, 
      trig10(16) => rx_fifo_we_next, 
      trig10(17) => rx_fifo_re, 
      trig10(18) => rx_fifo_empty, 
      trig10(19) => descrambler_reset, 
      trig10(20) => descrambler_en, 
      trig10(21) => read_fifo_we, 
      trig10(22) => read_fifo_re, 
      trig10(23) => rx_fifo_almost_empty, 
      trig10(24) => HOLD_det_r, 
      trig10(25) => ALIGN_det_r, 
      trig10(26) => TWO_HOLD_det, 
      trig10(27) => read_fifo_empty_i, 
      trig10(28) => TWO_HOLD_det_r, 
      trig10(29) => HOLD_det, 
      trig10(30) => HOLD_stop_after_ALIGN_det, 
      trig10(31) => ALIGN_det_r2,
      trig11     => dword_count,
      trig12     => rx_sector_count,
      trig13     => DATA_FIS_dword_count,
      trig14     => dword_count_value,
      trig15     => dword_count_init_value
         );


   SATA_TX_FRAME_ILA_i : sata_tx_frame_ila
    port map (
      control  => sata_tx_frame_ila_control,
      clk      => sata_user_clk,
      trig0    => tx_frame_value,
      trig1    => tx_dataout,
      trig2    => rx_datain,
      trig3    => tx_fifo_dout,
      trig4    => master_fsm_value,
      trig5    => tx_fifo_din,
      trig6    => write_fifo_din,
      trig7    => write_fifo_dout,
      trig8    => FIS_word_count,
      trig9    => scrambler_count,
      trig10(0) => tx_fifo_we,
      trig10(1) => tx_fifo_re,
      trig10(2) => tx_fifo_full,
      trig10(3) => align_en_out,
      trig10(4) => SYNC_det, 
      trig10(5) => R_RDY_det, 
      trig10(6) => R_IP_det, 
      trig10(7) => R_OK_det,
      trig10(8) => R_ERR_det,
      trig10(9) => start_tx,
      trig10(10) => tx_done,
      trig10(11) => tx_fifo_almost_empty,
      trig10(12) => tx_charisk_out,
      trig10(13) => tx_fifo_empty,
      trig10(14) => scrambler_din_re,
      trig10(15) => ALIGN_det, 
      trig10(16) => HOLD_start_det, 
      trig10(17) => HOLD_stop_det, 
      trig10(18) => CONT_det, 
      trig10(19) => write_fifo_prog_full, 
      trig10(20) => tx_err,
      trig10(21) => write_fifo_almost_empty,
      trig10(22) => new_cmd,
      trig10(23) => scrambler_reset_after_FIS,
      trig10(24) => write_fifo_we,
      trig10(25) => write_fifo_re,
      trig10(26) => write_fifo_empty,
      trig10(27) => scrambler_en,
      trig10(28) => tx_fifo_prog_full,
      trig10(29) => scrambler_count_en_data_fis,
      trig10(30) => scrambler_reset,
      trig10(31) => crc_en,
      trig11     => scrambler_din,
      trig12     => crc_dout,
      trig13     => tx_sector_count,
      trig14     => scrambler_count_value,
      trig15     => tx_fifo_data_count
        );

      --trig14     => scrambler_count_init_value,
   end generate chipscope_gen_ila; 

end BEHAV;
