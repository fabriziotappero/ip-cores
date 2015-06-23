--##############################################################################
-- RS-232 receiver, parametrizable bit rate through generics.
-- Bit rate defaults to 19200 bps @50MHz.
-- WARNING: Hacked up for light8080 demo. Poor performance, no formal testing!
-- I don't advise using this in for any general purpose.
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rs232_rx is
  generic (
    BAUD_RATE     : integer := 19200;
    CLOCK_FREQ    : integer := 50000000);
    port ( 
        rxd       : in std_logic;
        
        data_rx   : out std_logic_vector(7 downto 0);
        rx_rdy    : out std_logic;
        read_rx   : in std_logic;
        
        clk       : in std_logic;
        reset     : in std_logic);
end rs232_rx;

architecture hardwired of rs232_rx is

-- Bit sampling period is 1/16 of the baud rate
constant SAMPLING_PERIOD : integer := (CLOCK_FREQ / BAUD_RATE) / 16;


--##############################################################################

-- Serial port signals
signal rxd_q :            std_logic;
signal tick_ctr :         std_logic_vector(3 downto 0);
signal state :            std_logic_vector(3 downto 0);
signal next_state :       std_logic_vector(3 downto 0);
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
signal tick_baud_ctr :    std_logic_vector(10 downto 0);

signal rx_rdy_flag :      std_logic;
signal set_rx_rdy_flag :  std_logic;


begin

process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_baud_ctr <= (others => '0');
    else
      if conv_integer(tick_baud_ctr)=SAMPLING_PERIOD then -- 325 for 9600 bps
        tick_baud_ctr <= (others => '0');
      else
        tick_baud_ctr <= tick_baud_ctr + 1;
      end if;
    end if;
  end if;
end process;

tick_ctr_enable<= '1' when conv_integer(tick_baud_ctr)=SAMPLING_PERIOD else '0';

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
end process;


start_bit_detected <= '1' when state="0000" and rxd_q='1' and rxd='0' else '0';
reset_tick_ctr <= '1' when start_bit_detected='1' else '0';

stop_bit_sampled <= '1' when state="1010" and tick_ctr="1011" else '0';
load_rx_buffer <= '1' when stop_bit_sampled='1' and sampled_bit='1' else '0';
stop_error <= '1' when stop_bit_sampled='1' and sampled_bit='0' else '0';

process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_ctr <= "0000";
    else
      if tick_ctr_enable='1' then
        if tick_ctr="1111" or reset_tick_ctr='1' then
          tick_ctr <= "0000";
        else
          tick_ctr <= tick_ctr + 1;
        end if;
      end if;
    end if;
  end if;
end process;

next_state <= 
  "0001" when state="0000" and start_bit_detected='1' else
  "0000" when state="0001" and tick_ctr="1010" and sampled_bit='1' else
  "0000" when state="1010" and tick_ctr="1111" else
  state + 1 when tick_ctr="1111" and do_shift='1' else
  state;
      

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
end process;

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
end process;

with samples select 
  sampled_bit <=  '0' when "000",
                  '0' when "001",
                  '0' when "010",
                  '1' when "011",
                  '0' when "100",
                  '1' when "101",
                  '1' when "110",
                  '1' when others;

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
end process;

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
end process;

do_shift <= state(0) or state(1) or state(2) or state(3);

-- reception shift register
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
end process;

rx_rdy <= rx_rdy_flag;

data_rx <= rx_buffer;

end hardwired;
