--
-- Rotary Control for Spartan 3E Starter Kit
-- Adapted to attach to z80soc by:
--
-- Ronivon C. Costa
-- 2008/05/12
--
-------------------------------------------------------------------------------------------
-- Reference design - Rotary encoder and simple LEDs on Spartan-3E Starter Kit (Revision C)
--
-- Ken Chapman - Xilinx Ltd - November 2005
-- Revised 20th February 2006
--
-- This design demonstrates how to interface to the rotary encoder and simple LEDs.
--    At the start, only one LED is on. 
--    Turning the rotary encoder to the left or right will cause
--    the LED which is on to appear to also move in the corresponding direction.
--    Pressing the rotary encoder will invert all LEDs so that only one is off.
--
-- The design also uses the 50MHz oscillator provided on the board.
--
-- Instructional value
--   Basic VHDL including definition of inputs and outputs.
--   UCF (User Constraints File) constraints to define pin assignments to match board.
--   UCF constraints to apply pull-up and pull-down resistors to input pins.
--   Detecting rotary movement.
--   Synchronous design.
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2006.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ROT_CTRL IS
	PORT (
		CLOCK				: IN STD_LOGIC;
		ROT_A				: IN STD_LOGIC;
		ROT_B				: IN STD_LOGIC;
		DIRECTION		: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0));
END ROT_CTRL;

ARCHITECTURE RTL OF ROT_CTRL IS

SIGNAL rotary_in			: std_logic_vector(1 downto 0);
SIGNAL rotary_in_a		: std_logic;
SIGNAL rotary_in_b		: std_logic;
SIGNAL rotary_q1			: std_logic;
SIGNAL rotary_q2			: std_logic;
SIGNAL delay_rotary_q1	: std_logic;
SIGNAL rotary_event		: std_logic;
SIGNAL rotary_left		: std_logic;
SIGNAL counter				: std_logic_vector(21 downto 0);

BEGIN
--
-- Define direction based on rotary movement, and return to processor
--
  return_dir: process(CLOCK)
  begin
		if CLOCK'event and CLOCK = '1' then
			if rotary_event='1' then
				if rotary_left='1' then 
					DIRECTION <= "10"; -- Rotating to the left
					counter <= "0000000000000000000000";
				else
					DIRECTION <= "01"; -- Rotating to the right
					counter <= "0000000000000000000000";
				end if;
			else
				if counter = "1111111111111111111111" then
					DIRECTION <= "00"; 
					counter <= "0000000000000000000000";
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interface to rotary encoder.
  -- Detection of movement and direction.
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The rotary switch contacts are filtered using their offset (one-hot) style to  
  -- clean them. Circuit concept by Peter Alfke.
  -- Note that the clock rate is fast compared with the switch rate.

--
-- The rising edges of 'rotary_q1' indicate that a rotation has occurred and the 
-- state of 'rotary_q2' at that time will indicate the direction. 
--
rotary_direction: process(CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
		delay_rotary_q1 <= rotary_q1;
		if rotary_q1='1' and delay_rotary_q1='0' then
			rotary_event <= '1';
			rotary_left <= rotary_q2;
		else
			rotary_event <= '0';
			rotary_left <= rotary_left;
		end if;
	end if;
end process;

rotary_filter: process(CLOCK)
begin
	if CLOCK'event and CLOCK='1' then
      --Synchronise inputs to clock domain using flip-flops in input/output blocks.		
		rotary_in_a <= ROT_A;
		rotary_in_b <= ROT_B;
		rotary_in <= rotary_in_a & rotary_in_b;
		
		case rotary_in is
			when "00" => 
				rotary_q1 <= '0';
				rotary_q2 <= rotary_q2;
			when "01" => 
				rotary_q1 <= rotary_q1;
				rotary_q2 <= '0';
			when "10" => 
				rotary_q1 <= rotary_q1;
				rotary_q2 <= '1';
			when "11" => 
				rotary_q1 <= '1';
				rotary_q2 <= rotary_q2;
			when others => 
				rotary_q1 <= rotary_q1;
				rotary_q2 <= rotary_q2;
		end case;
	end if;
end process;

end;