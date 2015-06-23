--
-- Copyright (C) 2006 Johannes Hausensteiner (johannes.hausensteiner@pcl.at)
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--
-- 
-- Filename: spi_ctrl.vhd
--
-- Function: SPI Flash controller for DIY Calculator
-- 
--
-- Changelog
--
--  0.1  25.Sep.2006   JH   new
--  0.2  15.Nov.2006   JH   remove old code
--  1.0   5.Feb.2007   JH   new clocking scheme
--  1.1   4.Apr.2007   JH   implement high address byte
--  1.2  16.Apr.2007   JH   clock enable
--  1.3  23.Apr.2007   JH   remove all asynchronous elements
--  1.4   4.May 2007   JH   resolve read timing
--  1.5  10.May 2007   JH   remove read signal
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi_ctrl is
  port (
    clk_in   : in std_logic;
    rst      : in std_logic;
    spi_clk  : out std_logic;
    spi_cs   : out std_logic;
    spi_din  : in std_logic;
    spi_dout : out std_logic;
    sel      : in std_logic;
    wr       : in std_logic;
    addr     : in std_logic_vector (2 downto 0);
    d_in     : in std_logic_vector (7 downto 0);
    d_out    : out std_logic_vector (7 downto 0)
  );
end spi_ctrl;

architecture rtl of spi_ctrl is
  -- clock generator
  constant SYS_FREQ  : integer :=  25000000;  -- 25MHz
  constant SPI_FREQ  : integer :=   6250000;  -- 6.25MHz
  signal clk_en : std_logic;
  signal clk_cnt : integer range 0 to (SYS_FREQ/SPI_FREQ)-1;

  type state_t is (
    IDLE, TxCMD, TxADD_H, TxADD_M, TxADD_L, TxDUMMY, TxDATA, RxDATA,
    WAIT1, WAIT2, WAIT3, WAIT4, WAIT6, WAIT5, WAIT7, WAIT8, CLR_CMD);
  signal state, next_state : state_t;

  -- transmitter
  signal tx_reg, tx_sreg : std_logic_vector (7 downto 0);
  signal tx_empty, tx_empty_set : std_logic;
  signal tx_bit_cnt : std_logic_vector (3 downto 0);

  -- receiver
  signal rx_sreg : std_logic_vector (7 downto 0);
  signal rx_ready, rx_ready_set, rx_bit_cnt_clr : std_logic;
  signal rx_bit_cnt : std_logic_vector (3 downto 0);

  signal wr_cmd, wr_data, wr_add_h, wr_add_m, wr_add_l : std_logic;
  signal rd_stat, rd_add_h, rd_add_m, rd_add_l : std_logic;
  signal rd_data, rd_data1, rd_data2 : std_logic;
  signal spi_cs_int, spi_clk_int : std_logic;

  -- auxiliary signals
  signal rx_enable, rx_empty, rx_empty_clr : std_logic;
  signal tx_enable, tx_enable_d : std_logic;
  signal tx_new_data, tx_new_data_clr, is_tx_data, is_wait6 : std_logic;
  signal cmd_clr, busy : std_logic;

  -- registers
  signal cmd, tx_data, rx_data : std_logic_vector (7 downto 0);
  signal add_h, add_m, add_l : std_logic_vector (7 downto 0);
  
  -- FLASH commands
  constant NOP  : std_logic_vector (7 downto 0) := x"FF";  -- no cmd to execute
  constant WREN : std_logic_vector (7 downto 0) := x"06";  -- write enable
  constant WRDI : std_logic_vector (7 downto 0) := x"04";  -- write disable
  constant RDSR : std_logic_vector (7 downto 0) := x"05";  -- read status reg
  constant WRSR : std_logic_vector (7 downto 0) := x"01";  -- write stat. reg
  constant RDCMD: std_logic_vector (7 downto 0) := x"03";  -- read data
  constant F_RD : std_logic_vector (7 downto 0) := x"0B";  -- fast read data
  constant PP :   std_logic_vector (7 downto 0) := x"02";  -- page program
  constant SE :   std_logic_vector (7 downto 0) := x"D8";  -- sector erase
  constant BE :   std_logic_vector (7 downto 0) := x"C7";  -- bulk erase
  constant DP :   std_logic_vector (7 downto 0) := x"B9";  -- deep power down
  constant RES :  std_logic_vector (7 downto 0) := x"AB";  -- read signature
