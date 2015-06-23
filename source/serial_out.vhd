--------------------------------------------------------------------------------
---
---  SERIAL OUTPUT
---
---  :Author: Jonathan P Dawson
---  :Date: 17/10/2013
---  :email: chips@jondawson.org.uk
---  :license: MIT
---  :Copyright: Copyright (C) Jonathan P Dawson 2013
---
---  A Serial Output Component
---
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_output is

  generic(
    CLOCK_FREQUENCY : integer;
    BAUD_RATE       : integer
  );
  port(
    CLK     : in std_logic;
    RST     : in  std_logic;
    TX      : out std_logic := '1';
   
    IN1     : in std_logic_vector(7 downto 0);
    IN1_STB : in std_logic;
    IN1_ACK : out std_logic := '1'
  );

end entity serial_output;

architecture RTL of serial_output is

  constant CLOCK_DIVIDER : Unsigned(11 downto 0) := To_unsigned(CLOCK_FREQUENCY/BAUD_RATE, 12);
  signal BAUD_COUNT      : Unsigned(11 downto 0) := (others => '0');
  signal DATA            : std_logic_vector(7 downto 0) := (others => '0');
  signal X16CLK_EN       : std_logic := '0';
  signal S_IN1_ACK       : std_logic := '0';

  type STATE_TYPE is (IDLE, START, WAIT_EN, TX0, TX1, TX2, TX3, TX4, TX5, TX6, TX7, STOP);
  signal STATE : STATE_TYPE := IDLE;

begin

  process
  begin
    wait until rising_edge(CLK);
    if BAUD_COUNT = CLOCK_DIVIDER - 1 then
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
    case STATE is
      when IDLE =>
        TX <= '1';
        S_IN1_ACK <= '1';
        if S_IN1_ACK = '1' and IN1_STB = '1' then
          S_IN1_ACK <= '0';
          DATA  <= IN1;
          STATE <= WAIT_EN;
        end if;
      when WAIT_EN =>
        if X16CLK_EN = '1' then
          STATE <= START;
        end if;
      when START =>
        if X16CLK_EN = '1' then
          STATE <= TX0;
        end if;
        TX <= '0'; 
      when TX0 =>
        if X16CLK_EN = '1' then
          STATE <= TX1;
        end if;
        TX <= DATA(0);
      when TX1 =>
        if X16CLK_EN = '1' then
          STATE <= TX2;
        end if;
        TX <= DATA(1);
      when TX2 =>
        if X16CLK_EN = '1' then
          STATE <= TX3;
        end if;
        TX <= DATA(2);
      when TX3 =>
        if X16CLK_EN = '1' then
          STATE <= TX4;
        end if;
        TX <= DATA(3);
      when TX4 =>
        if X16CLK_EN = '1' then
          STATE <= TX5;
        end if;
        TX <= DATA(4);
      when TX5 =>
        if X16CLK_EN = '1' then
          STATE <= TX6;
        end if;
        TX <= DATA(5);
      when TX6 =>
        if X16CLK_EN = '1' then
          STATE <= TX7;
        end if;
        TX <= DATA(6);
      when TX7 =>
        if X16CLK_EN = '1' then
          STATE <= STOP;
        end if;
        TX <= DATA(7);
      when STOP =>
        if X16CLK_EN = '1' then
          STATE <= IDLE;
        end if;
        TX <= '1';
      when others =>
        STATE <= IDLE;
    end case;
    if RST = '1' then
      STATE <= IDLE;
      TX <= '1';
      S_IN1_ACK <= '0';
    end if; 
  end process;

  IN1_ACK <= S_IN1_ACK;

end architecture RTL;
