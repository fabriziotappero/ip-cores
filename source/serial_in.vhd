--------------------------------------------------------------------------------
---
---  SERIAL INPUT
---
---  :Author: Jonathan P Dawson
---  :Date: 17/10/2013
---  :email: chips@jondawson.org.uk
---  :license: MIT
---  :Copyright: Copyright (C) Jonathan P Dawson 2013
---
---  A Serial Input Component
---
--------------------------------------------------------------------------------
---
---Serial Input
---============
---
---Read a stream of data from a serial UART
---
---Outputs
-----------
---
--- + OUT1 : Serial data stream
---
---Generics
-----------
---
--- + baud_rate
--- + clock frequency

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SERIAL_INPUT is

  generic(
    CLOCK_FREQUENCY : integer;
    BAUD_RATE       : integer
  );
  port(
    CLK      : in std_logic;
    RST      : in std_logic;
    RX       : in std_logic;
   
    OUT1     : out std_logic_vector(7 downto 0);
    OUT1_STB : out std_logic;
    OUT1_ACK : in  std_logic
  );

end entity SERIAL_INPUT;

architecture RTL of SERIAL_INPUT is

  type SERIAL_IN_STATE_TYPE is (IDLE, START, RX0, RX1, RX2, RX3, RX4, RX5, RX6, RX7, STOP, OUTPUT_DATA);
  signal STATE           : SERIAL_IN_STATE_TYPE;
  signal STREAM          : std_logic_vector(7 downto 0);
  signal STREAM_STB      : std_logic;
  signal STREAM_ACK      : std_logic;
  signal COUNT           : integer Range 0 to 3;
  signal BIT_SPACING     : integer Range 0 to 15;
  signal INT_SERIAL      : std_logic;
  signal SERIAL_DEGLITCH : std_logic_Vector(1 downto 0);
  constant CLOCK_DIVIDER : unsigned(11 downto 0) := To_unsigned(CLOCK_FREQUENCY/(BAUD_RATE * 16), 12);
  signal BAUD_COUNT      : unsigned(11 downto 0);
  signal X16CLK_EN       : std_logic;

begin

  process
  begin
    wait until rising_edge(CLK);
    if BAUD_COUNT = CLOCK_DIVIDER then
      BAUD_COUNT <= (others => '0');
      X16CLK_EN  <= '1';
    else
      BAUD_COUNT <= BAUD_COUNT + 1;
      X16CLK_EN  <= '0';
    end if;
    if RST = '1' then
      BAUD_COUNT <= (others => '0');
      X16CLK_EN  <= '0';
    end if;
  end process;

  process
  begin
    wait until rising_edge(CLK);
    SERIAL_DEGLITCH <= SERIAL_DEGLITCH(0) & RX;
    if X16CLK_EN = '1' then
      if SERIAL_DEGLITCH(1) = '0' then
        if COUNT = 0 then
          INT_SERIAL <= '0';
        else 
          COUNT <= COUNT - 1;
        end if;
      else
        if COUNT = 3 then
          INT_SERIAL <= '1';
        else
          COUNT <= COUNT + 1;
        end if;
      end if;
    end if;
    if RST = '1' then
      SERIAL_DEGLITCH <= "11";
    end if;
  end process;

  process
  begin
    wait until rising_edge(CLK);
	 if X16CLK_EN = '1' then 
      if BIT_SPACING = 15 then
        BIT_SPACING <= 0;
      else
        BIT_SPACING <= BIT_SPACING + 1;
      end if;
    end if;
    case STATE is
      when IDLE =>
        BIT_SPACING <= 0;
        if X16CLK_EN = '1' and INT_SERIAL = '0' then
          STATE <= START;
        end if;
      when START =>
        if X16CLK_EN = '1' and BIT_SPACING = 7 then
          BIT_SPACING <= 0;
          STATE <= RX0;
        end if; 
      when RX0 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(0) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX1;
        end if;
      when RX1 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(1) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX2;
        end if;
      when RX2 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(2) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX3;
        end if;
      when RX3 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(3) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX4;
        end if;
      when RX4 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(4) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX5;
        end if;
      when RX5 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(5) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX6;
        end if;
      when RX6 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(6) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= RX7;
        end if;
      when RX7 =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
          OUT1(7) <= INT_SERIAL;
          BIT_SPACING <= 0;
          STATE <= STOP;
        end if;
      when STOP =>
        if X16CLK_EN = '1' and BIT_SPACING = 15 then
            BIT_SPACING <= 0;
            STATE <= OUTPUT_DATA;
            OUT1_STB <= '1';
        end if;
      when OUTPUT_DATA =>
          if OUT1_ACK = '1' then
            OUT1_STB <= '0';
            STATE <= IDLE;
          end if;
      when others =>
        STATE <= IDLE;
    end case;
    if RST = '1' then
      STATE <= IDLE;
      OUT1_STB <= '0';
    end if; 
  end process;
end architecture RTL;
