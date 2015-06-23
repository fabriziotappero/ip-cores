-------------------------------------------------------------------------------
-- Title      : I2C bus wrapper
-- Project    : 
-------------------------------------------------------------------------------
-- File       : i2c_bus_wrap.vhd
-- Author     : Wojciech M. Zabolotny wzab01<at>gmail.com
-- License    : PUBLIC DOMAIN
-- Company    : 
-- Created    : 2015-05-05
-- Last update: 2015-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-05  1.0      xl	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity i2c_bus_wrap is

  port (
    -- System interface
    din    : in  std_logic_vector(7 downto 0);   -- input data
    dout   : out std_logic_vector(7 downto 0);   -- output data
    addr   : in  std_logic_vector(2 downto 0);   -- address
    rd_nwr : in  std_logic;
    cs     : in  std_logic;             -- address decoder output, active '1'
    clk    : in  std_logic;
    rst    : in  std_logic;
    i2c_rst    : in  std_logic;
    -- Interfejs I2C
    scl_i  : in  std_logic;
    scl_o  : out std_logic;
    sda_i  : in  std_logic;
    sda_o  : out std_logic
    );
end;  -- entity i2c_bus_wrap;

architecture i2c_beh of i2c_bus_wrap is

  component i2c_master_top
    generic(
      ARST_LVL : std_logic              -- asynchronous reset level
      );
    port (
      -- wishbone signals
      wb_clk_i  : in  std_logic;        -- master clock input
      wb_rst_i  : in  std_logic;        -- synchronous active high reset
      arst_i    : in  std_logic;        -- asynchronous reset
      wb_adr_i  : in  unsigned(2 downto 0);          -- lower address bits
      wb_dat_i  : in  std_logic_vector(7 downto 0);  -- Databus input
      wb_dat_o  : out std_logic_vector(7 downto 0);  -- Databus output
      wb_we_i   : in  std_logic;        -- Write enable input
      wb_stb_i  : in  std_logic;        -- Strobe signals / core select signal
      wb_cyc_i  : in  std_logic;        -- Valid bus cycle input
      wb_ack_o  : out std_logic;        -- Bus cycle acknowledge output
      wb_inta_o : out std_logic;        -- interrupt request output signal

      -- i2c lines
      scl_pad_i    : in  std_logic;     -- i2c clock line input
      scl_pad_o    : out std_logic;     -- i2c clock line output
      scl_padoen_o : out std_logic;  -- i2c clock line output enable, active low
      sda_pad_i    : in  std_logic;     -- i2c data line input
      sda_pad_o    : out std_logic;     -- i2c data line output
      sda_padoen_o : out std_logic   -- i2c data line output enable, active low
      );
  end component;  -- i2c_master_top;

  -- Additional signals used to control I2C pins
  signal s_scl_pad_i, s_scl_pad_o, s_scl_padoen_o                                                     : std_logic;
  signal s_sda_pad_i, s_sda_pad_o, s_sda_padoen_o                                                     : std_logic;
  -- Additional signals for WISHBONE interface
  signal s_wb_clk_i, s_wb_rst_i, s_arst_i, s_wb_we_i, s_wb_stb_i, s_wb_cyc_i, s_wb_ack_o, s_wb_inta_o : std_logic;
  signal s_wb_dat_i, s_wb_dat_o                                                                       : std_logic_vector(7 downto 0);
  signal s_wb_adr_i                                                                                   : unsigned(2 downto 0);
  signal s_rd_nwr, s_cs                                                                               : std_logic;
  signal s_rd_nwr2, s_cs2                                                                             : std_logic;
  --signal rst : std_logic;

  type stan_ci2c is (INIT, WR_WAIT_INIT, INIT1, WR_WAIT_INIT1,
                     INIT2, WR_WAIT_INIT2, INIT3, WR_WAIT_INIT3,
                     IDLE, WR_WAIT, WR_END, RD_WAIT, RD_END);
  signal stan : stan_ci2c;
