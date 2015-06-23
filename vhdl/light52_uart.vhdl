--------------------------------------------------------------------------------
-- light52_uart.vhdl -- Basic, hardwired RS232 UART.
--------------------------------------------------------------------------------
--
-- Most operational parameters are hardcoded: 8 bit words, no parity, 1 stop 
-- bit. The only parameter that can be configured in run time is the baud rate,
-- and only if generic HARDWIRED is set to false.
--
-- The UART is independent of any external timers and has its own baud rate 
-- counter (if enabled with generic HARDWIRED). 
-- 9-bit modes from the original MCS51 UART are not yet supported.
-- The UART supports polled mode with TxRdy and RxRdy flags in SCON and will 
-- eventually support parity bits. 
--
-- The receiver logic is a simplified copy of the original 8051 UART as 
-- described in Intel manuals. The bit period is split in 16 sampling periods, 
-- and 3 samples are taken at the center of each bit period. The bit value is 
-- decided by majority. The receiver logic has some error recovery capability 
-- that should make this core reliable enough for actual application use -- yet, 
-- the core does not have a formal test bench.
--
-- See usage notes below.
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
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
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- UART programmer model
--------------------------------------------------------------------------------
--
-- The UART has a number of configuration registers addressable with input 
-- signal addr_i:
--
-- [00] => SCON: Status/control register (r/w).
-- [01] => SBUF: Data buffer, both transmission and reception.
-- [10] => SBPL: Bit period register, low byte -- OPTIONAL.
-- [11] => SBPH: Bit period register, high byte -- OPTIONAL.
--
-- Note that the SFR address mapping is determined externally.
-- Note too that SCON flags are not compatible to the original 51 except for 
-- the TI and RI flags.
--
-- Data buffers:
----------------
--
-- SBUF works as in the original 8051. Writing to it triggers a transmission, 
-- and the same address [00b] is used for both the rx and the tx buffer. 
--
-- Writing to the data buffer when flag TxRdy is high will trigger a 
-- transmission and clear flag TxRdy.
-- Writing to the data buffer when flag TxRdy is clear will have no effect.
-- 
-- Reading the data register when flag RxRdy is high will return the last 
-- received data byte, and will clear flag RxRdy but NOT RxIrq. 
-- Reading the register when flag RxRdy is clear will return indeterminate data,
-- which in practice will usually be the last byte received.
--
-- Interrupts:
--------------
--
-- The core has two interrupt sources tied to a single external irq line. The
-- sources are these:
-- 
-- -# Receiver interrupt: Raised when the stop bit is sampled and determined 
--    to be valid (about the middle of the bit period).
--    If the stop bit is not valid (not high) then the interrupt is not 
--    triggered. If a start bit is determined to be spurious (i.e. the falling
--    edge is detected but the bit value when sampled is not 0) then the
--    interrupt is not triggered -- because reception is aborted.
--    This interrupt sets flag RxIrw in the status register.
-- -# Transmitter interrupt: Raised at the end of the transmission of the stop
--    bit.
--    This interrupt sets flag TxIrq in the status register 1 clock cycle after
--    the interrupt is raised.
-- 
-- The core does not have any interrupt enable mask. If any interrupt source 
-- triggers, the output irq_o is asserted for one cycle. This is all the extent 
-- of the interrupt processing done by this module -- enough to be connected
-- to the light52 interrupt module but not for general use outside this project.
-- 
-- Error detection:
-------------------
--
-- The core is capable of detecting and recovering from these error conditions:
-- 
-- -# When a start bit is determined to be spurious (i.e. the falling edge is 
--    detected but the bit value when sampled is not 0) then the core returns to
--    its idle state (waiting for a new start bit).
-- -# If a stop bit is determined to be invalid (not 1 when sampled), the 
--    reception interrupt is not triggered and the received byte is discarded.
-- -# When the 3 samples taken from the center of a bit period are not equal, 
--    the bit value is decided by majority.
-- 
-- In none of the 3 cases does the core raise any error flag. It would be very 
-- easy to include those flags in the core, but it would take a lot more time 
-- to test them minimally and that's why they haven't been included.
--
-- Status register flags:
-------------------------
--
--      7       6       5       4       3       2       1       0
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--  |   0   |   0   | RxRdy | TxRdy |   0   |   0   | RxIrq | TxIrq |
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--      h       h       r       r       h       h      W1C     W1C    
--
--  Bits marked 'h' are hardwired and can't be modified. 
--  Bits marked 'r' are read only; they are set and clear by the core.
--  Bits marked W1C ('Write 1 Clear') are set by the core when an interrupt 
--  has been triggered and must be cleared by the software by writing a '1'.
--
-- -# Status bit TxRdy is high when there isn't any transmission in progress. 
--    It is cleared when data is written to the transmission buffer and is 
--    raised at the same time the transmission interrupt is triggered.
-- -# Status bit RxRdy is raised at the same time the receive interrupt is
--    triggered and is cleared when the data register is read.
-- -# Status bit TxIrq is raised when the transmission interrupt is triggered 
--    and is cleared when a 1 is written to it.
-- -# Status bit RxIrq is raised when the reception interrupt is triggered 
--    and is cleared when a 1 is written to it.
--
-- When writing to the status/control registers, only flags TxIrq and RxIrq are
-- affected, and only when writing a '1' as explained above. All other flags 
-- are read-only.
--
-- Baud rate configuration:
---------------------------
--
-- The baud rate is determined by the value of 14-bit register 'bit_period_reg'.
-- This register holds the length of the bit period in clock cycles and its
-- value may be hardcoded or configured at run time.
--
-- When generic HARDWIRED is true, bit_period_reg is hardwired with a value 
-- computed from the value of generic BAUD_RATE. The bit period computation 
-- needs to know the master clock rate, which should be given in generic 
-- CLOCK_RATE.
-- Writes to the baud registers when HARDWIRED is true will be ignored.
--
-- When generic HARDWIRED is false, generics BAUD_RATE and CLOCK_RATE determine 
-- the reset value of bit_period_reg, but the register can be changed at run 
-- time by writing at addresses [10b] and [11b], which access the low and high 
-- bytes of the register, respectively.
-- Reading from those register addresses returns the value of the status 
-- register (a LUT saving measure) so the registers are effectively write-only.
--
--------------------------------------------------------------------------------
-- Core interface signals:
--
-- clk_i:     Clock input, active rising edge.
-- reset_i:   Synchronous reset.
-- txd_o:     TxD UART output.
-- rxd_i:     RxD UART input -- synchronization logic included.
-- irq_o:     Interrupt output, asserted for 1 cycle when triggered.
-- data_i:    Data bus, input.
-- data_o:    Data bus, output.
-- addr_i:    Register selection address (see above).
-- wr_i:      Write enable input.
-- rd_i:      Read enable input.
-- ce_i:      Chip enable, must be active at the same time as wr_i or rd_i.
-- 
--
-- A detailed explanation of the interface timing will not be given. The core 
-- reads and writes like a synchronous memory. There's usage examples in other 
-- project files.
--------------------------------------------------------------------------------

