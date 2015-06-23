--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version	    : 3.6.1
--  \   \        Application	    : MIG
--  /   /        Filename           : DDR2_Ram_Core_controller_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : THis is main controller block. This includes the following
--                  features:
--                - The controller state machine that controls the
--                  initialization process upon power up, as well as the
--                  read, write, and refresh commands.
--                - Accepts and decodes the user commands.
--                - Generates the address and Bank address and control signals
--                  to the memory    
--                - Generates control signals for other modules.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_controller_0 is
  generic
    (
     COL_WIDTH : integer := COLUMN_ADDRESS;
     ROW_WIDTH : integer := ROW_ADDRESS
    );
  port(
    clk               : in  std_logic;
    rst0              : in  std_logic;
    rst180            : in  std_logic;
    address           : in  std_logic_vector(((ROW_ADDRESS + COLUMN_ADDRESS)-1)
                                            downto 0);
    bank_addr         : in  std_logic_vector((BANK_ADDRESS-1) downto 0);
    command_register  : in  std_logic_vector(2 downto 0);
    burst_done        : in  std_logic;
    ddr_rasb_cntrl    : out std_logic;
    ddr_casb_cntrl    : out std_logic;
    ddr_web_cntrl     : out std_logic;
    ddr_ba_cntrl      : out std_logic_vector((BANK_ADDRESS-1) downto 0);
    ddr_address_cntrl : out std_logic_vector((ROW_ADDRESS-1) downto 0);
    ddr_cke_cntrl     : out std_logic;
    ddr_csb_cntrl     : out std_logic;
    ddr_odt_cntrl     : out std_logic;
    dqs_enable        : out std_logic;
    dqs_reset         : out std_logic;
    write_enable      : out std_logic;
    rst_calib         : out std_logic;
    rst_dqs_div_int   : out std_logic;
    cmd_ack           : out std_logic;
    init              : out std_logic;
    ar_done           : out std_logic;
    wait_200us        : in  std_logic;
    auto_ref_req      : out std_logic;
    read_fifo_rden    : out std_logic -- Read Enable signal for read fifo(to data_read)
    );
end DDR2_Ram_Core_controller_0;