begin
  -- assign signals
  spi_cs <= spi_cs_int;
  spi_clk <= spi_clk_int;
  spi_dout <= tx_sreg(7);

  -- clock generator
  spi_divider : process (rst, clk_in)
    begin
    if rst = '1' then
      clk_cnt <= 0;
      clk_en <= '0';
      spi_clk_int <= '1';
    elsif falling_edge (clk_in) then
      if clk_cnt = ((SYS_FREQ / SPI_FREQ) - 2) or
         clk_cnt = ((SYS_FREQ / SPI_FREQ) - 3) then
        clk_cnt <= clk_cnt + 1;
        clk_en <= '0';
        if tx_enable = '1' or rx_enable = '1' then
          spi_clk_int <= '0';
        else
          spi_clk_int <= '1';
        end if;
      elsif clk_cnt = ((SYS_FREQ / SPI_FREQ) - 1) then
        clk_cnt <= 0;
        clk_en <= '1';
        spi_clk_int <= '1';
      else
        clk_cnt <= clk_cnt + 1;
        clk_en <= '0';
        spi_clk_int <= '1';
      end if;
    end if;
  end process;

  -- address decoder
  process (sel, addr, wr)
    variable input : std_logic_vector (4 downto 0);
  begin
    input := sel & addr & wr;
    -- defaults
    wr_data <= '0';
    wr_cmd <= '0';
    wr_add_h <= '0';
    wr_add_m <= '0';
    wr_add_l <= '0';
    rd_data <= '0';
    rd_stat <= '0';
    rd_add_h <= '0';
    rd_add_m <= '0';
    rd_add_l <= '0';
    case input is
      when "10000" => rd_data  <= '1';
      when "10001" => wr_data  <= '1';
      when "10010" => rd_stat  <= '1';
      when "10011" => wr_cmd   <= '1';
      when "10100" => rd_add_l <= '1';
      when "10101" => wr_add_l <= '1';
      when "10110" => rd_add_m <= '1';
      when "10111" => wr_add_m <= '1';
      when "11000" => rd_add_h <= '1';
      when "11001" => wr_add_h <= '1';
      when others => null;
    end case;
  end process;

  -- read back registers
  d_out(0) <=    (rx_data(0) and rd_data)
              or (busy       and rd_stat)
              or (add_h(0)   and rd_add_h)
              or (add_m(0)   and rd_add_m)
              or (add_l(0)   and rd_add_l);

  d_out(1) <=    (rx_data(1) and rd_data)
              or (tx_empty   and rd_stat)
              or (add_h(1)   and rd_add_h)
              or (add_m(1)   and rd_add_m)
              or (add_l(1)   and rd_add_l);

  d_out(2) <=    (rx_data(2) and rd_data)
              or (rx_ready   and rd_stat)
              or (add_h(2)   and rd_add_h)
              or (add_m(2)   and rd_add_m)
              or (add_l(2)   and rd_add_l);

  d_out(3) <=    (rx_data(3) and rd_data)
              or (is_wait6   and rd_stat)
              or (add_h(3)   and rd_add_h)
              or (add_m(3)   and rd_add_m)
              or (add_l(3)   and rd_add_l);

  d_out(4) <=    (rx_data(4) and rd_data)
              or ('0'        and rd_stat)
              or (add_h(4)   and rd_add_h)
              or (add_m(4)   and rd_add_m)
              or (add_l(4)   and rd_add_l);

  d_out(5) <=    (rx_data(5) and rd_data)
              or ('0'        and rd_stat)
              or (add_h(5)   and rd_add_h)
              or (add_m(5)   and rd_add_m)
              or (add_l(5)   and rd_add_l);

  d_out(6) <=    (rx_data(6) and rd_data)
              or ('0'        and rd_stat)
              or (add_h(6)   and rd_add_h)
              or (add_m(6)   and rd_add_m)
              or (add_l(6)   and rd_add_l);

  d_out(7) <=    (rx_data(7) and rd_data)
              or ('0'        and rd_stat)
              or (add_h(7)   and rd_add_h)
              or (add_m(7)   and rd_add_m)
              or (add_l(7)   and rd_add_l);

  -- write command register
  process (rst, cmd_clr, clk_in)
  begin
    if rst = '1' or cmd_clr = '1' then
      cmd <= NOP;
    elsif rising_edge (clk_in) then
      if wr_cmd = '1' then
        cmd <= d_in;
      end if;
    end if;
  end process;

  -- write address high register
  process (rst, clk_in)
  begin
    if rst = '1' then
      add_h <= x"00";
    elsif rising_edge (clk_in) then
      if wr_add_h = '1' then
        add_h <= d_in;
      end if;
    end if;
  end process;

  -- write address mid register
  process (rst, clk_in)
  begin
    if rst = '1' then
      add_m <= x"00";
    elsif rising_edge (clk_in) then
      if wr_add_m ='1' then
        add_m <= d_in;
      end if;
    end if;
  end process;

  -- write address low register
  process (rst, clk_in)
  begin
    if rst = '1' then
      add_l <= x"00";
    elsif rising_edge (clk_in) then
      if wr_add_l ='1' then
        add_l <= d_in;
      end if;
    end if;
  end process;

  -- write tx data register
  process (rst, clk_in)
  begin
    if rst = '1' then
      tx_data <= x"00";
    elsif rising_edge (clk_in) then
      if wr_data = '1' then
        tx_data <= d_in;
      end if;
    end if;
  end process;

  -- new tx data flag
  tx_new_data_clr <= tx_empty_set and is_tx_data;
  process (rst, tx_new_data_clr, clk_in)
  begin
    if rst = '1' or tx_new_data_clr = '1' then
      tx_new_data <= '0';
    elsif rising_edge (clk_in) then
      if wr_data ='1' then
        tx_new_data <= '1';
      end if;
    end if;
  end process;

  -- advance the state machine
  process (rst, clk_in)
  begin
    if rst = '1' then
      state <= IDLE;
    elsif rising_edge (clk_in) then
      if clk_en = '1' then
        state <= next_state;
      end if;
    end if;
  end process;

  -- state machine transition table
  process (state, cmd, tx_bit_cnt, tx_new_data, rx_bit_cnt, rx_empty)
  begin
    case state is
      when IDLE =>
        case cmd is
          when NOP => next_state <= IDLE;
          when others => next_state <= TxCMD;
        end case;

      when TxCMD =>
        if tx_bit_cnt < x"7" then
          next_state <= TxCMD;
        else
          case cmd is
            when WREN | WRDI | BE | DP => next_state <= CLR_CMD;
            when SE | PP | RES | RDCMD | F_RD|WRSR|RDSR => next_state <= WAIT1;
            when others => next_state <= CLR_CMD;
          end case;
        end if;

      when WAIT1 =>
        case cmd is
          when WREN | WRDI | BE | DP => next_state <= CLR_CMD;
          when SE | PP | RES | RDCMD | F_RD => next_state <= TxADD_H;
          when WRSR => next_state <= TxDATA;
          when RDSR => next_state <= RxDATA;
          when others => next_state <= CLR_CMD;
        end case;

      when TxADD_H =>
        if tx_bit_cnt < x"7" then
          next_state <= TxADD_H;
        else
          next_state <= WAIT2;
        end if;

      when WAIT2 => next_state <= TxADD_M;

      when TxADD_M =>
        if tx_bit_cnt < x"7" then
          next_state <= TxADD_M;
        else
          next_state <= WAIT3;
        end if;

      when WAIT3 => next_state <= TxADD_L;

      when TxADD_L =>
        if tx_bit_cnt < x"7" then
          next_state <= TxADD_L;
        else
          case cmd is
            when PP => next_state <= WAIT6;
            when SE | RES | RDCMD | F_RD => next_state <= WAIT4;
            when others => next_state <= CLR_CMD;
          end case;
        end if;

      when WAIT4 =>
        case cmd is
          when F_RD => next_state <= TxDUMMY;
          when RES | RDCMD => next_state <= RxDATA;
          when others => next_state <= CLR_CMD;
        end case;

      when TxDUMMY =>
        if tx_bit_cnt < x"7" then
          next_state <= TxDUMMY;
        else
          next_state <= WAIT8;
        end if;

      when WAIT7 => next_state <= WAIT8;

      when WAIT8 =>
        case cmd is
          when RDCMD | F_RD =>
            if rx_empty = '1' then
              next_state <= RxDATA;
            else
              next_state <= WAIT8;
            end if;
          when others => next_state <= CLR_CMD;
        end case;

      when RxDATA =>
        if rx_bit_cnt < x"7" then
          next_state <= RxDATA;
        else
          case cmd is
            when RDCMD | F_RD => next_state <= WAIT7;
            when RDSR | RES => next_state <= WAIT5;
            when others => next_state <= CLR_CMD;
          end case;
        end if;

      when TxDATA =>
        if tx_bit_cnt < x"7" then
          next_state <= TxDATA;
        else
          case cmd is
            when PP => next_state <= WAIT6;
            when others => next_state <= CLR_CMD;
          end case;
        end if;

      when WAIT6 =>
        case cmd is
          when PP =>
            if tx_new_data = '1' then
              next_state <= TxDATA;
            else
              next_state <= WAIT6;
            end if;
          when others => next_state <= CLR_CMD;
        end case;

      when WAIT5 => next_state <= CLR_CMD;

      when CLR_CMD => next_state <= IDLE;
    end case;
  end process;

  -- state machine output table
  process (state, cmd, tx_data, add_m, add_l, add_h)
  begin
    -- default values
    tx_enable <= '0';
    rx_enable <= '0';
    rx_bit_cnt_clr <= '1';
    tx_reg <= x"FF";
    spi_cs_int <= '0';
    busy <= '1';
    cmd_clr <= '0';
    is_tx_data <= '0';
    is_wait6 <= '0';

    case state is
      when IDLE =>
        busy <= '0';
      when TxCMD =>
        tx_reg <= cmd;
        tx_enable <= '1';
        spi_cs_int <= '1';
      when TxDATA =>
        tx_reg <= tx_data;
        tx_enable <= '1';
        spi_cs_int <= '1';
        is_tx_data <= '1';
      when TxADD_H =>
        tx_reg <= add_h;
        tx_enable <= '1';
        spi_cs_int <= '1';
      when TxADD_M =>
        tx_reg <= add_m;
        tx_enable <= '1';
        spi_cs_int <= '1';
      when TxADD_L =>
        tx_reg <= add_l;
        tx_enable <= '1';
        spi_cs_int <= '1';
      when TxDUMMY =>
        tx_reg <= x"00";
        tx_enable <= '1';
        spi_cs_int <= '1';
      when RxDATA =>
        rx_bit_cnt_clr <= '0';
        rx_enable <= '1';
        spi_cs_int <= '1';
      when WAIT1 | WAIT2 | WAIT3 | WAIT4 | WAIT8 =>
        spi_cs_int <= '1';
      when WAIT6 =>
        is_wait6 <= '1';
        spi_cs_int <= '1';
      when WAIT5 | WAIT7 =>
        rx_bit_cnt_clr <= '0';
        spi_cs_int <= '1';
      when CLR_CMD =>
        cmd_clr <= '1';
      when others => null;
    end case;
  end process;

  -- the tx_empty flip flop
  process (rst, wr_data, clk_in)
  begin
    if rst = '1' then
      tx_empty <= '1';
    elsif wr_data = '1' then
      tx_empty <= '0';
    elsif rising_edge (clk_in) then
      if tx_empty_set = '1' then
        tx_empty <= '1';
      end if;
    end if;
  end process;

  -- delay the tx_enable signal
  process (rst, clk_in)
  begin
    if rst = '1' then
      tx_enable_d <= '0';
    elsif rising_edge (clk_in) then
      tx_enable_d <= tx_enable;
    end if;
  end process;

  -- transmitter shift register and bit counter
  process (rst, tx_reg, tx_enable_d, clk_in)
  begin
    if rst = '1' then
      tx_sreg <= x"FF";
      tx_bit_cnt <= x"0";
      tx_empty_set <= '0';
    elsif tx_enable_d = '0' then
      tx_sreg <= tx_reg;
      tx_bit_cnt <= x"0";
      tx_empty_set <= '0';
    elsif rising_edge (clk_in) then
      if clk_en = '1' then
        tx_bit_cnt <= tx_bit_cnt + 1;
        tx_sreg <= tx_sreg (6 downto 0) & '1';
        if tx_bit_cnt = x"6" and is_tx_data = '1' then
          tx_empty_set <= '1';
        else
          tx_empty_set <= '0';
        end if;
      end if;
    end if;
  end process;

  -- synchronize rd_data
  process (rst, clk_in)
  begin
    if rst = '1' then
      rd_data1 <= '0';
    elsif falling_edge (clk_in) then
      rd_data1 <= rd_data;
    end if;
  end process;

  process (rst, clk_in)
  begin
    if rst = '1' then
      rd_data2 <= '0';
    elsif falling_edge (clk_in) then
      if rd_data = '0' then
        rd_data2 <= rd_data1;
      end if;
    end if;
  end process;

  -- the rx_empty flip flop
  process (rst, clk_in)
  begin
    if rst = '1' then
      rx_empty <= '1';
    elsif rising_edge (clk_in) then
      if rx_empty_clr = '1' then
        rx_empty <= '0';
      elsif rd_data2 = '1' then
        rx_empty <= '1';
      end if;
    end if;
  end process;

  -- the rx_ready flip flop
  process (rst, clk_in)
  begin
    if rst = '1' then
      rx_ready <= '0';
    elsif rising_edge (clk_in) then
      if rd_data = '1' then
        rx_ready <= '0';
      elsif rx_ready_set = '1' then
        rx_ready <= '1';
      end if;
    end if;
  end process;

  -- the rx_data register
  process (rst, clk_in)
  begin
    if rst = '1' then
      rx_data <= x"FF";
    elsif rising_edge (clk_in) then
      if rx_ready_set = '1' then
        rx_data <= rx_sreg;
      end if;
    end if;
  end process;

  -- receiver shift register and bit counter
  process (rst, rx_bit_cnt_clr, clk_in)
  begin
    if rst = '1' or rx_bit_cnt_clr = '1' then
      rx_bit_cnt <= x"0";
      rx_ready_set <= '0';
      rx_empty_clr <= '0';
      rx_sreg <= x"FF";
    elsif rising_edge (clk_in) then
      if clk_en = '1' then
        rx_sreg <= rx_sreg (6 downto 0) & spi_din;
        case rx_bit_cnt is
          when x"0" =>
            rx_bit_cnt <= rx_bit_cnt + 1;
            rx_ready_set <= '0';
            rx_empty_clr <= '1';
          when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" =>
            rx_bit_cnt <= rx_bit_cnt + 1;
            rx_ready_set <= '0';
            rx_empty_clr <= '0';
          when x"7" =>
            rx_bit_cnt <= rx_bit_cnt + 1;
            rx_ready_set <= '1';
            rx_empty_clr <= '0';
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;
end rtl;