entity light52_uart is
  generic (
    HARDWIRED     : boolean := true;  -- Baud rate hardwired to constant value 
    BAUD_RATE     : natural := 19200; -- Default (or hardwired) baud rate 
    CLOCK_FREQ    : natural := 50E6); -- Clock rate
    port ( 
        rxd_i     : in std_logic;
        txd_o     : out std_logic;
        
        irq_o     : out std_logic;
        
        data_i    : in std_logic_vector(7 downto 0);
        data_o    : out std_logic_vector(7 downto 0);
        
        addr_i    : in std_logic_vector(1 downto 0);
        wr_i      : in std_logic;
        rd_i      : in std_logic;
        ce_i      : in std_logic;
        
        clk_i     : in std_logic;
        reset_i   : in std_logic
    );
end light52_uart;

architecture hardwired of light52_uart is

-- Bit period expressed in master clock cycles
constant DEFAULT_BIT_PERIOD : integer := (CLOCK_FREQ / BAUD_RATE);


--##############################################################################

-- Common signals

signal reset :            std_logic;
signal clk :              std_logic;


signal bit_period_reg :   unsigned(13 downto 0);
signal sampling_period :  unsigned(9 downto 0);


-- Interrupt & status register signals

signal tx_irq_flag :      std_logic;
signal rx_irq_flag :      std_logic;
signal load_stat_reg :    std_logic;
signal load_tx_reg :      std_logic;

-- Receiver signals
signal rxd_q :            std_logic;
signal tick_ctr :         unsigned(3 downto 0);
signal state :            unsigned(3 downto 0);
signal next_state :       unsigned(3 downto 0);
signal start_bit_detected : std_logic;
signal reset_tick_ctr :   std_logic;
signal stop_bit_sampled : std_logic;
signal load_rx_buffer :   std_logic;
signal stop_error :       std_logic;
signal samples :          std_logic_vector(2 downto 0);
signal sampled_bit :      std_logic;
signal do_shift :         std_logic;
signal rx_buffer :        std_logic_vector(7 downto 0);
signal rx_shift_reg :     std_logic_vector(9 downto 0);
signal tick_ctr_enable :  std_logic;
signal tick_baud_ctr :    unsigned(10 downto 0);

