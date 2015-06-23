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
-- ENTITY: command_layer 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description: This sub-module implements the Command Layer of the SATA Protocol
--              The User Command parameters such as: cmd_type, sector_address, sector_count
--              are encoded into a command FIS according to the ATA format and passed to
--              the Transport Layer.                   
--              
-- PORTS: 
-----------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity command_layer is
  generic(
    CHIPSCOPE           : boolean := false
       );
  port(
     -- Clock and Reset Signals
    clk                   : in  std_logic;
    sw_reset              : in  std_logic;
    -- ChipScope ILA / Trigger Signals
    cmd_layer_ila_control  : in  std_logic_vector(35 downto 0);
    ---------------------------------------
    -- Signals from/to User Logic
    new_cmd               : in  std_logic;
    cmd_done              : out std_logic;
    cmd_type	          : in  std_logic_vector(1 downto 0);
    sector_count          : in  std_logic_vector(31 downto 0);
    sector_addr           : in  std_logic_vector(31 downto 0);
    user_din              : in  std_logic_vector(31 downto 0); 
    user_din_re_out       : out std_logic; 
    user_dout             : out std_logic_vector(31 downto 0); 
    user_dout_re          : in std_logic; 
    user_fifo_empty       : in std_logic; 
    user_fifo_full        : in std_logic; 
    sector_timer_out      : out std_logic_vector(31 downto 0);
    -- Signals from/to Link Layer
    write_fifo_full       : in std_logic;
    ll_ready_for_cmd      : in std_logic;
    ll_cmd_start	  : out std_logic;
    ll_cmd_type	          : out std_logic_vector(1 downto 0);
    ll_dout               : out std_logic_vector(31 downto 0);
    ll_dout_we            : out std_logic;
    ll_din                : in  std_logic_vector(31 downto 0);
    ll_din_re             : out  std_logic
      );
