----------------------------------------------------------------------
----                                                              ----
----  UART and FIFO cpu interface                                 ----
----                                                              ----
----  This file is part of the xxx project                        ----
----  http://www.opencores.org/cores/xxx/                         ----
----                                                              ----
----  Description                                                 ----
--             Serial UART with byte wide register interface for control/status, data, and baud rate.
--             Transmit(Tx) and Receive(Rx) data is FIFO buffered. Tx and Rx FIFO size configurable independently.
--             Currently only supports no parity, 8 data bits, 1 stop bit (N81).
--             Data is sent least significant bit first.
--             Baud rate divisor set via 16 bit register, allowing a wide range of baud rates and system clocks.
--
--             Future:
--              - insertion and checking of parity bit
--              - data bit order configurable
--              - number of data bits configurable
--              - cts/rts
--              - interrupt on rx data ready and/or tx fifo empty
--
--Registers: 0x00: Data:
--                    Write this register to push data into the transmit FIFO. The UART
--                    empties the FIFO and transmits data at the specified baud rate.
--                    If the FIFO is full, writes are ignored.
--                    Read this register to pull data from the receive FIFO. If the FIFO
--                    is empty, reading returns the previously read value.
--           0x01: Control/Status:
--                    bit0: Rx FIFO data ready:     High when data waiting in the rx FIFO.
--                    bit1: Rx FIFO overflow flag:  High if overflow occurs. Write 0 to clear.
--                    bit2: Rx stop bit error flag: High if invalid stop bit. Write 0 to clear.
--                    bit3: Tx FIFO full:           High when the tx FIFO is full.        
--                    bit4: Tx FIFO overflow flag:  High if overflow occurs. Write 0 to clear.
--                    bit5: unused
--                    bit6: Cpu interface facing loopback enable: loopback is at serial txd/rxd pins
--                    bit7: Txd/rxd pin facing loopback enable: loopback is at txd/rxd pins
--                          (both loopbacks can be enabled at the same time)
--
--           0x02: Baud Rate Divisor LSB: baud rate = System clock / (baud rate divisor+1)
--           0x03: Baud Rate Divisor MSB: e.g. set to 433 to get 115200 with a 50MHz
--                                        system clock. Error is < 0.01%. 
--
-- Fmax and resource use data:
--
----  To Do:                                                      ----
----   -                                                          ----
----                                                              ----
----  Author(s):                                                  ----
----      - Andrew Bridger, andrew.bridger@gmail.org              ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2001 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log$
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
  generic(
    BASE_ADDR           : natural := 0;                --Uart registers are offset from
                                                       -- this base address.
    TX_FIFO_ADDR_LENGTH : natural := 5;                --5 length addr => 32 byte deep FIFO
    RX_FIFO_ADDR_LENGTH : natural := 5
    );
  port(
    clk            : in  std_logic;                    --all inputs(except rxd) MUST be synchronous to clk.
    reset          : in  std_logic;                    --synchronous reset
    --Serial UART
    i_rxd          : in  std_logic;                    --receive serial data (asynchronous)
    o_txd          : out std_logic;                    --transmit serial data
    --Cpu register interface
    i_addr         : in  std_logic_vector;             --highest index is msb of address.
    i_write_enable : in  std_logic;                    --high for 1 clk period for a write
    i_read_enable  : in  std_logic;                    --high for 1 clk period for a read
    i_data         : in  std_logic_vector(7 downto 0);
    o_data         : out std_logic_vector(7 downto 0)  --data returned up to 2 clock cycles after read_enable
    );
end uart;