architecture arc of DDR2_Ram_Core_controller_0 is

  type s_m is (IDLE, PRECHARGE, AUTO_REFRESH, ACTIVE,
               FIRST_WRITE, WRITE_WAIT, BURST_WRITE,
               PRECHARGE_AFTER_WRITE, PRECHARGE_AFTER_WRITE_2, READ_WAIT,
               BURST_READ, ACTIVE_WAIT);

  type s_m1 is (INIT_IDLE, INIT_PRECHARGE,
                INIT_AUTO_REFRESH, INIT_LOAD_MODE_REG);
  signal next_state, current_state           : s_m;
  signal init_next_state, init_current_state : s_m1;

  signal ack_reg              : std_logic;
  signal ack_o                : std_logic;
  signal auto_ref             : std_logic;
  signal auto_ref1            : std_logic;
  signal autoref_value        : std_logic;
  signal auto_ref_detect1     : std_logic;
  signal autoref_count        : std_logic_vector((MAX_REF_WIDTH-1) downto 0);
  signal ar_done_p            : std_logic;
  signal auto_ref_issued      : std_logic;
  signal auto_ref_issued_p    : std_logic;
  signal ba_address_reg1      : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal ba_address_reg2      : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal burst_length         : std_logic_vector(2 downto 0);
  signal burst_cnt_max        : std_logic_vector(2 downto 0);
  signal cas_count            : std_logic_vector(2 downto 0);
  signal ras_count           : std_logic_vector(4 downto 0); 
  signal column_address_reg   : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal ddr_rasb1            : std_logic;
  signal ddr_casb1            : std_logic;
  signal ddr_web1             : std_logic;
  signal ddr_ba1              : std_logic_vector((BANK_ADDRESS-1) downto 0);
  signal ddr_address1         : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal dqs_enable_out       : std_logic;
  signal dqs_reset_out        : std_logic;
  signal dll_rst_count        : std_logic_vector(7 downto 0);
  signal init_count           : std_logic_vector(3 downto 0);
  signal init_done            : std_logic;
  signal init_done_r1         : std_logic;
  signal init_done_dis        : std_logic;
  signal init_done_value      : std_logic;
  signal init_memory          : std_logic;
  signal init_mem             : std_logic;
  signal init_cmd_in    : std_logic;
  signal init_pre_count       : std_logic_vector(6 downto 0);
  signal ref_freq_cnt         : std_logic_vector((MAX_REF_WIDTH-1) downto 0);
  signal read_cmd_in             : std_logic;
  signal read_cmd1            : std_logic;
  signal read_cmd2            : std_logic;
  signal read_cmd3            : std_logic;
  signal rcd_count           : std_logic_vector(2 downto 0);
  signal rp_cnt_value         : std_logic_vector(2 downto 0);
  signal rfc_count_reg        : std_logic;
  signal ar_done_reg          : std_logic;
  signal rdburst_end_1        : std_logic;
  signal rdburst_end_2        : std_logic;
  signal rdburst_end          : std_logic;
  signal rp_count             : std_logic_vector(2 downto 0);
  signal rfc_count            : std_logic_vector(7 downto 0);
  signal row_address_reg      : std_logic_vector((ROW_ADDRESS-1) downto 0);
  signal column_address1      : std_logic_vector((ROW_ADDRESS -1) downto 0);
  signal rst_dqs_div_r        : std_logic;
  signal rst_dqs_div_r1       : std_logic;
  signal wrburst_end_cnt      : std_logic_vector(2 downto 0);
  signal wrburst_end          : std_logic;
  signal wrburst_end_1        : std_logic;
  signal wrburst_end_2        : std_logic;
  signal wrburst_end_3        : std_logic;
  signal wr_count             : std_logic_vector(2 downto 0);
  signal write_enable_out     : std_logic;
  signal write_cmd_in         : std_logic;
  signal write_cmd2           : std_logic;
  signal write_cmd3           : std_logic;
  signal write_cmd1           : std_logic;
  signal go_to_active_value   : std_logic;
  signal go_to_active         : std_logic;
  signal dqs_div_cascount     : std_logic_vector(2 downto 0);
  signal dqs_div_rdburstcount : std_logic_vector(2 downto 0);
  signal dqs_enable1          : std_logic;
  signal dqs_enable2          : std_logic;
  signal dqs_enable3          : std_logic;
  signal dqs_reset1_clk0      : std_logic;
  signal dqs_reset2_clk0      : std_logic;
  signal dqs_reset3_clk0      : std_logic;
  signal dqs_enable_int       : std_logic;
  signal dqs_reset_int        : std_logic;
  signal rst180_r             : std_logic;
  signal rst0_r               : std_logic;
  signal emr                  : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr                  : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr_dll_rst          : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal lmr_dll_set          : std_logic_vector(ROW_ADDRESS - 1 downto 0);
  signal ddr_odt1             : std_logic;
  signal ddr_odt2             : std_logic;
  signal rst_dqs_div_int1     : std_logic;
  signal accept_cmd_in        : std_logic;
  signal dqs_enable_i         : std_logic;
  signal auto_ref_wait        : std_logic;
  signal auto_ref_wait1       : std_logic;
  signal auto_ref_wait2       : std_logic;
  signal address_reg          : std_logic_vector(((ROW_ADDRESS +
                                                   COLUMN_ADDRESS)-1) downto 0);
  signal ddr_rasb2            : std_logic;
  signal ddr_casb2            : std_logic;
  signal ddr_web2             : std_logic;
  signal count6               : std_logic_vector(7 downto 0);
  signal clk180               : std_logic;
  signal odt_deassert         : std_logic;
  

  constant addr_const1 : std_logic_vector(14 downto 0) := "000010000000000";
  constant addr_const2 : std_logic_vector(14 downto 0) := "000001110000000";  --380
  constant addr_const3 : std_logic_vector(14 downto 0) := "000110001111111";  --C7F
  constant ba_const1   : std_logic_vector(2 downto 0)  := "010";
  constant ba_const2   : std_logic_vector(2 downto 0)  := "011";
  constant ba_const3   : std_logic_vector(2 downto 0)  := "001";

  attribute iob                        : string;
  attribute syn_useioff                : boolean;
  attribute syn_preserve               : boolean;
  attribute syn_keep                   : boolean;

  attribute iob of rst_iob_out                 : label is "FORCE";
  attribute syn_useioff of rst_iob_out         : label is true;
  attribute syn_preserve of lmr_dll_rst        : signal is true;
  attribute syn_preserve of lmr_dll_set        : signal is true;
  attribute syn_preserve of ba_address_reg1    : signal is true;
  attribute syn_preserve of ba_address_reg2    : signal is true;
  attribute syn_preserve of column_address_reg : signal is true;
  attribute syn_preserve of row_address_reg    : signal is true;

begin

  clk180      <= not clk;
  emr         <= EXT_LOAD_MODE_REGISTER;
  lmr         <= LOAD_MODE_REGISTER;
  lmr_dll_rst <= lmr(ROW_ADDRESS - 1 downto 9) & '1' & lmr(7 downto 0);
  lmr_dll_set <= lmr(ROW_ADDRESS - 1 downto 9) & '0' & lmr(7 downto 0);


