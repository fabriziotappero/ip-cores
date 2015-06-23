
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- ENTITY:   NPI_CORE
-- PURPOSE:  Interface SATA Core with MPMC via NPI
--
-- GENERICS:
--           CHIPSCOPE           - True if Core should include ILA
--           RAM_OFFSET          - Start address for connected RAMDisk
--           BLOCK_SIZE          - Block Size in Bytes
--           BLOCK_SIZE_WIDTH    - 2^(BLOCK_SIZE_WIDTH) = BLOCK_SIZE/8
--
-- PORTS:
--           NPI_*               - Native Port Interface Signals to MPMC
--
-------------------------------------------------------------------------------

entity npi_core is
  generic (
    -- Generics
    CHIPSCOPE             : boolean                  := false;
    END_SWAP              : boolean                  := true;
    RAM_OFFSET            : std_logic_vector(0 to 7) := x"04";
    BLOCK_SIZE            : integer                  := 512
  );
  port (
    -- ChipScope ILA Control
    npi_if_ila_control    : in  std_logic_vector(35 downto 0);
    npi_if_tx_ila_control : in  std_logic_vector(35 downto 0);
    npi_ila_control       : in  std_logic_vector(35 downto 0);    
    -- Clock Sources
    MPMC_Clk              : in  std_logic;
    user_clk              : in  std_logic;
    -- Reset Source
    reset                 : in  std_logic;
    -- SATA Core Signals
    NPI_CORE_DIN          : in  std_logic_vector(31 downto 0);
    NPI_CORE_WE           : in  std_logic;
    NPI_CORE_FULL         : out std_logic;
    NPI_CORE_DOUT         : out std_logic_vector(31 downto 0);
    NPI_CORE_DOUT_WE      : out std_logic;
    SATA_CORE_FULL        : in  std_logic;
    req_type              : in  std_logic_vector(1 downto 0);
    new_cmd               : in  std_logic;
    num_read_bytes_in     : in  std_logic_vector(31 downto 0);     
    num_write_bytes_in    : in  std_logic_vector(31 downto 0);       
    NPI_init_wr_addr_in   : in  std_logic_vector(31 downto 0);  
    NPI_init_rd_addr_in   : in  std_logic_vector(31 downto 0);  
    NPI_ready_for_cmd     : out std_logic;     
    -- NPI Signals 
    NPI_AddrAck           : in  std_logic;
    NPI_WrFIFO_AlmostFull : in  std_logic;
    NPI_RdFIFO_Empty      : in  std_logic;
    NPI_InitDone          : in  std_logic;
    NPI_WrFIFO_Empty      : in  std_logic;
    NPI_RdFIFO_Latency    : in  std_logic_vector(1 downto 0);
    NPI_RdFIFO_RdWdAddr   : in  std_logic_vector(3 downto 0);    
    NPI_RdFIFO_Data       : in  std_logic_vector(63 downto 0);
    NPI_AddrReq           : out std_logic;
    NPI_RNW               : out std_logic;
    NPI_WrFIFO_Push       : out std_logic;
    NPI_RdFIFO_Pop        : out std_logic;
    NPI_RdModWr           : out std_logic; 
    NPI_WrFIFO_Flush      : out std_logic;    
    NPI_RdFIFO_Flush      : out std_logic;
    NPI_Size              : out std_logic_vector(3 downto 0);
    NPI_WrFIFO_BE         : out std_logic_vector(7 downto 0);    
    NPI_Addr              : out std_logic_vector(31 downto 0);
    NPI_WrFIFO_Data       : out std_logic_vector(63 downto 0)    
  );
end entity npi_core;

