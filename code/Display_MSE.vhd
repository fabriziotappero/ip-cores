--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


-- ******************---
--
--	To be used with LMS testing rutine
--	process Error signal for proper display
--
-- ******************---

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Main BLOCK BODY
entity Display_MSE is
    Port ( 
    		 reset: in std_logic;
           error_in : in std_logic_vector(7 downto 0);
           clock : in std_logic;
		 an_out: out std_logic;
           seg_select_out : out std_logic_vector(3 downto 0);
           seg_dis_out : out std_logic_vector(7 downto 0));
end Display_MSE;

-- Architecture
architecture mixed of Display_MSE is

-- Components Used

	-- 1 Multiplexer For input to 7 segment module
	component mux 
	    Port ( in1 : in std_logic_vector(3 downto 0);
	           in2 : in std_logic_vector(3 downto 0);
	           in3 : in std_logic_vector(3 downto 0);
	           in4 : in std_logic_vector(3 downto 0);
	           sel : in std_logic_vector( 1 downto 0);

	           o_ut : out std_logic_vector(3 downto 0));
	end component;

	-- 2 Binary to sevenseg Mapping module
	component bin_to_7seg 
		    Port ( din : in std_logic_vector(3 downto 0);
		           dis_out : out std_logic_vector(7 downto 0));
	end component;

	-- 3 Digital to analog output	1 bit (frequency)
	component d_a 
		  port (
			   clk : in std_logic;
			   data_in : in std_logic_vector (15 downto 0);
			   reset:in std_logic;

			   an_out : out std_logic
			  );
	end component;
	
	-- Local Interconnects
	signal error_tmp: std_logic_vector( 15 downto 0);
	signal error_led_out_tmp:std_logic_vector(7 downto 0);
	signal seg_in: std_logic_vector( 3 downto 0);
	signal seg_sel: std_logic_vector( 1 downto 0);

begin

	-- FSM for Selcting 7 segment display (Multiplexed mode)

	mux_display_sel: 
	process (clock)
	begin
		if(clock'event and clock = '1') then
			 if reset = '0' then seg_sel <= "00";
			 elsif seg_sel = "00" then seg_sel <= "01";
			 elsif seg_sel = "01" then seg_sel <= "10";
			 elsif seg_sel = "10" then seg_sel <= "11";
			 elsif seg_sel = "11" then seg_sel <= "00";
			 else  seg_sel <= "ZZ"; 
			 end if;

		end if;
	end process;

	-- Selecting perticular segment for display

	seg_select_out <= 	"0ZZZ" when seg_sel = "00" else
					"Z0ZZ" when seg_sel = "01" else
					"ZZ0Z" when seg_sel = "10" else
					"ZZZ0" when seg_sel = "11" else
					"ZZZZ"; 

    -- IT is Square of ERROR
    error_tmp <= error_in * error_in;

    -- Converting Binary to Seven segment pattern
    seven_seg:bin_to_7seg 
		Port map( 
				din => seg_in,
		          dis_out => error_led_out_tmp
			    );

	-- Negative logic out
	seg_dis_out <= not error_led_out_tmp;

	-- MULTIPLEXED DISPLAY thats why ..
	m1:mux 
	port map(in1 => error_tmp(3 downto 0),
		    in2 => error_tmp(7 downto 4),
		    in3 => error_tmp(11 downto 8),
		    in4 => error_tmp(15 downto 12),
		    sel => seg_sel,	-- Changing with fast clock
		    o_ut => seg_in
  		   );

	-- NUMBER to FREQ Generator (1 bit Analog)
	d_to_a:d_a
		port map(
			   clk => clock,
			   data_in => error_tmp,	-- 16 bit
			   an_out => an_out,	-- 1 bit
			   reset => reset
			  );

end mixed;
--************ END *******-----