signal rx_rdy_flag :      std_logic;
signal rx_irq :           std_logic;
signal set_rx_rdy_flag :  std_logic;
signal rxd :              std_logic;

signal read_rx :          std_logic;
signal status :           std_logic_vector(7 downto 0);

-- Transmitter signals 

signal tx_counter :       unsigned(13 downto 0);
signal tx_data :          std_logic_vector(10 downto 0);
signal tx_ctr_bit :       unsigned(3 downto 0);
signal tx_busy :          std_logic;
signal tx_irq :           std_logic;



begin

-- Do a minimal sanity check on the value of the generics.
-- This will only catch some of the many ways the configuration can go wrong,
-- the rest will get caught while debugging...
assert (BAUD_RATE*16) < CLOCK_FREQ
report "UART default baud rate is too high."
severity failure;


-- Rename the most commonly used inputs to get rid of the i/o suffix
clk <= clk_i;
reset <= reset_i;
rxd <= rxd_i;


-- Serial port status byte -- only 2 status flags -- SEE process interrupt_flags
-- below if you change these!
status <= 
    "00" & rx_rdy_flag & (not tx_busy) &    -- State flags
    "00" & rx_irq_flag & tx_irq_flag;       -- Interrupt flags

-- Read register multiplexor
with addr_i select data_o <= 
    rx_buffer   when "01",
    status      when others;


load_tx_reg <= '1' when wr_i = '1' and ce_i = '1' and addr_i = "01" else '0';
load_stat_reg <= '1' when wr_i = '1' and ce_i = '1' and addr_i = "00" else '0';
read_rx <= '1' when rd_i = '1' and ce_i = '1' else '0';

rx_irq <= set_rx_rdy_flag;
    
irq_o <= rx_irq or tx_irq;    

interrupt_flags:
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      rx_irq_flag <= '0';
      tx_irq_flag <= '0';
    else
      if set_rx_rdy_flag='1' then
        rx_irq_flag <= '1';
      elsif load_stat_reg='1' and data_i(1)='1' then
        rx_irq_flag <= '0';
      end if;
      if tx_irq='1' then
        tx_irq_flag <= '1';
      elsif load_stat_reg='1' and data_i(0)='1' then
        tx_irq_flag <= '0';
      end if;
    end if;
  end if;
end process interrupt_flags;


baud_rate_registers:
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      bit_period_reg <= to_unsigned(DEFAULT_BIT_PERIOD,14);
    else
      if wr_i = '1' and ce_i = '1' then
        if addr_i = "10" then
          bit_period_reg(7 downto 0) <= unsigned(data_i);
        elsif addr_i = "11" then
          bit_period_reg(13 downto 8) <= unsigned(data_i(5 downto 0));
        end if;
      end if;
    end if;
  end if;
end process baud_rate_registers;

sampling_period <= bit_period_reg(13 downto 4);
    
  
-- Receiver --------------------------------------------------------------------

baud_counter:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_baud_ctr <= (others => '0');
    else
      if tick_baud_ctr=sampling_period then
        tick_baud_ctr <= (others => '0');
      else
        tick_baud_ctr <= tick_baud_ctr + 1;
      end if;
    end if;
  end if;
end process baud_counter;

tick_ctr_enable<= '1' when tick_baud_ctr=sampling_period else '0';

-- Register RxD at the bit sampling rate -- 16 times the baud rate. 
rxd_input_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rxd_q <= '0';
    else
      if tick_ctr_enable='1' then
        rxd_q <= rxd;
      end if;
    end if;
  end if;
end process rxd_input_register;

-- We detect the start bit when...
start_bit_detected <= '1' when 
      state="0000" and        -- ...we're waiting for the start bit...
      rxd_q='1' and rxd='0'   -- ...and we see RxD going 1-to-0
      else '0';         

-- As soon as we detect the start bit we synchronize the bit sampler to 
-- the start bit's falling edge.
reset_tick_ctr <= '1' when start_bit_detected='1' else '0';

-- We have seen the end of the stop bit when...
stop_bit_sampled <= '1' when 
      state="1010" and        -- ...we're in the stop bit period...
      tick_ctr="1011"         -- ...and we get the 11th sample in the bit period
      else '0';

-- Load the RX buffer with the shift register when...
load_rx_buffer <= '1' when 
      stop_bit_sampled='1' and  -- ...we've just seen the end of the stop bit...
      sampled_bit='1'           -- ...and its value is correct (1)
      else '0';

-- Conversely, we detect a stop bit error when...   
stop_error <= '1' when 
      stop_bit_sampled='1' and  -- ...we've just seen the end of the stop bit...
      sampled_bit='0'           -- ...and its value is incorrect (0)
      else '0';