------------------------------------------------------------------------------
-- ARCHITECTURE
------------------------------------------------------------------------------
architecture BEH of npi_core is
  
  -----------------------------------------------------------------------------
  -- NPI Signals
  -----------------------------------------------------------------------------
  signal core_rfd               : std_logic;
  signal data_to_mem            : std_logic_vector(0 to 63);
  signal data_to_mem_we         : std_logic;
  signal data_to_mem_re         : std_logic;
  signal data_to_core           : std_logic_vector(0 to 63);        
  signal data_to_core_we        : std_logic;      
  signal num_rd_bytes           : std_logic_vector(0 to 31);
  signal num_wr_bytes           : std_logic_vector(0 to 31);
  signal init_rd_addr           : std_logic_vector(0 to 31);
  signal init_wr_addr           : std_logic_vector(0 to 31);
  signal rd_req_start           : std_logic;
  signal rd_req_start_next      : std_logic; 
  signal wr_req_start           : std_logic;
  signal wr_req_start_next      : std_logic;  
  signal rd_req_done            : std_logic;
  signal wr_req_done            : std_logic;    

  -- AGS: Added on 8/19
  -- Request Type: RnW Signal (1 = Read Request / 0 = Write Request)
  signal req_type_r              : std_logic_vector(1 downto 0);
  signal new_cmd_r, new_cmd_r2   : std_logic;
  signal new_cmd_started         : std_logic; 
  signal  NPI_CORE_DOUT_next     : std_logic_vector(31 downto 0);
  signal  NPI_CORE_DOUT_out      : std_logic_vector(31 downto 0);
  signal  NPI_CORE_DOUT_WE_next  : std_logic ;
  signal  NPI_CORE_DOUT_WE_out   : std_logic ;

  signal  NPI_ready_for_cmd_out, NPI_ready_for_cmd_next : std_logic;
  -----------------------------------------------------------------------------
  -- TX FIFO Signals
  -----------------------------------------------------------------------------
  signal tx_fifo_din            : std_logic_vector(0 to 63);
  signal tx_fifo_re             : std_logic;
  signal tx_fifo_we             : std_logic;
  signal tx_fifo_dout           : std_logic_vector(0 to 31);
  signal tx_fifo_empty          : std_logic;
  signal tx_fifo_full           : std_logic;
  signal tx_fifo_prog_full      : std_logic;
  signal tx_fifo_valid          : std_logic;

  -----------------------------------------------------------------------------
  -- RX FIFO Signals
  -----------------------------------------------------------------------------
  signal rx_fifo_din            : std_logic_vector(0 to 31);
  signal rx_fifo_re             : std_logic;
  signal rx_fifo_we             : std_logic;
  signal rx_fifo_dout           : std_logic_vector(0 to 63);
  signal rx_fifo_empty          : std_logic;
  signal rx_fifo_full           : std_logic;
  signal rx_fifo_prog_full      : std_logic;
  signal rx_fifo_prog_full_next : std_logic;
  signal rx_fifo_valid          : std_logic;  
  
  -----------------------------------------------------------------------------
  -- RX FSM Signals (From Router / Aurora Core to NPI Component)
  -----------------------------------------------------------------------------
  type LL_RX_FSM_TYPE is (idle, check_req_type, issue_wr_req, issue_rd_req, done);
  signal ll_rx_fsm_cs, ll_rx_fsm_ns : LL_RX_FSM_TYPE := idle;
  signal ll_rx_fsm_value, ll_rx_fsm_value_r  : std_logic_vector(0 to 3);

  -----------------------------------------------------------------------------
  -- TX FSM Signals (To Router / Aurora Core)
  -----------------------------------------------------------------------------
  type LL_TX_FSM_TYPE is (idle, xfer_data, done, dead);
  signal ll_tx_fsm_cs, ll_tx_fsm_ns : LL_TX_FSM_TYPE := idle;
  signal ll_tx_fsm_value, ll_tx_fsm_value_r   : std_logic_vector(0 to 3);

  -----------------------------------------------------------------------------
  -- RX FIFO Declaration
  -----------------------------------------------------------------------------  
  component rx_fifo
    port (
      din       : in std_logic_vector(31 downto 0);
      rd_clk    : in std_logic;
      rd_en     : in std_logic;
      rst       : in std_logic;
      wr_clk    : in std_logic;
      wr_en     : in std_logic;
      dout      : out std_logic_vector(63 downto 0);
      empty     : out std_logic;
      full      : out std_logic;
      prog_full : out std_logic;
      valid     : out std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- TX FIFO Declaration
  -----------------------------------------------------------------------------
  component tx_fifo
    port (
      din       : in std_logic_vector(63 downto 0);
      rd_clk    : in std_logic;
      rd_en     : in std_logic;
      rst       : in std_logic;
      wr_clk    : in std_logic;
      wr_en     : in std_logic;
      dout      : out std_logic_vector(31 downto 0);
      empty     : out std_logic;
      full      : out std_logic;
      prog_full : out std_logic;
      valid     : out std_logic);
  end component;
 
  -----------------------------------------------------------------------------
  -- ILA Instance
  -----------------------------------------------------------------------------
  component npi_if_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(31 downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(3 downto 0);
      trig4   : in std_logic_vector(23 downto 0);
      trig5   : in std_logic_vector(63 downto 0);
      trig6   : in std_logic_vector(63 downto 0);
      trig7   : in std_logic_vector(31 downto 0));
  end component;

  component npi_if_tx_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(3 downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(7 downto 0));
  end component;
 
-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin
  
  -----------------------------------------------------------------------------
  -- NPI Output Signals
  -----------------------------------------------------------------------------
  core_rfd        <= not(tx_fifo_prog_full);
  data_to_mem     <= rx_fifo_dout when (ll_rx_fsm_cs = issue_wr_req) else (others => '0');
  data_to_mem_we  <= rx_fifo_valid when (ll_rx_fsm_cs = issue_wr_req) else '0';
  tx_fifo_re      <= not(tx_fifo_empty) when (SATA_CORE_FULL = '0') else '0';

  -----------------------------------------------------------------------------
  -- PROCESS: LL_RX_FSM_VALUE_PROC
  -- PURPOSE: RX FSM State Indicator for ChipScope
  -----------------------------------------------------------------------------
  LL_RX_FSM_VALUE_PROC : process (ll_rx_fsm_cs) is
  begin
    case (ll_rx_fsm_cs) is
      when idle              => ll_rx_fsm_value <= x"0";
      when check_req_type    => ll_rx_fsm_value <= x"1";
      when issue_wr_req      => ll_rx_fsm_value <= x"2";
      when issue_rd_req      => ll_rx_fsm_value <= x"3";
      when done              => ll_rx_fsm_value <= x"4";
      when others            => ll_rx_fsm_value <= x"5";
    end case;
  end process LL_RX_FSM_VALUE_PROC;
 
  -----------------------------------------------------------------------------
  -- PROCESS: LL_RX_FSM_STATE_PROC
  -- PURPOSE: Register RX FSM to MPMC Clock (200 MHz)
  -----------------------------------------------------------------------------
  LL_RX_FSM_STATE_PROC : process (MPMC_Clk) is
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk='1')) then
      if (reset='1') then
        wr_req_start      <= '0';
        rd_req_start      <= '0';
        ll_rx_fsm_cs      <= idle;
        rx_fifo_prog_full <= '0';
        ll_rx_fsm_value_r <= (others => '0'); 
        req_type_r        <= "00";
        new_cmd_r         <= '0';
        init_rd_addr      <= (others => '0');
        init_wr_addr      <= (others => '0'); 
        num_wr_bytes      <= (others => '0');
        num_rd_bytes      <= (others => '0');
        NPI_ready_for_cmd_out <= '0';
     else
        wr_req_start      <= wr_req_start_next;
        rd_req_start      <= rd_req_start_next;
        ll_rx_fsm_cs      <= ll_rx_fsm_ns;
        rx_fifo_prog_full <= rx_fifo_prog_full_next;
        ll_rx_fsm_value_r <= ll_rx_fsm_value;  
        req_type_r        <= req_type;
        new_cmd_r         <= new_cmd;
        init_rd_addr      <= NPI_init_rd_addr_in;
        init_wr_addr      <= NPI_init_wr_addr_in; 
        num_wr_bytes      <= num_write_bytes_in;
        num_rd_bytes      <= num_read_bytes_in;
        NPI_ready_for_cmd_out <= NPI_ready_for_cmd_next;
      end if;
    end if;
  end process LL_RX_FSM_STATE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: LL_RX_FSM_LOGIC_PROC
  -- PURPOSE: Next State and Output Function for RX FSM
  -----------------------------------------------------------------------------
  LL_RX_FSM_LOGIC_PROC : process (ll_rx_fsm_cs, 
                                  rd_req_start,
                                  rx_fifo_empty, rx_fifo_valid, rx_fifo_dout,
                                  rx_fifo_prog_full, data_to_mem_re, wr_req_done,
                                  req_type_r, new_cmd_r
                                  ) is
  begin
    wr_req_start_next        <= wr_req_start;
    rd_req_start_next        <= rd_req_start;
    ll_rx_fsm_ns             <= ll_rx_fsm_cs;
    NPI_ready_for_cmd_next   <= NPI_ready_for_cmd_out;

    case (ll_rx_fsm_cs) is
      -------------------------------------------------------------------------
      -- Idle State: 0 - Wait for data from AIREN which is in RX_FIFO
      -------------------------------------------------------------------------
      when idle =>
        wr_req_start_next    <= '0';        
        rd_req_start_next    <= '0';
        rx_fifo_re           <= '0';
        NPI_ready_for_cmd_next   <= '1';
        if (new_cmd_r2 = '1') then 
          ll_rx_fsm_ns       <= check_req_type;
        end if;

       when check_req_type =>
        if (req_type_r = "01") then
          ll_rx_fsm_ns       <= issue_rd_req;
          NPI_ready_for_cmd_next   <= '0';
        elsif ((req_type_r = "10") and (rx_fifo_prog_full = '1') and (rx_fifo_empty = '0')) then
          ll_rx_fsm_ns       <= issue_wr_req;
          NPI_ready_for_cmd_next   <= '0';
        else
          rx_fifo_re         <= '0';
          ll_rx_fsm_ns       <= check_req_type;
        end if;
          
      -------------------------------------------------------------------------
      -- Issue Write Request State: 4 - Issue NPI Write Request
      -------------------------------------------------------------------------
      when issue_wr_req =>
        rx_fifo_re           <= data_to_mem_re;
        if (wr_req_done = '1') then
          wr_req_start_next  <= '0';
          ll_rx_fsm_ns       <= done;
        else
          wr_req_start_next  <= '1';
          ll_rx_fsm_ns       <= issue_wr_req;
        end if;

      -------------------------------------------------------------------------
      -- Issue Read Request State: 5 - Issue NPI Read Request
      -------------------------------------------------------------------------
      when issue_rd_req =>
        rx_fifo_re           <= '0';
        tx_fifo_we           <= data_to_core_we;
        tx_fifo_din          <= data_to_core;
        if (rd_req_done = '1') then
          rd_req_start_next  <= '0';
          ll_rx_fsm_ns       <= done;
        else
          rd_req_start_next  <= '1';
          ll_rx_fsm_ns       <= issue_rd_req;
        end if;

      -------------------------------------------------------------------------
      -- Done State: 6 - Signal TX FSM To Transfer
      -------------------------------------------------------------------------
      when done =>
        rx_fifo_re           <= '0';
        NPI_ready_for_cmd_next   <= '1';
        ll_rx_fsm_ns         <= idle;
        
      when others =>
        rx_fifo_re           <= '0';
        ll_rx_fsm_ns         <= idle;
    end case;
  end process LL_RX_FSM_LOGIC_PROC;

  -- De-Assert new_cmd after 1 clk cycle
  NEW_CMD_PROC: process (MPMC_Clk)
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk = '1')) then
      if (reset = '1') then
         new_cmd_r2  <= '0';
         new_cmd_started  <= '0';
      elsif(new_cmd_r = '0') then
         new_cmd_started  <= '0';
      elsif (new_cmd_r = '1' and new_cmd_started  = '0') then
         new_cmd_r2  <= '1';
         new_cmd_started  <= '1';
      elsif (new_cmd_started  = '1') then
         new_cmd_r2  <= '0';
      end if;
    end if; 
  end process NEW_CMD_PROC;

  -----------------------------------------------------------------------------
  -- RX FIFO Instance
  -----------------------------------------------------------------------------
  rx_fifo_din <= NPI_CORE_DIN;
  rx_fifo_we  <= NPI_CORE_WE;
  NPI_CORE_FULL <= rx_fifo_full;

  rx_fifo_i : rx_fifo
    port map (
      din       => rx_fifo_din,
      rd_clk    => MPMC_Clk,
      rd_en     => rx_fifo_re,
      rst       => reset,
      wr_clk    => user_clk,
      wr_en     => rx_fifo_we,
      dout      => rx_fifo_dout,
      empty     => rx_fifo_empty,
      full      => rx_fifo_full,
      prog_full => rx_fifo_prog_full_next,
      valid     => rx_fifo_valid);


  -----------------------------------------------------------------------------
  -- PROCESS: LL_TX_FSM_VALUE_PROC
  -- PURPOSE: State Indicator for ChipScope
  -----------------------------------------------------------------------------
  LL_TX_FSM_VALUE_PROC : process (ll_tx_fsm_cs) is
  begin
    case (ll_tx_fsm_cs) is
      when idle      => ll_tx_fsm_value <= x"0";
      when xfer_data => ll_tx_fsm_value <= x"1";
      when done      => ll_tx_fsm_value <= x"2";
      when dead      => ll_tx_fsm_value <= x"3";                        
      when others    => ll_tx_fsm_value <= x"4";
    end case;
  end process LL_TX_FSM_VALUE_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: LL_TX_FSM_STATE_PROC
  -- PURPOSE: Register TX and RX FSMs to Router_Clk
  -----------------------------------------------------------------------------
  LL_TX_FSM_STATE_PROC : process (user_clk)
  begin
    if ((user_clk'event) and (user_clk = '1')) then
      if (reset = '1') then
        ll_tx_fsm_cs  <= idle;
        NPI_CORE_DOUT_out <= (others => '0');
        NPI_CORE_DOUT_WE_out <= '0';
        ll_tx_fsm_value_r <= (others => '0');  
      else
        ll_tx_fsm_cs  <= ll_tx_fsm_ns;
        NPI_CORE_DOUT_out <= NPI_CORE_DOUT_next;
        NPI_CORE_DOUT_WE_out <= NPI_CORE_DOUT_WE_next;
        ll_tx_fsm_value_r <= ll_tx_fsm_value;  
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- PROCESS: LL_TX_FSM_LOGIC_PROC
  -- PURPOSE: Next State and Output Function
  -----------------------------------------------------------------------------
  LL_TX_FSM_LOGIC_PROC : process (ll_tx_fsm_cs, ll_rx_fsm_cs,
                                  tx_fifo_empty, tx_fifo_dout,
                                  tx_fifo_valid) is
  begin
    ll_tx_fsm_ns         <= ll_tx_fsm_cs;
    NPI_CORE_DOUT_next   <= NPI_CORE_DOUT_out;
    NPI_CORE_DOUT_WE_next  <= NPI_CORE_DOUT_WE_out;

    case (ll_tx_fsm_cs) is
      -------------------------------------------------------------------------
      -- Idle State: 0 - Wait for valid data in TX FIFO
      -------------------------------------------------------------------------
      when idle =>
        NPI_CORE_DOUT_next    <= (others => '0');
        NPI_CORE_DOUT_WE_next <= '0';
        -- If it is a Write Request to RAMDisk (wait until Write is complete)
        if (tx_fifo_empty = '0') and (ll_rx_fsm_cs = issue_wr_req) then
          ll_tx_fsm_ns       <= idle;
        elsif (tx_fifo_empty = '0') then
          ll_tx_fsm_ns       <= xfer_data;
        end if;

      -------------------------------------------------------------------------
      -- Xfer Data State: 1 - Transfer Data to Sata Core
      -------------------------------------------------------------------------
      when xfer_data =>
        NPI_CORE_DOUT_next    <= tx_fifo_dout;
        if (SATA_CORE_FULL = '0') then
           NPI_CORE_DOUT_WE_next <= '1';
        else
           NPI_CORE_DOUT_WE_next <= '0';
        end if;
        if (tx_fifo_empty = '1') then
          --ll_tx_fsm_ns       <= xfer_data;
          ll_tx_fsm_ns       <= idle;
        end if;      

      -------------------------------------------------------------------------
      -- Dead State: 4 - Stay in Dead State if something goes horribly wrong
      -------------------------------------------------------------------------
      when dead =>
        NPI_CORE_DOUT_next    <= (others => '0');
        NPI_CORE_DOUT_WE_next <= '0';
        ll_tx_fsm_ns      <= dead;
        
      when others  =>
        NPI_CORE_DOUT_next    <= (others => '0');
        NPI_CORE_DOUT_WE_next <= '0';
        ll_tx_fsm_ns      <= dead;     

    end case;
  end process LL_TX_FSM_LOGIC_PROC;

  NPI_CORE_DOUT_WE <= NPI_CORE_DOUT_WE_out;
  NPI_CORE_DOUT    <= NPI_CORE_DOUT_out;
  NPI_ready_for_cmd <= NPI_ready_for_cmd_out;

  -----------------------------------------------------------------------------
  -- TX FIFO Instance
  -----------------------------------------------------------------------------
  tx_fifo_i : tx_fifo
    port map (
      din       => tx_fifo_din,
      rd_clk    => user_clk,
      rd_en     => tx_fifo_re,
      rst       => reset,
      wr_clk    => MPMC_Clk,
      wr_en     => tx_fifo_we,
      dout      => tx_fifo_dout,
      empty     => tx_fifo_empty,
      full      => tx_fifo_full,
      prog_full => tx_fifo_prog_full,
      valid     => tx_fifo_valid);


  -----------------------------------------------------------------------------
  -- NPI Instance
  -----------------------------------------------------------------------------
  npi_i : entity work.npi
    generic map(
      CHIPSCOPE             => CHIPSCOPE,
      END_SWAP              => END_SWAP
      )
    port map(
      npi_ila_control       => npi_ila_control      ,
      MPMC_Clk              => MPMC_Clk             ,
      NPI_Reset             => reset                ,
      core_rfd              => core_rfd             ,
      data_to_mem           => data_to_mem          ,
      data_to_mem_we        => data_to_mem_we       ,
      data_to_mem_re        => data_to_mem_re       ,
      data_to_core          => data_to_core         ,
      data_to_core_we       => data_to_core_we      ,
      num_rd_bytes          => num_rd_bytes         ,
      num_wr_bytes          => num_wr_bytes         ,
      init_rd_addr          => init_rd_addr         ,
      init_wr_addr          => init_wr_addr         ,
      rd_req_start          => rd_req_start         ,
      rd_req_done           => rd_req_done          ,
      wr_req_start          => wr_req_start         ,
      wr_req_done           => wr_req_done          ,
      NPI_AddrAck           => NPI_AddrAck          ,
      NPI_WrFIFO_AlmostFull => NPI_WrFIFO_AlmostFull,
      NPI_RdFIFO_Empty      => NPI_RdFIFO_Empty     ,
      NPI_InitDone          => NPI_InitDone         ,
      NPI_WrFIFO_Empty      => NPI_WrFIFO_Empty     ,
      NPI_RdFIFO_Latency    => NPI_RdFIFO_Latency   ,
      NPI_RdFIFO_RdWdAddr   => NPI_RdFIFO_RdWdAddr  ,
      NPI_RdFIFO_Data       => NPI_RdFIFO_Data      ,
      NPI_AddrReq           => NPI_AddrReq          ,
      NPI_RNW               => NPI_RNW              ,
      NPI_WrFIFO_Push       => NPI_WrFIFO_Push      ,
      NPI_RdFIFO_Pop        => NPI_RdFIFO_Pop       ,
      NPI_RdModWr           => NPI_RdModWr          ,
      NPI_WrFIFO_Flush      => NPI_WrFIFO_Flush     ,
      NPI_RdFIFO_Flush      => NPI_RdFIFO_Flush     ,
      NPI_Size              => NPI_Size             ,
      NPI_WrFIFO_BE         => NPI_WrFIFO_BE        ,
      NPI_Addr              => NPI_Addr             ,
      NPI_WrFIFO_Data       => NPI_WrFIFO_Data      
      );  
  
  -----------------------------------------------------------------------------
  -- RAMDISK ILA Instance
  -----------------------------------------------------------------------------
  CHIPSCOPE_ILA_GEN: if (CHIPSCOPE) generate    
    npi_if_ila_i : npi_if_ila
      port map (
        CONTROL     => npi_if_ila_control   ,
        CLK         => MPMC_Clk           ,
        trig0       => init_rd_addr       ,
        trig1       => init_wr_addr       ,
        trig2       => rx_fifo_din        ,
        trig3       => ll_rx_fsm_value_r  ,
        trig4(0)    => core_rfd           ,
        trig4(1)    => data_to_mem_we     ,
        trig4(2)    => data_to_mem_re     ,
        trig4(3)    => rd_req_start       ,
        trig4(4)    => wr_req_start       ,
        trig4(5)    => rd_req_done        ,
        trig4(6)    => wr_req_done        ,
        trig4(7)    => '0',
        trig4(8)    => tx_fifo_re         ,
        trig4(9)    => tx_fifo_we         ,
        trig4(10)   => tx_fifo_empty      ,
        trig4(11)   => tx_fifo_full       ,
        trig4(12)   => tx_fifo_prog_full  ,
        trig4(13)   => tx_fifo_valid      ,
        trig4(14)   => rx_fifo_re         ,
        trig4(15)   => rx_fifo_we         ,
        trig4(16)   => rx_fifo_empty      ,
        trig4(17)   => rx_fifo_full       ,
        trig4(18)   => rx_fifo_valid      ,
        trig4(19)   => rx_fifo_prog_full  ,   
        trig4(20)   => new_cmd_r,
        trig4(21)   => NPI_ready_for_cmd_out,
        trig4(22)   => new_cmd_r2 ,
        trig4(23)   => '0'                ,            
        trig5       => rx_fifo_dout,                
        trig6       => tx_fifo_din,                
        trig7       => num_rd_bytes
        );

    npi_if_tx_ila_i : npi_if_tx_ila
      port map (
        CONTROL     => npi_if_tx_ila_control ,
        CLK         => user_clk           ,
        trig0       => ll_tx_fsm_value_r  ,
        trig1       => NPI_CORE_DOUT_out,
        trig2(0)    => core_rfd           ,
        trig2(1)    => rd_req_start       ,
        trig2(2)    => rd_req_done ,
        trig2(3)    => NPI_CORE_DOUT_we_out,  
        trig2(4)    => tx_fifo_re,
        trig2(5)    => tx_fifo_empty,
        trig2(6)    => tx_fifo_prog_full,
        trig2(7)    => SATA_CORE_FULL 
        );
 
  end generate CHIPSCOPE_ILA_GEN;


end BEH;
