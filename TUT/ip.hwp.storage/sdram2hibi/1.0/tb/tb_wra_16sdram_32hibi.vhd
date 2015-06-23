-------------------------------------------------------------------------------
-- Title      : Synthesizable Testbench for 16-bit sdram <-> 32-bit hibi wra
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_wra_16sdram_32hibi.vhd
-- Author     :   <alhonena@AHVEN>
-- Company    : 
-- Created    : 2012-01-26
-- Last update: 2012-01-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Doesn't use hibi or sdram2hibi, just tests the 16-bit<->32-bit
-- adapter wrapper using the bare 16-bit sdram controller and simple 32-bit
-- test case generated here.
--
-- Currently uses DE2 board. If you find a reliably working simulation model
-- for the DE2 sdram, feel free to use it instead... I play it safe and use
-- the real chip & SignalTap.
--
-- Copied the good&old DE2 sdram controller tester - changed it to use 32-bit
-- data and added the adapter wrapper.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 TUT
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-01-26  1.0      alhonena	Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Title      : SDRAM TEST.
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sdram_test.vhd
-- Author     :   <alhonena@BUMMALO>
-- Company    : 
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Quick test for SDRAM controller; writes 4 words to SDRAM, reads
-- them back and verifies the contents. The 3rd word is configured by external
-- switches so you can verify that the verification works :-).
--
-- Just for an experiment, I implemented the FSM as an integer counter.
-- It looks much nicer in SignalTap I primarily used to verify the operation.
-- LEDR shows the progress, LEDG shows error status.
-- LEDG(0) -> data came too early from the ctrl.
-- LEDG(1...4) -> data mismatch.
-- LEDG(5) -> extra data from the ctrl.
-- LEDR(0) -> Gave write command.
-- LEDR(1) -> Gave read command.
-- LEDR(10...13) -> data words succesfully read.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/13  1.0      alhonena	Created
-- 2011/07/16  2.0      alhonena        Continued.
-- 2011/10/09  2.1      alhonena        Updated coding conventions & comments.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_wra_16sdram_32hibi is
  
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    
    SW    : in  std_logic_vector(15 downto 0);
    LEDR : out std_logic_vector(17 downto 0);
    LEDG : out std_logic_vector(8 downto 0);

    sdram_data_inout       : inout std_logic_vector(15 downto 0);
    sdram_cke_out          : out   std_logic;
    sdram_cs_n_out         : out   std_logic;
    sdram_we_n_out         : out   std_logic;
    sdram_ras_n_out        : out   std_logic;
    sdram_cas_n_out        : out   std_logic;
    sdram_dqm_out          : out   std_logic_vector(1 downto 0);
    sdram_ba_out           : out   std_logic_vector(1 downto 0);
    sdram_address_out      : out   std_logic_vector(11 downto 0);
    sdram_clk              : out   std_logic
    );

end tb_wra_16sdram_32hibi;