architecture rtl of uart is

  signal rxd_d1, rxd_clean : std_logic;

  --FIFO from/to main process communication.
  signal tx_fifo_write_data, tx_fifo_read_data       : std_logic_vector(7 downto 0);
  signal tx_fifo_write_request, tx_fifo_read_request : std_logic;
  signal rx_fifo_write_data, rx_fifo_read_data       : std_logic_vector(7 downto 0);
  signal rx_fifo_write_request, rx_fifo_read_request : std_logic;
  signal rx_fifo_read_request_d1                     : std_logic;
  signal tx_fifo_full_flag                           : std_logic;
  signal tx_fifo_overflow                            : std_logic;
  signal tx_fifo_empty, tx_fifo_data_waiting         : std_logic;
  signal rx_fifo_overflow                            : std_logic;
  signal rx_fifo_empty                               : std_logic;
  signal rx_fifo_data_ready_flag                     : std_logic;

  --Cpu regs/bits
  signal rx_fifo_overflow_flag    : std_logic;
  signal tx_fifo_overflow_flag    : std_logic;
  signal rx_stop_bit_invalid_flag : std_logic;

  signal cpu_facing_loopback_enable     : std_logic;
  signal serial_facing_loopback_enable  : std_logic;
  --Baud rate divisor for 50MHz system clock and 115200 baud rate.
  constant BAUD_RATE_DIVISOR_50M_115200 : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(433, 16));
  signal baud_rate_divisor_slv          : std_logic_vector(15 downto 0);
  --cpu register addresses and bit indexes
  constant DATA_REG                     : std_logic_vector(1 downto 0)  := "00";
  constant CONTROL_STATUS_REG           : std_logic_vector(1 downto 0)  := "01";
  constant BAUD_RATE_DIVISOR_LSB_REG    : std_logic_vector(1 downto 0)  := "10";
  constant BAUD_RATE_DIVISOR_MSB_REG    : std_logic_vector(1 downto 0)  := "11";
  constant BASE_ADDR_SLV                : std_logic_vector(i_addr'length-1 downto 0)
    := std_logic_vector(to_unsigned(BASE_ADDR, i_addr'length));
  
begin

  main : process(clk)
    type uart_state_t is (IDLE, START, DATA, STOP);
    variable tx_state, rx_state : uart_state_t;
    subtype baud_rate_t is natural range 0 to (2**16)-1;
    variable baud_rate_divisor  : baud_rate_t;
    variable tx_baud_rate_count : baud_rate_t;
    variable rx_baud_rate_count : baud_rate_t;
    variable tx_data_count      : natural range 0 to 7;
    variable rx_data_count      : natural range 0 to 7;
    variable rx_bit_enable      : boolean;
    variable tx_bit_enable      : boolean;
    variable chip_select        : boolean;
    variable rxd, txd           : std_logic;
    variable addr               : std_logic_vector(i_addr'length-1 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        --Keep uart serial lines high during reset. Don't want any glitches at startup.
        rxd_d1                        <= '1';
        rxd_clean                     <= '1';
        rxd                           := '1';
        txd                           := '1';
        o_txd                         <= '1';
        --Put UART rx/tx FSMs and counters into a known state at reset.
        tx_state                      := IDLE;
        rx_state                      := IDLE;
        tx_baud_rate_count            := 0;
        rx_baud_rate_count            := 0;
        tx_fifo_write_request         <= '0';
        tx_fifo_read_request          <= '0';
        rx_fifo_write_request         <= '0';
        rx_fifo_read_request          <= '0';
        --Power up state for registers
        baud_rate_divisor_slv         <= BAUD_RATE_DIVISOR_50M_115200;  --set default for 115200
        rx_fifo_overflow_flag         <= '0';
        rx_stop_bit_invalid_flag      <= '0';
        tx_fifo_overflow_flag         <= '0';
        cpu_facing_loopback_enable    <= '0';
        serial_facing_loopback_enable <= '0';
        --Check base addr on x4 byte boundary.
        --Only check during reset so no burden on sim speed. (Synplicity doesn't honour this assert unfortunately.)
        assert BASE_ADDR_SLV(1 downto 0) = "00" report "UART Base address must be 32 bit aligned. I.e. 2 LSBs must be 00"
          severity failure;
      else
        ------[CPU Interface]------
        --CPU interface side of rx and tx fifos. Including the registers directly within this module means
        --this is a self-contained module.
        addr        := i_addr;                                          --ensure addr is in "downto" form.
        chip_select := (addr(addr'high downto 2) = BASE_ADDR_SLV(BASE_ADDR_SLV'high downto 2));
        if chip_select then
          --Cpu register write.
          if i_write_enable = '1' then
            case i_addr(1 downto 0) is
              when DATA_REG =>
                tx_fifo_write_data    <= i_data;
                tx_fifo_write_request <= '1';
              when CONTROL_STATUS_REG =>
                --Some bits are only write zero to clear.
                if i_data(1) = '0' then
                  rx_fifo_overflow_flag <= '0';
                end if;
                if i_data(2) = '0' then
                  rx_stop_bit_invalid_flag <= '0';
                end if;
                if i_data(4) = '0' then
                  tx_fifo_overflow_flag <= '0';
                end if;
                --Standard read/write control bits
                cpu_facing_loopback_enable    <= i_data(6);
                serial_facing_loopback_enable <= i_data(7);

              when BAUD_RATE_DIVISOR_LSB_REG => baud_rate_divisor_slv(7 downto 0)  <= i_data;
              when BAUD_RATE_DIVISOR_MSB_REG => baud_rate_divisor_slv(15 downto 8) <= i_data;
              when others                    => null;
            end case;
          end if;
          --Cpu register read.
          if i_read_enable = '1' then
            case i_addr(1 downto 0) is
              when DATA_REG           => rx_fifo_read_request <= '1';
              when CONTROL_STATUS_REG => o_data               <= serial_facing_loopback_enable &
                                                                 cpu_facing_loopback_enable &
                                                                 '0' &  --unused
                                                                 tx_fifo_overflow_flag &
                                                                 tx_fifo_full_flag &
                                                                 rx_stop_bit_invalid_flag &
                                                                 rx_fifo_overflow_flag &
                                                                 rx_fifo_data_ready_flag;
              when BAUD_RATE_DIVISOR_LSB_REG => o_data <= baud_rate_divisor_slv(7 downto 0);
              when BAUD_RATE_DIVISOR_MSB_REG => o_data <= baud_rate_divisor_slv(15 downto 8);
              when others                    => null;
            end case;
          end if;
        end if;
        --Takes 1 clock to read data out of rx fifo.
        rx_fifo_read_request_d1 <= rx_fifo_read_request;
        if rx_fifo_read_request_d1 = '1' then
          o_data <= rx_fifo_read_data;
        end if;
        --type conversion for baud rate divisor.
        baud_rate_divisor := to_integer( unsigned( baud_rate_divisor_slv ));

        ------[UART Transmit (tx) FSM]------
        tx_fifo_read_request <= '0';    --default
        case tx_state is
          when IDLE =>
            txd := '1';
            if tx_fifo_data_waiting = '1' then
              tx_state             := START;
              tx_fifo_read_request <= '1';
            end if;
          --output 1 start bit
          when START =>
            if tx_bit_enable then
              txd           := '0';
              tx_state      := DATA;
              tx_data_count := 0;
            end if;
          --output 8 data bits, least significant bit first.
          when DATA =>
            if tx_bit_enable then
              txd := tx_fifo_read_data(tx_data_count);
              if tx_data_count = 7 then
                tx_state := STOP;
              else
                tx_data_count := tx_data_count + 1;
              end if;
            end if;
          --output 1 stop bit
          when STOP =>
            if tx_bit_enable then
              txd      := '1';
              tx_state := IDLE;
            end if;
        end case;

        --transmit baud rate "clk" (enable)
        if tx_baud_rate_count = 0 then
          tx_baud_rate_count := baud_rate_divisor;
          tx_bit_enable      := true;
        else
          tx_baud_rate_count := tx_baud_rate_count - 1;
          tx_bit_enable      := false;
        end if;

        ------[UART Receive (rx) FSM]------
        rx_fifo_write_request <= '0';
        case rx_state is
          when IDLE =>
            if rxd = '0' then
              rx_state           := START;
              rx_baud_rate_count := baud_rate_divisor/2;  --setup baud rate counter so we sample
                                                          --at middle of bit period
            end if;
          --look for a start bit that is continuously low for at least 1/2 the nominal bit
          --period. This helps to filter short duration glitches. And gets us sampling
          --rxd at the center of a bit period.
          when START =>
            if rxd /= '0' then
              --start bit has not stayed low for longer than 1/2 a bit period.
              rx_state := IDLE;
            elsif rx_bit_enable then
              rx_state      := DATA;
              rx_data_count := 0;
            end if;
          --read in 8 data bits.
          when DATA =>
            if rx_bit_enable then
              rx_fifo_write_data(rx_data_count) <= rxd;
              if rx_data_count = 7 then
                rx_state := STOP;
              else
                rx_data_count := rx_data_count + 1;
              end if;
            end if;
          --check stop bit is '1'. If not, set the rx error flag.
          when STOP =>
            if rx_bit_enable then
              if rxd = '1' then
                --Valid stop bit, so attempt to write the received byte to the rx fifo.
                rx_fifo_write_request <= '1';
              else
                --Invalid stop bit.
                rx_stop_bit_invalid_flag <= '1';
              end if;
              rx_state := IDLE;
            end if;
        end case;

        --receive baud rate "clk" (enable)
        if rx_baud_rate_count = 0 then
          rx_baud_rate_count := baud_rate_divisor;
          rx_bit_enable      := true;
        else
          rx_baud_rate_count := rx_baud_rate_count - 1;
          rx_bit_enable      := false;
        end if;

        ------[Latch FIFO overflow bits]------
        if tx_fifo_overflow = '1' then
          tx_fifo_overflow_flag <= '1';
        end if;
        if rx_fifo_overflow = '1' then
          rx_fifo_overflow_flag <= '1';
        end if;

        ------[Loopbacks and Rxd Retime]------
        --rxd is an asynchronous input so retime it onto the system clock domain.
        rxd_d1    <= i_rxd;
        rxd_clean <= rxd_d1;
        if cpu_facing_loopback_enable = '0' then
          --normal operation.
          rxd := rxd_clean;
        else
          --loopback enabled.
          rxd := txd;
        end if;
        if serial_facing_loopback_enable = '0' then
          --normal operation.
          o_txd <= txd;
        else
          --loopback enabled.
          o_txd <= rxd_clean;
        end if;
      end if;
    end if;
  end process;

  tx_fifo : entity work.synchronous_FIFO(rtl)
    generic map (
      ADDR_LENGTH => TX_FIFO_ADDR_LENGTH,
      DATA_WIDTH  => 8)
    port map (
      clk           => clk,
      reset         => reset,
      write_data    => tx_fifo_write_data,
      write_request => tx_fifo_write_request,
      full          => tx_fifo_full_flag,
      overflow      => tx_fifo_overflow,
      read_data     => tx_fifo_read_data,
      read_request  => tx_fifo_read_request,
      empty         => tx_fifo_empty,
      underflow     => open,
      half_full     => open);

  tx_fifo_data_waiting <= not tx_fifo_empty;

  rx_fifo : entity work.synchronous_FIFO(rtl)
    generic map (
      ADDR_LENGTH => RX_FIFO_ADDR_LENGTH,
      DATA_WIDTH  => 8)
    port map (
      clk           => clk,
      reset         => reset,
      write_data    => rx_fifo_write_data,
      write_request => rx_fifo_write_request,
      full          => open,
      overflow      => rx_fifo_overflow,
      read_data     => rx_fifo_read_data,
      read_request  => rx_fifo_read_request,
      empty         => rx_fifo_empty,
      underflow     => open,
      half_full     => open);

  rx_fifo_data_ready_flag <= not rx_fifo_empty;
end rtl;