-- Input : COMMAND REGISTER FORMAT
-- 000 - NOP
-- 010 - Initialize memory
-- 100 - Write Request
-- 110 - Read request


-- Input : Address format
-- row address = address((ROW_ADDRESS + COLUMN_ADDRESS) -1 downto COLUMN_ADDRESS)
-- column address = address(COLUMN_ADDRESS-1 downto 0)

  ddr_csb_cntrl     <= '0';
  ddr_cke_cntrl     <= not wait_200us;
  init              <= init_done;
  ddr_rasb_cntrl    <= ddr_rasb2;
  ddr_casb_cntrl    <= ddr_casb2;
  ddr_web_cntrl     <= ddr_web2;
  rst_dqs_div_int   <= rst_dqs_div_int1;
  ddr_address_cntrl <= ddr_address1;
  ddr_ba_cntrl      <= ddr_ba1;

  -- turn off auto-precharge when issuing read/write commands (A10 = 0)
  -- mapping the column address for linear addressing.
  gen_ddr_addr_col_0: if (COL_WIDTH = ROW_WIDTH-1) generate
    column_address1 <= (address_reg(COL_WIDTH-1 downto 10) & '0' &
                        address_reg(9 downto 0));
  end generate;

  gen_ddr_addr_col_1: if ((COL_WIDTH > 10) and
                          not(COL_WIDTH = ROW_WIDTH-1)) generate
    column_address1(ROW_WIDTH-1 downto COL_WIDTH+1) <= (others => '0');
    column_address1(COL_WIDTH downto 0) <=
      (address_reg(COL_WIDTH-1 downto 10) & '0' & address_reg(9 downto 0));
  end generate;

  gen_ddr_addr_col_2: if (not((COL_WIDTH > 10) or
                              (COL_WIDTH = ROW_WIDTH-1))) generate
    column_address1(ROW_WIDTH-1 downto COL_WIDTH+1) <= (others => '0');
    column_address1(COL_WIDTH downto 0) <=
      ('0' & address_reg(COL_WIDTH-1 downto 0));
  end generate;


  process(clk)
  begin
    if clk'event and clk = '0' then
      rst180_r <= rst180;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      rst0_r <= rst0;
    end if;
  end process;

--******************************************************************************
-- Register user address
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      row_address_reg    <= address_reg(((ROW_ADDRESS + COLUMN_ADDRESS)-1) downto
                                        COLUMN_ADDRESS);
      column_address_reg <= column_address1;
      ba_address_reg1    <= bank_addr;
      ba_address_reg2    <= ba_address_reg1;
      address_reg        <= address;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        burst_length <= "000";
      else
        burst_length <= lmr(2 downto 0);
      end if;
    end if;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '0') then
      if rst180_r = '1' then
        accept_cmd_in <= '0';
      elsif (current_state = IDLE and (rp_count = "000"  and (rfc_count_reg and
                                        not(auto_ref_wait) and
                                        not(auto_ref_issued)) = '1')) then
        accept_cmd_in <= '1';
      else
        accept_cmd_in <= '0';
      end if;
    end if;
  end process;
--******************************************************************************
-- Commands from user.
--******************************************************************************
  init_cmd_in       <= '1' when (command_register = "010") else '0';
  write_cmd_in      <= '1' when (command_register = "100" and
                                 accept_cmd_in = '1') else '0';
  read_cmd_in       <= '1' when (command_register = "110" and
                                 accept_cmd_in = '1') else '0';

--******************************************************************************
-- write_cmd1 is asserted when user issued write command and the controller s/m
-- is in idle state and AUTO_REF is not asserted.
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        write_cmd1   <= '0';
        write_cmd2   <= '0';
        write_cmd3   <= '0';
      else
        if (accept_cmd_in = '1') then
          write_cmd1 <= write_cmd_in;
        end if;
        write_cmd2   <= write_cmd1;
        write_cmd3   <= write_cmd2;
      end if;
    end if;
  end process;

--******************************************************************************
-- read_cmd1 is asserted when user issued read command and the controller s/m
-- is in idle state and AUTO_REF is not asserted.
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        read_cmd1   <= '0';
        read_cmd2   <= '0';
        read_cmd3   <= '0';
      else
        if (accept_cmd_in = '1') then
          read_cmd1 <= read_cmd_in;
        end if;
        read_cmd2   <= read_cmd1;
        read_cmd3   <= read_cmd2;
      end if;
    end if;
  end process;