architecture rtl of tb_wra_16sdram_32hibi is

  component sdram_controller
    generic (
      clk_freq_mhz_g      : integer;
      mem_addr_width_g    : integer;
      amountw_g           : integer;
      block_read_length_g : integer;
      sim_ena_g           : integer);
    port (
      clk                    : in    std_logic;
      rst_n                  : in    std_logic;
      command_in             : in    std_logic_vector(1 downto 0);
      address_in             : in    std_logic_vector(mem_addr_width_g-1 downto 0);
      data_amount_in         : in    std_logic_vector(amountw_g - 1
                                                    downto 0);
      byte_select_in         : in    std_logic_vector(1 downto 0);
      input_empty_in         : in    std_logic;
      input_one_d_in         : in    std_logic;
      output_full_in         : in    std_logic;
      data_in                : in    std_logic_vector(15 downto 0);
      write_on_out           : out   std_logic;
      busy_out               : out   std_logic;
      output_we_out          : out   std_logic;
      input_re_out           : out   std_logic;
      data_out               : out   std_logic_vector(15 downto 0);
      sdram_data_inout       : inout std_logic_vector(15 downto 0);
      sdram_cke_out          : out   std_logic;
      sdram_cs_n_out         : out   std_logic;
      sdram_we_n_out         : out   std_logic;
      sdram_ras_n_out        : out   std_logic;
      sdram_cas_n_out        : out   std_logic;
      sdram_dqm_out          : out   std_logic_vector(1 downto 0);
      sdram_ba_out           : out   std_logic_vector(1 downto 0);
      sdram_address_out      : out   std_logic_vector(11 downto 0));
  end component;

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  component wra_16sdram_32hibi
    generic (
      mem_addr_width_g : integer);
    port (
      clk                       : in  std_logic;
      rst_n                     : in  std_logic;
      sdram2hibi_write_on_out   : out std_logic;
      sdram2hibi_comm_in        : in  std_logic_vector(1 downto 0);
      sdram2hibi_addr_in        : in  std_logic_vector(21 downto 0);
      sdram2hibi_data_amount_in : in  std_logic_vector(mem_addr_width_g-1 downto 0);
      sdram2hibi_input_one_d_in : in  std_logic;
      sdram2hibi_input_empty_in : in  std_logic;
      sdram2hibi_output_full_in : in  std_logic;
      sdram2hibi_busy_out       : out std_logic;
      sdram2hibi_re_out         : out std_logic;
      sdram2hibi_we_out         : out std_logic;
      sdram2hibi_data_in        : in  std_logic_vector(31 downto 0);
      sdram2hibi_data_out       : out std_logic_vector(31 downto 0);
      ctrl_command_out          : out std_logic_vector(1 downto 0);
      ctrl_address_out          : out std_logic_vector(21 downto 0);
      ctrl_data_amount_out      : out std_logic_vector(mem_addr_width_g-1 downto 0);
      ctrl_byte_select_out      : out std_logic_vector(1 downto 0);
      ctrl_input_empty_out      : out std_logic;
      ctrl_input_one_d_out      : out std_logic;
      ctrl_output_full_out      : out std_logic;
      ctrl_data_out             : out std_logic_vector(15 downto 0);
      ctrl_write_on_in          : in  std_logic;
      ctrl_busy_in              : in  std_logic;
      ctrl_output_we_in         : in  std_logic;
      ctrl_input_re_in          : in  std_logic;
      ctrl_data_in              : in  std_logic_vector(15 downto 0));
  end component;
  
  signal fifo_to_sdram_one_d : std_logic;
  signal fifo_to_sdram_empty : std_logic;
  signal fifo_to_sdram_re : std_logic;
  signal fifo_to_sdram_data : std_logic_vector(31 downto 0);
  signal fifo_from_sdram_data : std_logic_vector(31 downto 0);
  signal fifo_from_sdram_we : std_logic;
  signal fifo_from_sdram_full : std_logic;

  signal data_to_write_r : std_logic_vector(31 downto 0);
  signal we_r : std_logic;
  signal fifo_full : std_logic;

  signal data_to_read : std_logic_vector(31 downto 0);
  signal re_r : std_logic;
  signal empty_from_fifo : std_logic;

  signal state_r : integer range 0 to 15;

  signal read_cnt_r : integer range 0 to 7;

  signal command_to_sdram_ctrl : std_logic_vector(1 downto 0);
  signal address_to_sdram_ctrl : std_logic_vector(21 downto 0);
  signal data_amount_to_sdram_ctrl : std_logic_vector(21 downto 0);

  signal write_on, busy : std_logic;

  signal    ctrl_command_out          :  std_logic_vector(1 downto 0);
  signal    ctrl_address_out          :  std_logic_vector(21 downto 0);
  signal    ctrl_data_amount_out      :  std_logic_vector(21 downto 0);
  signal    ctrl_byte_select_out      :  std_logic_vector(1 downto 0);
  signal    ctrl_input_empty_out      :  std_logic;
  signal    ctrl_input_one_d_out      :  std_logic;
  signal    ctrl_output_full_out      :  std_logic;
  signal    ctrl_data_out             :  std_logic_vector(15 downto 0);
  signal    ctrl_write_on_in          :  std_logic;
  signal    ctrl_busy_in              :  std_logic;
  signal    ctrl_output_we_in         :  std_logic;
  signal    ctrl_input_re_in          :  std_logic;
  signal    ctrl_data_in              :  std_logic_vector(15 downto 0);


  