-- tick_ctr is a counter 16 times faster than the baud rate that is aligned to 
-- the falling edge of the start bit, so that when tick_ctr=0 we're close to 
-- the start of a bit period.      
bit_sample_counter:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_ctr <= "0000";
    else
      if tick_ctr_enable='1' then
        -- Restart counter when it reaches 15 OR when the falling edge
        -- of the start bit is detected; this is how we synchronize to the 
        -- start bit.
        if tick_ctr="1111" or reset_tick_ctr='1' then
          tick_ctr <= "0000";
        else
          tick_ctr <= tick_ctr + 1;
        end if;
      end if;
    end if;
  end if;
end process bit_sample_counter;

-- Main RX state machine: 
-- 0      -> waiting for start bit
-- 1      -> sampling start bit
-- 2..9   -> sampling data bit 0 to 7
-- 10     -> sampling stop bit
next_state <= 
  -- Start sampling the start bit when we detect the falling edge
  "0001" when state="0000" and start_bit_detected='1' else
  -- Return to idle state if the start bit is not a clean 0
  "0000" when state="0001" and tick_ctr="1010" and sampled_bit='1' else
  -- Return to idle state at the end of the stop bit period
  "0000" when state="1010" and tick_ctr="1111" else
  -- Otherwise, proceed to next bit period at the end of each period
  state + 1 when tick_ctr="1111" and do_shift='1' else
  state;
      
rx_state_machine_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      state <= "0000";
    else
      if tick_ctr_enable='1' then
        state <= next_state;
      end if;   
    end if;
  end if;
end process rx_state_machine_register;

-- Collect 3 RxD samples from the 3 central sampling periods of the bit period.
rx_sampler:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      samples <= "000";
    else
      if tick_ctr_enable='1' then
        if tick_ctr="0111" then
          samples(0) <= rxd;
        end if;
        if tick_ctr="1000" then
          samples(1) <= rxd;
        end if;
        if tick_ctr="1001" then
          samples(2) <= rxd;
        end if;
      end if;
    end if;
  end if;
end process rx_sampler;

-- Decide the value of the RxD bit by majority
with samples select 
  sampled_bit <=  '0' when "000",
                  '0' when "001",
                  '0' when "010",
                  '1' when "011",
                  '0' when "100",
                  '1' when "101",
                  '1' when "110",
                  '1' when others;

rx_buffer_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_buffer <= "00000000";
      set_rx_rdy_flag <= '0';
    else
      if tick_ctr_enable='1' and load_rx_buffer='1' and rx_rdy_flag='0' then
        rx_buffer <= rx_shift_reg(8 downto 1);
        set_rx_rdy_flag <= '1';
      else
        set_rx_rdy_flag <= '0';
      end if;
    end if;
  end if;
end process rx_buffer_register;

rx_flag:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_rdy_flag <= '0';
    else
      if set_rx_rdy_flag='1' then
        rx_rdy_flag <= '1';
      else
        if read_rx = '1' then
          rx_rdy_flag <= '0';
        end if;
      end if;
    end if;
  end if;
end process rx_flag;

-- RX shifter control: shift in any state other than idle state (0)
do_shift <= state(0) or state(1) or state(2) or state(3);

rx_shift_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_shift_reg <= "1111111111";
    else
      if tick_ctr_enable='1' then
        if tick_ctr="1010" and do_shift='1' then
          rx_shift_reg(9) <= sampled_bit;
          rx_shift_reg(8 downto 0) <= rx_shift_reg(9 downto 1);
        end if;
      end if;
    end if;
  end if;
end process rx_shift_register;

    
-- Transmitter -----------------------------------------------------------------


main_tx_process:
process(clk)
begin
if clk'event and clk='1' then
  
  if reset='1' then
    tx_data <= "10111111111";
    tx_busy <= '0';
    tx_irq <= '0';
    tx_ctr_bit <= "0000";
    tx_counter <= (others => '0');
  elsif load_tx_reg='1' and tx_busy='0' then
    tx_data <= "1"&data_i&"01";
    tx_busy <= '1';
  else
    if tx_busy='1' then
      if tx_counter = bit_period_reg then
        tx_counter <= (others => '0');
        tx_data(9 downto 0) <= tx_data(10 downto 1);
        tx_data(10) <= '1';
        if tx_ctr_bit = "1010" then
           tx_busy <= '0';
           tx_irq <= '1';
           tx_ctr_bit <= "0000";
        else
           tx_ctr_bit <= tx_ctr_bit + 1;
        end if;
      else
        tx_counter <= tx_counter + 1;
      end if;
    else
      tx_irq <= '0';
    end if;
  end if;
end if;
end process main_tx_process;

txd_o <= tx_data(0);

end hardwired;