--******************************************************************************
-- ras_count- Active to Precharge time
-- Controller is giving tras violation when user issues a single read command for 
-- BL=4 and tRAS is more then 42ns.It uses a fixed clk count of 7 clocks which is 
-- 7*6(@166) = 42ns. Addded ras_count counter which will take care of tras timeout. 
-- RAS_COUNT_VALUE parameter is used to load the counter and it depends on the 
-- selected memory and frequency
--******************************************************************************
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ras_count <= "00000";
      elsif(current_state = ACTIVE) then
        ras_count <= RAS_COUNT_VALUE - '1';
      elsif(ras_count /= "00000") then
        ras_count <= ras_count - '1';
      end if;
    end if;
  end process;
--******************************************************************************
-- rfc_count
-- An executable command can be issued only after Trfc period after a AUTOREFRESH
-- command is issued. rfc_count_value is set in the parameter file depending on
-- the memory device speed grade and the selected frequency.For example for 5B
-- speed grade, at 133Mhz, rfc_counter_value = 8'b00001001.
-- ( Trfc/clk_period= 75/7.5= 10)
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rfc_count <= "00000000";
      elsif(current_state = AUTO_REFRESH) then
        rfc_count <= RFC_COUNT_VALUE;
      elsif(rfc_count /= "00000000") then
        rfc_count <= rfc_count - '1';
      end if;
    end if;
  end process;

--******************************************************************************
-- rp_count
-- An executable command can be issued only after Trp period after a PRECHARGE
-- command is issued. 
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rp_count <= "000";
      elsif(current_state = PRECHARGE) then
        rp_count <= RP_COUNT_VALUE;
      elsif(rp_count /= "000") then
        rp_count <= rp_count - '1';
      end if;
    end if;
  end process;


  
--******************************************************************************
-- rcd_count
-- ACTIVE to READ/WRITE delay - Minimum interval between ACTIVE and READ/WRITE command. 
--******************************************************************************

  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        rcd_count <= "000";
      elsif (current_state = ACTIVE) then
        rcd_count <= "001";
      elsif (rcd_count /= "000") then
        rcd_count <= rcd_count - '1';
      end if;
    end if;
  end process;