end command_layer;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture BEHAV of command_layer is

 -------------------------------------------------------------------------------
 -- COMMAND LAYER
 -------------------------------------------------------------------------------
  constant READ_DMA         : std_logic_vector(7 downto 0) := x"25";
  constant WRITE_DMA        : std_logic_vector(7 downto 0) := x"35";
  constant REG_FIS_VALUE    : std_logic_vector(7 downto 0) := x"27";
  constant DATA_FIS_VALUE   : std_logic_vector(7 downto 0) := x"46";
  constant DEVICE_REG       : std_logic_vector(7 downto 0) := x"E0";
  constant FEATURES         : std_logic_vector(7 downto 0) := x"00";
  constant READ_DMA_CMD     : std_logic_vector(1 downto 0) := "01";
  constant WRITE_DMA_CMD    : std_logic_vector(1 downto 0) := "10";
  constant DATA_FIS_HEADER  : std_logic_vector(31 downto 0) := x"00000046";
  constant NDWORDS_PER_DATA_FIS : std_logic_vector(15 downto 0) := conv_std_logic_vector(2048, 16);--128*16       
  constant SECTOR_NDWORDS     : integer := 128;  -- 128 DWORDS / 512 Byte Sector    

  component cmd_layer_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(3  downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(31 downto 0);
      trig4   : in std_logic_vector(31 downto 0);
      trig5   : in std_logic_vector(1 downto 0);
      trig6   : in std_logic_vector(1 downto 0);
      trig7   : in std_logic_vector(31 downto 0);
      trig8   : in std_logic_vector(31 downto 0);
      trig9   : in std_logic_vector(23 downto 0);
      trig10  : in std_logic_vector(15 downto 0);
      trig11  : in std_logic_vector(11 downto 0);
      trig12  : in std_logic_vector(15 downto 0);
      trig13  : in std_logic_vector(31 downto 0)
   );
  end component;


 -----------------------------------------------------------------------------
  -- Finite State Machine Declaration (curr and next states)
 -----------------------------------------------------------------------------
  type COMMAND_FSM_TYPE is (wait_for_cmd, build_REG_FIS, send_REG_FIS_DW1, 
                           send_REG_FIS_DW2, send_REG_FIS_DW3, send_REG_FIS_DW4, send_REG_FIS_DW5,
                           send_DATA_FIS_HEADER, send_write_data, send_cmd_start, wait_for_cmd_start, 
                           wait_for_cmd_done, dead                           
                     );
  signal command_fsm_curr, command_fsm_next : COMMAND_FSM_TYPE := wait_for_cmd; 
  signal command_fsm_value                  : std_logic_vector (0 to 3);
  
  signal ll_cmd_start_next                 : std_logic;
  signal ll_cmd_start_out                  : std_logic;
  signal cmd_done_next                  : std_logic;
  signal cmd_done_out                   : std_logic;
  signal read_fifo_empty                : std_logic;
  signal ll_dout_next                   : std_logic_vector(0 to 31); 
  signal ll_dout_we_next                : std_logic; 
  signal ll_dout_out                    : std_logic_vector(0 to 31); 
  signal ll_dout_we_out                 : std_logic; 
  signal ll_cmd_type_next               : std_logic_vector(0 to 1); 
  signal ll_cmd_type_out                : std_logic_vector(0 to 1); 
  signal dword_count                    : std_logic_vector(0 to 15); 
  signal dword_count_next               : std_logic_vector(0 to 15); 
  signal write_data_count               : std_logic_vector(0 to 31); 
  signal write_data_count_next          : std_logic_vector(0 to 31); 
  signal user_din_re                    : std_logic; 
  signal sector_count_int               : integer; 

  --- ILA signals ----
  signal user_dout_ila                  : std_logic_vector(0 to 31); 
  signal ll_din_re_ila                  : std_logic; 

  --- Timer ----
  signal sector_timer                   : std_logic_vector(31 downto 0);
  --signal sata_timer                     : std_logic_vector(31 downto 0);

  type reg_fis_type is
    record
      FIS_type      : std_logic_vector(7 downto 0);
      pad_8         : std_logic_vector(7 downto 0);
      command       : std_logic_vector(7 downto 0);
      features      : std_logic_vector(7 downto 0);
      LBA           : std_logic_vector(23 downto 0);
      device        : std_logic_vector(7 downto 0);
      LBA_exp       : std_logic_vector(23 downto 0);
      features_exp  : std_logic_vector(7 downto 0);
      sector_count  : std_logic_vector(15 downto 0);
      pad_16        : std_logic_vector(15 downto 0);
      pad_32        : std_logic_vector(31 downto 0);
    end record; 

  signal reg_fis   : reg_fis_type;
  signal reg_fis_next   : reg_fis_type;

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- LINK LAYER
-------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- PROCESS: COMMAND_FSM_VALUE_PROC
  -- PURPOSE: ChipScope State Indicator Signal
  -----------------------------------------------------------------------------
  COMMAND_FSM_VALUE_PROC : process (command_fsm_curr) is
  begin
    case (command_fsm_curr) is
      when wait_for_cmd       => command_fsm_value <= x"0";
      when build_REG_FIS      => command_fsm_value <= x"1";
      when send_REG_FIS_DW1   => command_fsm_value <= x"2";
      when send_REG_FIS_DW2   => command_fsm_value <= x"3";
      when send_REG_FIS_DW3   => command_fsm_value <= x"4";
      when send_REG_FIS_DW4   => command_fsm_value <= x"5";
      when send_REG_FIS_DW5   => command_fsm_value <= x"6";
      when send_DATA_FIS_HEADER => command_fsm_value <= x"7";
      when send_write_data    => command_fsm_value <= x"8";
      when send_cmd_start     => command_fsm_value <= x"9";
      when wait_for_cmd_start => command_fsm_value <= x"A";
      when wait_for_cmd_done  => command_fsm_value <= x"B";
      when dead               => command_fsm_value <= x"C";
      when others             => command_fsm_value <= x"D";
    end case;
  end process COMMAND_FSM_VALUE_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: COMMAND_FSM_STATE_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  COMMAND_FSM_STATE_PROC: process (clk)
  begin
    if ((clk'event) and (clk = '1')) then
      if (sw_reset = '1') then
        --Initializing internal signals
        command_fsm_curr       <= wait_for_cmd;
        cmd_done_out           <= '0';
        ll_cmd_start_out       <= '0';
        ll_dout_we_out         <= '0'; 
        ll_dout_out            <= (others => '0'); 
        ll_cmd_type_out        <= (others => '0');
        write_data_count       <= (others => '0');
        dword_count            <= (others => '0');
        reg_fis.FIS_type       <= (others => '0');
        reg_fis.pad_8          <= (others => '0');
        reg_fis.command        <= (others => '0');
        reg_fis.features       <= (others => '0');
        reg_fis.LBA            <= (others => '0');
        reg_fis.device         <= (others => '0');
        reg_fis.LBA_exp        <= (others => '0');
        reg_fis.features_exp   <= (others => '0');
        reg_fis.sector_count   <= (others => '0');
        reg_fis.pad_16         <= (others => '0');
        reg_fis.pad_32         <= (others => '0');
      else
        -- Register all Current Signals to their _next Signals
        command_fsm_curr       <= command_fsm_next;
        cmd_done_out           <= cmd_done_next;
        ll_cmd_start_out       <= ll_cmd_start_next;
        ll_dout_we_out         <= ll_dout_we_next; 
        ll_dout_out            <= ll_dout_next; 
        ll_cmd_type_out        <= ll_cmd_type_next;
        dword_count            <= dword_count_next;
        write_data_count       <= write_data_count_next;
        reg_fis.FIS_type       <= reg_fis_next.FIS_type ;
        reg_fis.pad_8          <= reg_fis_next.pad_8;
        reg_fis.command        <= reg_fis_next.command;
        reg_fis.features       <= reg_fis_next.features;
        reg_fis.LBA            <= reg_fis_next.LBA;
        reg_fis.device         <= reg_fis_next.device;
        reg_fis.LBA_exp        <= reg_fis_next.LBA_exp;
        reg_fis.features_exp   <= reg_fis_next.features_exp;
        reg_fis.sector_count   <= reg_fis_next.sector_count;
        reg_fis.pad_16         <= reg_fis_next.pad_16;
        reg_fis.pad_32         <= reg_fis_next.pad_32;
      end if;
    end if;
  end process COMMAND_FSM_STATE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: COMMAND_FSM_LOGIC_PROC 
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  COMMAND_FSM_LOGIC_PROC : process (command_fsm_curr, new_cmd, cmd_type, 
                                   ll_cmd_start_out, ll_dout_we_out,
                                   ll_dout_out, dword_count, write_data_count     
                                   ) is
  begin
    -- Register _next to current signals
    command_fsm_next          <= command_fsm_curr;
    cmd_done_next             <= cmd_done_out;
    ll_cmd_start_next         <= ll_cmd_start_out;
    ll_dout_we_next           <= ll_dout_we_out; 
    ll_dout_next              <= ll_dout_out; 
    ll_cmd_type_next          <= cmd_type;
    user_din_re               <= '0';
    dword_count_next          <= dword_count;
    write_data_count_next     <= write_data_count;
    reg_fis_next.FIS_type     <= reg_fis.FIS_type ;
    reg_fis_next.pad_8        <= reg_fis.pad_8;
    reg_fis_next.command      <= reg_fis.command;
    reg_fis_next.features     <= reg_fis.features;
    reg_fis_next.LBA          <= reg_fis.LBA;
    reg_fis_next.device       <= reg_fis.device;
    reg_fis_next.LBA_exp      <= reg_fis.LBA_exp;
    reg_fis_next.features_exp <= reg_fis.features_exp;
    reg_fis_next.sector_count <= reg_fis.sector_count;
    reg_fis_next.pad_16       <= reg_fis.pad_16;
    reg_fis_next.pad_32       <= reg_fis.pad_32;

    ---------------------------------------------------------------------------
    -- Finite State Machine
    ---------------------------------------------------------------------------
    case (command_fsm_curr) is
      
     -- x0
     when wait_for_cmd =>   
         cmd_done_next     <= '1';
         ll_cmd_start_next    <= '0';
         ll_dout_we_next   <= '0'; 
         ll_dout_next      <= (others => '0'); 
         if (new_cmd = '1') then
            cmd_done_next     <= '0';
            command_fsm_next  <= build_REG_FIS;
         end if;

     -- x1
     when build_REG_FIS =>   
          reg_fis_next.FIS_type      <= REG_FIS_VALUE;
          reg_fis_next.pad_8         <= x"80";
          if (cmd_type = READ_DMA_CMD) then
             reg_fis_next.command    <= READ_DMA;
          else
             reg_fis_next.command    <= WRITE_DMA;
          end if;
          reg_fis_next.features      <= FEATURES;
          reg_fis_next.LBA           <= sector_addr(23 downto 0);
          reg_fis_next.device        <= DEVICE_REG;
          reg_fis_next.LBA_exp       <= (others => '0');
          reg_fis_next.features_exp  <= FEATURES;
          reg_fis_next.sector_count  <= sector_count(15 downto 0);
          reg_fis_next.pad_16        <= (others => '0');
          reg_fis_next.pad_32        <= (others => '0');
          command_fsm_next           <= send_REG_FIS_DW1;

     -- x2
     when send_REG_FIS_DW1 => 
          ll_dout_next         <= reg_fis.FEATURES & reg_fis.command & reg_fis.pad_8 & reg_fis.FIS_type;
          ll_dout_we_next      <= '1';
          command_fsm_next     <= send_REG_FIS_DW2;
   
     -- x3
     when send_REG_FIS_DW2 => 
          ll_dout_next         <= reg_fis.device & reg_fis.LBA;
          ll_dout_we_next      <= '1';
          command_fsm_next     <= send_REG_FIS_DW3;
  
     -- x4
     when send_REG_FIS_DW3 => 
          ll_dout_next         <= reg_fis.features_exp & reg_fis.LBA_exp;
          ll_dout_we_next      <= '1';
          command_fsm_next     <= send_REG_FIS_DW4;
     
     -- x5
     when send_REG_FIS_DW4 => 
          ll_dout_next         <= reg_fis.pad_16 & reg_fis.sector_count ;
          ll_dout_we_next      <= '1';
          command_fsm_next     <= send_REG_FIS_DW5;
     
     -- x6
     when send_REG_FIS_DW5 => 
          ll_dout_next         <= reg_fis.pad_32;
          ll_dout_we_next      <= '1';
          command_fsm_next  <= send_cmd_start;

     -- x7
     when send_DATA_FIS_HEADER =>
          if (user_fifo_full = '1') then
             ll_dout_next         <= DATA_FIS_HEADER;
             ll_dout_we_next      <= '1';
             command_fsm_next     <= send_write_data;
          end if;

     -- x8
     when send_write_data =>
          if(dword_count >= NDWORDS_PER_DATA_FIS) then
            user_din_re        <= '0';
            ll_dout_we_next    <= '0'; 
            ll_dout_next       <= (others => '0');
            dword_count_next   <= (others => '0');
            command_fsm_next   <= send_DATA_FIS_HEADER;
          elsif (write_fifo_full = '1' or user_fifo_empty = '1') then
            user_din_re        <= '0';
            ll_dout_we_next    <= '0'; 
            ll_dout_next       <= (others => '0');
          else 
            write_data_count_next <= write_data_count + 1;
            dword_count_next   <= dword_count + 1;
            user_din_re        <= '1'; 
            ll_dout_next       <= user_din;
            ll_dout_we_next    <= '1';
          end if;

          if (write_data_count = (SECTOR_NDWORDS*sector_count_int)) then
             write_data_count_next <= (others => '0');
             dword_count_next   <= (others => '0');
             user_din_re        <= '0';
             ll_dout_we_next    <= '0'; 
             ll_dout_next       <= (others => '0');
             command_fsm_next   <= wait_for_cmd_done;
          end if;
 
     -- x9
     when send_cmd_start =>
          ll_dout_we_next   <= '0'; 
          ll_dout_next      <= (others => '0'); 
          if (ll_ready_for_cmd = '1') then
            ll_cmd_start_next           <= '1';
            command_fsm_next         <= wait_for_cmd_start;
          end if;

     -- xA
     when wait_for_cmd_start =>
          ll_cmd_start_next           <= '0';
          if (ll_ready_for_cmd = '0') then
             if (cmd_type = READ_DMA_CMD) then
               command_fsm_next   <= wait_for_cmd_done;
             else
               command_fsm_next   <= send_DATA_FIS_HEADER;
             end if;
          end if;

     -- xB
     when wait_for_cmd_done =>
          if (ll_ready_for_cmd = '1') then
             cmd_done_next     <= '1';
             command_fsm_next      <= wait_for_cmd;
          end if;
 
     -- xC
     when dead =>   
         command_fsm_next  <= dead;

     -- xD
     when others =>   
         command_fsm_next  <= dead;

   end case;
 end process COMMAND_FSM_LOGIC_PROC;

  cmd_done         <= cmd_done_out;
  ll_cmd_start     <= ll_cmd_start_out;
  ll_cmd_type      <= ll_cmd_type_out;

  user_din_re_out  <= user_din_re;
  user_dout_ila    <= ll_din;
  user_dout        <= user_dout_ila;
  ll_dout          <= ll_dout_out;
  ll_dout_we       <= ll_dout_we_out;
  ll_din_re_ila    <= user_dout_re;
  ll_din_re        <= ll_din_re_ila;

  sector_count_int <= conv_integer(sector_count);

  -----------------------------------------------------------------------------
  -- PROCESS: TIMER PROCESS 
  -- PURPOSE: Count time to read a sector
  -----------------------------------------------------------------------------
  TIMER_PROC: process (clk)
  begin
    if ((clk'event) and (clk = '1')) then
      if (sw_reset = '1') then
        sector_timer    <= (others => '0');
     --   sata_timer      <= (others => '0');
      --elsif ((command_fsm_curr = wait_for_cmd_done) and (ready_for_cmd = '1')) then
        --sata_timer      <= sata_timer + sector_timer;
      elsif (command_fsm_curr = wait_for_cmd) then
        if (new_cmd = '1') then
           sector_timer    <= (others => '0');
        else
           sector_timer    <= sector_timer;
        end if;
      else
        sector_timer    <= sector_timer + '1';
      end if;
    end if;
  end process TIMER_PROC;
  sector_timer_out        <= sector_timer;


 chipscope_gen_ila : if (CHIPSCOPE) generate
  CMD_LAYER_ILA_i : cmd_layer_ila
    port map (
      control  => cmd_layer_ila_control,
      clk      => clk,
      trig0    => command_fsm_value,
      trig1    => user_din,
      trig2    => user_dout_ila,
      trig3    => ll_din,
      trig4    => ll_dout_out,
      trig5    => cmd_type,
      trig6    => ll_cmd_type_out,
      trig7    => sector_timer,
      trig8    => sector_addr,
      trig9    => reg_fis.LBA,
      trig10    => reg_fis.sector_count,
      trig11(0) => new_cmd,
      trig11(1) => user_din_re,
      trig11(2) => user_dout_re,
      trig11(3) => ll_ready_for_cmd,
      trig11(4) => ll_cmd_start_out,
      trig11(5) => ll_dout_we_out, 
      trig11(6) => ll_din_re_ila,
      trig11(7) => cmd_done_out, 
      trig11(8) => '0',
      trig11(9) => write_fifo_full,
      trig11(10) => user_fifo_empty,
      trig11(11) => user_fifo_full,
      trig12    => dword_count,
      trig13    => write_data_count
     ); 
 end generate chipscope_gen_ila; 
 
end BEHAV;