begin  --i2c_master_top


  c_i2c : i2c_master_top
    generic map (
      ARST_LVL => '0')
    port map (
      -- WISHBONE interface
      wb_clk_i     => s_wb_clk_i,
      wb_rst_i     => s_wb_rst_i,
      arst_i       => s_arst_i,
      wb_we_i      => s_wb_we_i,
      wb_stb_i     => s_wb_stb_i,
      wb_cyc_i     => s_wb_cyc_i,
      wb_ack_o     => s_wb_ack_o,
      wb_inta_o    => s_wb_inta_o,
      wb_dat_i     => s_wb_dat_i,
      wb_dat_o     => s_wb_dat_o,
      wb_adr_i     => s_wb_adr_i,
      -- I2C interface
      scl_pad_i    => s_scl_pad_i,
      scl_pad_o    => s_scl_pad_o,
      scl_padoen_o => s_scl_padoen_o,
      sda_pad_i    => s_sda_pad_i,
      sda_pad_o    => s_sda_pad_o,
      sda_padoen_o => s_sda_padoen_o);

  -- Conversion WISHBON -> our standard
  -- Output-> active '0', inactive '1' ('H')
  s_scl_pad_i <= scl_i;
  s_sda_pad_i <= sda_i;
  --s_scl_pad_i <= '0' when (s_scl_pad_o = '0' and s_scl_padoen_o = '0') else '1';
  --s_sda_pad_i <= '0' when (s_sda_pad_o = '0' and s_sda_padoen_o = '0') else '1';
  scl_o       <= '0' when (s_scl_pad_o = '0' and s_scl_padoen_o = '0') else '1';
  sda_o       <= '0' when (s_sda_pad_o = '0' and s_sda_padoen_o = '0') else '1';

  -- Timing conversion: CCU -> WISHBONE
  s_wb_clk_i <= clk;
  s_wb_rst_i <= '0';
  s_arst_i   <= i2c_rst;
  s_wb_adr_i <= unsigned(addr);
  -- Write cycle
  -- When we detect WR (nCS=0, RD_nWR=0 & proper address), we initialize
  -- the WISHBONE write cycle
  -- It is a sequential process, activated with clk signal
  p1 : process (clk, rst)
  begin  -- process p1
    if rst = '0' then                   -- asynchronous reset (active low)
      s_wb_cyc_i <= '0';
      s_wb_stb_i <= '0';
      stan       <= IDLE;
      s_cs       <= '0';
      s_rd_nwr   <= '0';
      s_cs2      <= '0';
      s_rd_nwr2  <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      s_cs2     <= cs;
      s_rd_nwr2 <= rd_nwr;
      s_cs      <= s_cs2;
      s_rd_nwr  <= s_rd_nwr2;
      case stan is
        when IDLE =>
          s_wb_dat_i <= din;
          -- detection of begining of the write cycle
          if s_rd_nwr = '0' and s_cs = '1' then
            -- Set the write signals and wait for write
            s_wb_cyc_i <= '1';
            s_wb_stb_i <= '1';
            s_wb_we_i  <= '1';
            stan       <= WR_WAIT;
          elsif s_rd_nwr = '1' and s_cs = '1' then
            -- Set the read signals and wait for read
            s_wb_cyc_i <= '1';
            s_wb_stb_i <= '1';
            s_wb_we_i  <= '0';
            stan       <= RD_WAIT;
          end if;
        when WR_WAIT =>
          -- wait for wb_ack_o = '1'
          if s_wb_ack_o = '1' then
            s_wb_cyc_i <= '0';
            s_wb_stb_i <= '0';
            s_wb_we_i  <= '0';
            stan       <= WR_END;
          end if;
        when WR_END =>                  -- end of write cycle, wait for s_cs=0
          if s_cs = '0' then
            stan <= IDLE;
          end if;
        when RD_WAIT =>
          -- read cycle, wait for wb_ack_o = '1' 
          if s_wb_ack_o = '1' then
            s_wb_cyc_i <= '0';
            s_wb_stb_i <= '0';
            s_wb_we_i  <= '0';
            dout       <= s_wb_dat_o;
            stan       <= RD_END;
          end if;
        when RD_END =>                  -- end of read cycle, wait for s_cs='0'
          if s_cs = '0' then
            stan <= IDLE;
          end if;
        when others => null;
      end case;
    end if;
  end process p1;
end i2c_beh;