--******************************************************************************
-- WR Counter
-- a PRECHARGE command can be applied only after 2 cycles after a WRITE command
-- has finished executing
--******************************************************************************
  
  process (clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        wr_count   <= "000";
      else
        if (dqs_enable_int = '1') then
          wr_count <= TWR_COUNT_VALUE;
        elsif (wr_count /= "000") then
          wr_count <= wr_count - "001";
        end if;
      end if;
    end if;
  end process;

--******************************************************************************
-- autoref_count - This counter is used to issue AUTO REFRESH command to
-- the memory for every 7.8125us.
-- (Auto Refresh Request is raised for every 7.7 us to allow for termination
-- of any ongoing bus transfer).For example at 166MHz frequency
-- autoref_count = refresh_time_period/clock_period = 7.7us/6.02ns = 1279
--******************************************************************************
  
  ref_freq_cnt <= MAX_REF_CNT;
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        autoref_value <= '0';
      elsif (autoref_count = ref_freq_cnt) then
        autoref_value <= '1';
      else
        autoref_value <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        autoref_count <= (others => '0');
      elsif (autoref_value = '1') then
        autoref_count <= (others => '0');
      else
        autoref_count <= autoref_count + '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_detect1 <= '0';
        auto_ref1        <= '0';
      else
        auto_ref_detect1 <= autoref_value and init_done;
        auto_ref1        <= auto_ref_detect1;
      end if;
    end if;
  end process;

  ar_done_p <= '1' when ar_done_reg = '1' else '0';

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_wait   <= '0';
        ar_done         <= '0';
        auto_ref_issued <= '0';
      else
        if (auto_ref1 = '1' and auto_ref_wait = '0') then
          auto_ref_wait <= '1';
        elsif (auto_ref_issued = '1') then
          auto_ref_wait <= '0';
        else
          auto_ref_wait <= auto_ref_wait;
        end if;
        ar_done         <= ar_done_p;
        auto_ref_issued <= auto_ref_issued_p;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        auto_ref_wait1   <= '0';
        auto_ref_wait2   <= '0';
        auto_ref         <= '0';
      else
        if (auto_ref_issued_p = '1') then
          auto_ref_wait1 <= '0';
          auto_ref_wait2 <= '0';
          auto_ref       <= '0';
        else
          auto_ref_wait1 <= auto_ref_wait;
          auto_ref_wait2 <= auto_ref_wait1;
          auto_ref       <= auto_ref_wait2;
        end if;
      end if;
    end if;
  end process;

  auto_ref_req      <= auto_ref_wait;
  auto_ref_issued_p <= '1' when (current_state = AUTO_REFRESH) else '0';

--******************************************************************************
-- Common counter for the Initialization sequence
--******************************************************************************
  
  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        count6 <= "00000000";
      elsif(init_current_state = INIT_AUTO_REFRESH or init_current_state
            = INIT_PRECHARGE or init_current_state = INIT_LOAD_MODE_REG) then
        count6 <= RFC_COUNT_VALUE; 
      elsif(count6 /= "00000000") then
        count6 <= count6 - '1';
      else
        count6 <= "00000000";
      end if;
    end if;
  end process;

--******************************************************************************
-- While doing consecutive READs or WRITEs, the burst_cnt_max value determines
-- when the next READ or WRITE command should be issued. burst_cnt_max shows the
-- number of clock cycles for each burst. 
-- e.g burst_cnt_max = 2 for a burst length of 4
--                   = 4 for a burst length of 8
--******************************************************************************

  burst_cnt_max <= "010" when burst_length = "010" else
                   "100" when burst_length = "011" else
                   "000";

  
  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        cas_count <= "000";
      elsif(current_state = BURST_READ) then
        cas_count <= burst_cnt_max - '1';
      elsif(cas_count /= "000") then
        cas_count <= cas_count - '1';
      end if;
    end if;
  end process;


  process(clk)
  begin
    if (clk'event and clk = '0') then
      if (rst180_r = '1') then
        wrburst_end_cnt <= "000";
      elsif ((current_state = FIRST_WRITE) or (current_state = BURST_WRITE)) then
        wrburst_end_cnt <= burst_cnt_max;
      elsif (wrburst_end_cnt /= "000") then
        wrburst_end_cnt <= wrburst_end_cnt - '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        rdburst_end_1   <= '0';
      else
        if(burst_done = '1') then
          rdburst_end_1 <= '1';
        else
          rdburst_end_1 <= '0';
        end if;
        rdburst_end_2   <= rdburst_end_1;
      end if;
    end if;
  end process;

  rdburst_end <= rdburst_end_1 or rdburst_end_2;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        wrburst_end_1   <= '0';
      else
        if (burst_done = '1') then
          wrburst_end_1 <= '1';
        else
          wrburst_end_1 <= '0';
        end if;
        wrburst_end_2   <= wrburst_end_1;
        wrburst_end_3   <= wrburst_end_2;
      end if;
    end if;
  end process;

  wrburst_end <= wrburst_end_1 or wrburst_end_2 or wrburst_end_3;

--******************************************************************************
-- dqs_enable and dqs_reset signals are used to generate DQS signal during write
-- data.
--******************************************************************************
  dqs_enable_out <= '1' when ((current_state = FIRST_WRITE) or
                              (current_state = BURST_WRITE) or
                              (WRburst_end_cnt /= "000")) else '0';
  dqs_reset_out  <= '1' when current_state = FIRST_WRITE  else '0';
  dqs_enable     <= dqs_enable_i;
  
    dqs_enable_i   <= dqs_enable2;
  dqs_reset      <= dqs_reset2_clk0;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        dqs_enable_int <= '0';
        dqs_reset_int  <= '0';
      else
        dqs_enable_int <= dqs_enable_out;
        dqs_reset_int  <= dqs_reset_out;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if rst0_r = '1' then
        dqs_enable1     <= '0';
        dqs_enable2     <= '0';
        dqs_enable3     <= '0';
        dqs_reset1_clk0 <= '0';
        dqs_reset2_clk0 <= '0';
        dqs_reset3_clk0 <= '0';
      else
        dqs_enable1     <= dqs_enable_int;
        dqs_enable2     <= dqs_enable1;
        dqs_enable3     <= dqs_enable2;
        dqs_reset1_clk0 <= dqs_reset_int;
        dqs_reset2_clk0 <= dqs_reset1_clk0;
        dqs_reset3_clk0 <= dqs_reset2_clk0;
      end if;
    end if;
  end process;

--******************************************************************************
--Write Enable signal to the datapath
--******************************************************************************

  write_enable_out <= '1' when (wrburst_end_cnt /= "000")else '0';
  cmd_ack          <= ack_reg;
  ack_o            <= '1' when ((write_cmd_in = '1') or (write_cmd1 = '1') or
                                (read_cmd_in = '1') or (read_cmd1 = '1')) else '0';
  

  process(clk)
  begin
   if clk'event and clk = '0' then
    if rst180_r = '1' then
     write_enable <= '0';
    else
     write_enable <= write_enable_out;
    end if;
   end if;
  end process;


  ACK_REG_INST1 : FD
    port map (
      Q => ack_reg,
      D => ack_o,
      C => clk180
      );

--******************************************************************************
-- init_done will be asserted when initialization sequence is complete
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_memory  <= '0';
        init_done    <= '0';
        init_done_r1 <= '0';
      else
        init_memory  <= init_mem;
        init_done_r1 <= init_done;
        if ((init_done_value = '1')and (init_count = "1011")) then
          init_done  <= '1';
        else
          init_done  <= '0';
        end if;
      end if;
    end if;
  end process;

  init_done_dis <= '1' when ( init_done = '1' and init_done_r1 = '0') else
                   '0';
  
  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '0' then
        --synthesis translate_off
        assert (init_done_dis = '0') report "INITIALIZATION_DONE" severity note;
        --synthesis translate_on
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '0' then
      if init_cmd_in = '1' or rst180_r = '1' then
        init_pre_count <= "1010000";
      else
        init_pre_count <= init_pre_count - "0000001";
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_mem <= '0';
      elsif (init_cmd_in = '1') then
        init_mem <= '1';
      elsif ((init_count = "1011") and (count6 = "00000000")) then
        init_mem <= '0';
      else
        init_mem <= init_mem;
      end if;
    end if;
  end process;

-- Counter for Memory Initialization sequence


 process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        init_count <= "0000";
      elsif(((init_current_state = INIT_PRECHARGE) or 
		(init_current_state = INIT_LOAD_MODE_REG) or
		(init_current_state = INIT_AUTO_REFRESH)) and init_memory = '1') then
        init_count <= init_count + '1';
      else
        init_count <= init_count;
      end if;
    end if;
  end process;

  
  init_done_value     <= '1' when ((init_count = "1011") and
                               (dll_rst_count = "00000001")) else '0';

-- Counter to count 200 clock cycles When DLL reset is issued during initialization.
  

 process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dll_rst_count <= "00000000";
      elsif(init_count = "0100") then
        dll_rst_count <= "11001000";
      elsif(dll_rst_count /= "00000001") then
        dll_rst_count <= dll_rst_count - '1';
      else
        dll_rst_count <= dll_rst_count;
      end if;
    end if;
  end process;


  go_to_active_value  <= '1' when ((write_cmd_in = '1') and (accept_cmd_in = '1'))
                         or ((read_cmd_in = '1') and (accept_cmd_in = '1'))
                         else '0';

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        go_to_active <= '0';
      else
        go_to_active <= go_to_active_value;
      end if;
    end if;
  end process;

--******************************************************************************
-- Register counter values
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ar_done_reg   <= '0';
        rfc_count_reg <= '0';
      else
        if(rfc_count = "00000010") then   
          ar_done_reg <= '1';
        else
          ar_done_reg <= '0';
        end if;
        if(ar_done_reg = '1') then
          rfc_count_reg <= '1';
        elsif (init_done = '1' and init_mem = '0' and rfc_count = "00000000")
        then
          rfc_count_reg <= '1';
        elsif (auto_ref_issued = '1') then
          rfc_count_reg <= '0';
        else
          rfc_count_reg <= rfc_count_reg;
        end if;
      end if;
    end if;
  end process;

--******************************************************************************
-- Initialization state machine
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        init_current_state <= INIT_IDLE;
      else
        init_current_state <= init_next_state;
      end if;
    end if;
  end process;

  process (rst180_r, init_count, init_current_state, init_memory, count6,
           init_pre_count)
  begin
    if rst180_r = '1' then
      init_next_state             <= INIT_IDLE;
    else
      case init_current_state is
        when INIT_IDLE    =>
          if init_memory = '1' then
            case init_count is
              when "0000" =>
                if(init_pre_count = "0000001") then
                  init_next_state <= INIT_PRECHARGE;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0001" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0010" =>
                -- for reseting DLL in Base Mode register
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0011" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;  -- For EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0100" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;  -- For EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0101" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_PRECHARGE;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0110" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_AUTO_REFRESH;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "0111" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_AUTO_REFRESH;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1000" =>
                -- to deactivate the rst DLL bit in the LMR
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1001" =>
                -- to set OCD to default in EMR
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1010" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_LOAD_MODE_REG;  --  OCD exit in EMR
                else
                  init_next_state <= INIT_IDLE;
                end if;
              when "1011" =>
                if (count6 = "00000000") then
                  init_next_state <= INIT_IDLE;
                else
                  init_next_state <= init_current_state;
                end if;
              when others =>
                init_next_state   <= INIT_IDLE;
            end case;
          else
            init_next_state <= INIT_IDLE;
          end if;
        when INIT_PRECHARGE =>
          init_next_state <= INIT_IDLE;
        when INIT_LOAD_MODE_REG =>
          init_next_state <= INIT_IDLE;
        when INIT_AUTO_REFRESH =>
          init_next_state <= INIT_IDLE;
        when others =>
          init_next_state <= INIT_IDLE;
      end case;
    end if;
  end process;

--******************************************************************************
-- MAIN state machine
--******************************************************************************

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        current_state <= IDLE;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  process (rst180_r, cas_count, wr_count,
           go_to_active, write_cmd1, read_cmd3, current_state,
           wrburst_end, wrburst_end_cnt,
           rdburst_end, init_memory,rcd_count, ras_count,
           auto_ref, rfc_count_reg, rp_count)
  begin
    if rst180_r = '1' then
      next_state         <= IDLE;
    else
      case current_state is
        
        when IDLE =>
          if (init_memory = '0') then
            if(auto_ref = '1' and rfc_count_reg = '1' and rp_count = "000") then
              next_state <= AUTO_REFRESH;  -- normal Refresh in the IDLE state
            elsif go_to_active = '1' then
              next_state <= ACTIVE;
            else
              next_state <= IDLE;
            end if;
          else
            next_state   <= IDLE;
          end if;
          
        when PRECHARGE =>
          next_state <= IDLE;
          
        when AUTO_REFRESH =>
          next_state <= IDLE;
          
        when ACTIVE =>
          next_state <= ACTIVE_WAIT;
          
        when ACTIVE_WAIT =>
          if (rcd_count = "000" and write_cmd1 = '1') then
            next_state <= FIRST_WRITE;
          elsif (rcd_count = "000" and read_cmd3 = '1') then
            next_state <= BURST_READ;
          else
            next_state <= ACTIVE_WAIT;
          end if;
          
        when FIRST_WRITE =>
          next_state <= WRITE_WAIT;
          
        when WRITE_WAIT =>
          case wrburst_end is
            when '1' =>
              next_state <= PRECHARGE_AFTER_WRITE;
            when '0' =>
              if wrburst_end_cnt = "010" then
                next_state <= BURST_WRITE;
              else
                next_state <= WRITE_WAIT;
              end if;
            when others =>
              next_state   <= WRITE_WAIT;
          end case;
          
        when BURST_WRITE =>
          next_state <= WRITE_WAIT;
          
        when PRECHARGE_AFTER_WRITE =>
          next_state <= PRECHARGE_AFTER_WRITE_2;
          
        when PRECHARGE_AFTER_WRITE_2 =>
          if(wr_count = "00" and ras_count = "00000") then   
            next_state <= PRECHARGE;
          else
            next_state <= PRECHARGE_AFTER_WRITE_2;
          end if;
          
        when READ_WAIT  =>
          case rdburst_end is
            when '1'    =>
              next_state   <= PRECHARGE_AFTER_WRITE;
            when '0'    =>
              if cas_count = "001" then
                next_state <= BURST_READ;
              else
                next_state <= READ_WAIT;
              end if;
            when others =>
              next_state   <= READ_WAIT;
          end case;

        when BURST_READ =>
          next_state <= READ_WAIT;

        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_address1 <= (others => '0');
      elsif (init_mem = '1') then
        case (init_count) is
          when "0000" | "0101" =>
            ddr_address1 <= addr_const1((ROW_ADDRESS - 1) downto 0);
          when "0001"               =>
            ddr_address1 <= (others => '0');
          when "0010"               =>
            ddr_address1 <= (others => '0');
          when "0011"               =>
            ddr_address1 <= emr;
          when "0100"               =>
            ddr_address1 <= lmr_dll_rst;
          when "1000"               =>
            ddr_address1 <= lmr_dll_set;
          when "1001"               =>
            ddr_address1 <= emr or addr_const2((ROW_ADDRESS - 1) downto 0);
          when "1010"               =>
            ddr_address1 <= emr and addr_const3((ROW_ADDRESS - 1) downto 0);
          when others               =>
            ddr_address1 <= (others => '0');
        end case;
      elsif (current_state = PRECHARGE) then
        ddr_address1 <= addr_const1((ROW_ADDRESS - 1) downto 0);
      elsif (current_state = ACTIVE) then
        ddr_address1 <= row_address_reg;
      elsif (current_state = BURST_WRITE or current_state = FIRST_WRITE or
             current_state = BURST_READ) then
        ddr_address1 <= column_address_reg((ROW_ADDRESS - 1) downto 0);
      else
        ddr_address1 <= (others => '0');
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_ba1     <= (others => '0');
      elsif (init_mem = '1') then
        case (init_count) is
          when "0001" =>
            ddr_ba1 <= ba_const1((BANK_ADDRESS -1) downto 0);
          when "0010" =>
            ddr_ba1 <= ba_const2((BANK_ADDRESS -1) downto 0);
          when "0011" | "1001" | "1010" =>
            ddr_ba1 <= ba_const3((BANK_ADDRESS -1) downto 0);
          when others =>
            ddr_ba1 <= (others => '0');
        end case;
      elsif (current_state = ACTIVE or current_state = FIRST_WRITE or
             current_state = BURST_WRITE or current_state = BURST_READ) then
        ddr_ba1     <= ba_address_reg2;
      else
        ddr_ba1     <= (others => '0');
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        odt_deassert <= '0';
      elsif(wrburst_end_3 = '1') then
        odt_deassert <= '1';
      elsif(write_cmd3 = '0') then
        odt_deassert <= '0';
      else
        odt_deassert <= odt_deassert;
      end if;
    end if;
  end process;

  ddr_odt1 <= '1' when (write_cmd3 = '1' and (emr(6) = '1' or emr(2) = '1') and
                        odt_deassert = '0') else '0';

--******************************************************************************
-- Register CONTROL SIGNALS outputs
--******************************************************************************
  
  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_odt2  <= '0';
        ddr_rasb2 <= '1';
        ddr_casb2 <= '1';
        ddr_web2  <= '1';
      else
        ddr_odt2  <= ddr_odt1;
        ddr_rasb2 <= ddr_rasb1;
        ddr_casb2 <= ddr_casb1;
        ddr_web2  <= ddr_web1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '0' then
      if rst180_r = '1' then
        ddr_odt_cntrl <= '0';
      else
        ddr_odt_cntrl <= ddr_odt2;
      end if;
    end if;
  end process;

--******************************************************************************
-- control signals to the Memory
--******************************************************************************

  ddr_rasb1 <= '0' when (current_state = ACTIVE or current_state = PRECHARGE or
                         current_state = AUTO_REFRESH or
                         init_current_state = INIT_PRECHARGE or
                         init_current_state = INIT_AUTO_REFRESH or
                         init_current_state = INIT_LOAD_MODE_REG) else '1';

  ddr_casb1 <= '0' when (current_state = BURST_READ or
                         current_state = BURST_WRITE or
                         current_state = FIRST_WRITE or
                         current_state = AUTO_REFRESH or
                         init_current_state = INIT_AUTO_REFRESH or
                         init_current_state = INIT_LOAD_MODE_REG) else '1';

  ddr_web1 <= '0' when (current_state = BURST_WRITE or
                        current_state = FIRST_WRITE or
                        current_state = PRECHARGE or
                        init_current_state = INIT_PRECHARGE or
                        init_current_state = INIT_LOAD_MODE_REG) else '1';

-------------------------------------------------------------------------------

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dqs_div_cascount     <= "000";
      else
        if(ddr_rasb2 = '1' and ddr_casb2 = '0' and ddr_web2 = '1') then
          dqs_div_cascount   <= burst_cnt_max;
        else
          if dqs_div_cascount /= "000" then
            dqs_div_cascount <= dqs_div_cascount - "001";
          else
            dqs_div_cascount <= dqs_div_cascount;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        dqs_div_rdburstcount     <= "000";
      else
        if (dqs_div_cascount = "001" and burst_length = "010") then
          dqs_div_rdburstcount   <= "010";
        elsif (dqs_div_cascount = "011" and burst_length = "011") then
          dqs_div_rdburstcount   <= "100";
        else
          if dqs_div_rdburstcount /= "000" then
            dqs_div_rdburstcount <= dqs_div_rdburstcount - "001";
          else
            dqs_div_rdburstcount <= dqs_div_rdburstcount;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '0') then
      if rst180_r = '1' then
        rst_dqs_div_r     <= '0';
      else
        if (dqs_div_cascount = "001" and burst_length = "010")then
          rst_dqs_div_r   <= '1';
        elsif (dqs_div_cascount = "011" and burst_length = "011")then
          rst_dqs_div_r   <= '1';
        else
          if (dqs_div_rdburstcount = "001" and dqs_div_cascount = "000") then
            rst_dqs_div_r <= '0';
          else
            rst_dqs_div_r <= rst_dqs_div_r;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)                          -- For Reg dimm
  begin
    if(clk'event and clk = '0') then
      rst_dqs_div_r1 <= rst_dqs_div_r;
    end if;
  end process;

  process (clk)
  begin
    if (clk'event and clk = '0') then
      if (dqs_div_cascount /= "000" or dqs_div_rdburstcount /= "000") then
        rst_calib <= '1';
      else
        rst_calib <= '0';
      end if;
    end if;
  end process;

  rst_iob_out : FD
    port map (
      Q => rst_dqs_div_int1,
            D => rst_dqs_div_r, 
      C => clk
      );

--Read fifo read enable logic, this signal is same as rst_dqs_div_int signal for RDIMM 
--and one clock ahead of rst_dqs_div_int for component or UDIMM OR SODIMM. 
  process(clk)
  begin
    if clk'event and clk = '0' then
      read_fifo_rden <= rst_dqs_div_r1;
    end if;
  end process;
end arc;