begin  -- rtl

  sdram_clk <= clk;
  
  sdram_controller_1: sdram_controller
    generic map (
        clk_freq_mhz_g      => 50,
        mem_addr_width_g    => 22,
        amountw_g           => 22,
        block_read_length_g => 123,
        sim_ena_g           => 0)
    port map (
        clk                    => clk,
        rst_n                  => rst_n,
        command_in             => ctrl_command_out,
        address_in             => ctrl_address_out,
        data_amount_in         => ctrl_data_amount_out,
        byte_select_in         => ctrl_byte_select_out,
        input_empty_in         => ctrl_input_empty_out,
        input_one_d_in         => ctrl_input_one_d_out,
        output_full_in         => ctrl_output_full_out,
        data_in                => ctrl_data_out,
        write_on_out           => ctrl_write_on_in,
        busy_out               => ctrl_busy_in,
        output_we_out          => ctrl_output_we_in,
        input_re_out           => ctrl_input_re_in,
        data_out               => ctrl_data_in,
        sdram_data_inout       => sdram_data_inout,
        sdram_cke_out          => sdram_cke_out,
        sdram_cs_n_out         => sdram_cs_n_out,
        sdram_we_n_out         => sdram_we_n_out,
        sdram_ras_n_out        => sdram_ras_n_out,
        sdram_cas_n_out        => sdram_cas_n_out,
        sdram_dqm_out          => sdram_dqm_out,
        sdram_ba_out           => sdram_ba_out,
        sdram_address_out      => sdram_address_out);

  -- The DUT:
  wra_16sdram_32hibi_1: wra_16sdram_32hibi
    generic map (
      mem_addr_width_g => 22)
    port map (
      clk                       => clk,
      rst_n                     => rst_n,
      -- connected to the test case (that is, fifos):
      sdram2hibi_write_on_out   => write_on, 
      sdram2hibi_comm_in        => command_to_sdram_ctrl, 
      sdram2hibi_addr_in        => address_to_sdram_ctrl,
      sdram2hibi_data_amount_in => data_amount_to_sdram_ctrl,
      sdram2hibi_input_one_d_in => fifo_to_sdram_one_d,
      sdram2hibi_input_empty_in => fifo_to_sdram_empty,
      sdram2hibi_output_full_in => fifo_from_sdram_full,
      sdram2hibi_busy_out       => busy,
      sdram2hibi_re_out         => fifo_to_sdram_re,
      sdram2hibi_we_out         => fifo_from_sdram_we,
      sdram2hibi_data_in        => fifo_to_sdram_data,
      sdram2hibi_data_out       => fifo_from_sdram_data,
      -- connected directly to the sdram controller:
      ctrl_command_out          => ctrl_command_out,
      ctrl_address_out          => ctrl_address_out,
      ctrl_data_amount_out      => ctrl_data_amount_out,
      ctrl_byte_select_out      => ctrl_byte_select_out,
      ctrl_input_empty_out      => ctrl_input_empty_out,
      ctrl_input_one_d_out      => ctrl_input_one_d_out,
      ctrl_output_full_out      => ctrl_output_full_out,
      ctrl_data_out             => ctrl_data_out,
      ctrl_write_on_in          => ctrl_write_on_in,
      ctrl_busy_in              => ctrl_busy_in,
      ctrl_output_we_in         => ctrl_output_we_in,
      ctrl_input_re_in          => ctrl_input_re_in,
      ctrl_data_in              => ctrl_data_in);
  
  fifo_to_sdram: fifo
    generic map (
        data_width_g => 32,
        depth_g      => 8)
    port map (
        clk       => clk,
        rst_n     => rst_n,
        data_in   => data_to_write_r,
        we_in     => we_r,
        full_out  => fifo_full,
        one_p_out => open,
        re_in     => fifo_to_sdram_re,
        data_out  => fifo_to_sdram_data,
        empty_out => fifo_to_sdram_empty,
        one_d_out => fifo_to_sdram_one_d);

  fifo_from_sdram: fifo
    generic map (
        data_width_g => 32,
        depth_g      => 8)
    port map (
        clk       => clk,
        rst_n     => rst_n,
        data_in   => fifo_from_sdram_data,
        we_in     => fifo_from_sdram_we,
        full_out  => fifo_from_sdram_full,
        one_p_out => open,
        re_in     => re_r,
        data_out  => data_to_read,
        empty_out => empty_from_fifo,
        one_d_out => open);
  
  tester: process (clk, rst_n)
  begin  -- process tester
    if rst_n = '0' then                 -- asynchronous reset (active low)

      state_r <= 0;
      read_cnt_r <= 0;

      command_to_sdram_ctrl <= "00";

      LEDR <= (others => '0');
      LEDG <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Wait for initialization.
      if state_r = 0 and busy = '0' then
        state_r <= 1;
      end if;

      if state_r = 1 then
        data_to_write_r <= x"1234ABCD";
        we_r <= '1';
        state_r <= 2;
      end if;

      if state_r = 2 then
        data_to_write_r <= x"5678EFAB";
        we_r <= '1';
        state_r <= 3;
      end if;      

      if state_r = 3 then
        data_to_write_r <= x"3210" & SW;
        we_r <= '1';
        state_r <= 4;
      end if;

      if state_r = 4 then
        data_to_write_r <= x"01239ABC";
        we_r <= '1';
        state_r <= 5;
      end if;

      if state_r = 5 then
        we_r <= '0';
        command_to_sdram_ctrl <= "10";  -- WRITE COMMAND.
        address_to_sdram_ctrl <= "0000000000010011010010";  -- just a test address.
        data_amount_to_sdram_ctrl <= std_logic_vector(to_unsigned(4, 22));  -- Write four.
        state_r <= 6;
        LEDR(0) <= '1';
      end if;

      if state_r = 6 then
        command_to_sdram_ctrl <= "00";
        if busy = '0' then
          state_r <= 7;
        end if;
      end if;

      if state_r = 7 then
        command_to_sdram_ctrl <= "00";
        if busy = '0' then
          state_r <= 8;
        end if;
      end if;

      if state_r = 8 then
        command_to_sdram_ctrl <= "00";
        if busy = '0' then
          state_r <= 9;
        end if;
      end if;      

      if state_r = 9 then
        if busy = '0' then
          command_to_sdram_ctrl <= "01";  -- READ COMMAND.
          address_to_sdram_ctrl <= "0000000000010011010010";
          data_amount_to_sdram_ctrl <= std_logic_vector(to_unsigned(4, 22));
          state_r <= 10;
          LEDR(1) <= '1';
        end if;
        
      end if;

      if state_r = 10 then
        command_to_sdram_ctrl <= "00";
        state_r <= 11;
      end if;

      if empty_from_fifo = '0' and state_r < 10 then
        -- Error led: SDRAM controller gave data before it was asked for.
        LEDG(0) <= '1';
      end if;

      re_r <= '0';

      if empty_from_fifo = '0' and re_r = '0' then
        read_cnt_r <= read_cnt_r + 1;
        LEDR(read_cnt_r + 10) <= '1';
        re_r <= '1';
        case read_cnt_r is
          when 0 => if data_to_read /= x"1234ABCD" then
                       LEDG(1) <= '1';
                     end if;
          when 1 => if data_to_read /= x"5678EFAB" then
                       LEDG(2) <= '1';
                     end if;
          when 2 => if data_to_read /= x"3210" & "0101010101010101" then
                       LEDG(3) <= '1';
                     end if;
          when 3 => if data_to_read /= x"01239ABC" then
                       LEDG(4) <= '1';
                     end if;
          when 4 => LEDG(5) <= '1';  -- Too much data came from the ctrl.

          when others => null;
        end case;
      end if;


    end if;
  end process tester;

end rtl;
