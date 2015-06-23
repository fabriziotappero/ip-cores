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

-- This File is Testing System For Equalizer
-- It Includes DATA generator Equalizer core and Error Display unit

-- File: 	Filt_test_system.vhd  
-- Developer: Digish K. Pandya
-- Test bench file test_filt_test_sys.vhd

-- Main Testing system for LMS adaptive filter
-- Synthesised and tested on SPARTAN II xc2s100-6qt144

--Libraries from vendor
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Pin Definations
entity filt_test_system is
    Port ( clock : in std_logic;
           error_led_out : out std_logic_vector(7 downto 0);
		 seg_select:out std_logic_vector(3 downto 0);
           error_freq_out : out std_logic;
           filt_data_out : out std_logic_vector(7 downto 0);
           reset : in std_logic;
           reset_clk : in std_logic;
           adaption_enable : in std_logic);
end filt_test_system;

-- Architecture body

architecture test_chip of filt_test_system is

    -- Component Declarations

    -- 1 LMS filter Transpose form Architecture 			
    component tf_lms
	    Port ( 
	    		 xin : in std_logic_vector(7 downto 0);	  -- data input
	    		 dxin : in std_logic_vector(7 downto 0);  -- desired response input
	           clock : in std_logic;				  -- clock
			 adapt_en: in std_logic;		 		  -- enable adaption

			 err:out std_logic_vector(7 downto 0);	  -- error output
	           yout : out std_logic_vector(7 downto 0)  -- output data		
		     );
    end component ;

    -- 2 Data generator system 
    component data_gen
	     Port ( 
			 clock : in std_logic;
	           reset : in std_logic;

	           xout : out std_logic_vector(7 downto 0);
	           dxout : out std_logic_vector(7 downto 0)
			);
	end component ;
	
	-- 3 Clock devider 
	-- Provides two clocks for different purpose
	component clock_div
		    Port ( reset: in std_logic;
		    		 in_clk : in std_logic;

		           out1 : out std_logic;  -- fast
		           out2 : out std_logic); -- slow
	end component;

	-- 4 Displays MSE on seven segment diplay
	component Display_MSE 
		    Port ( reset: in std_logic;
		    		 error_in : in std_logic_vector(7 downto 0);
		           clock : in std_logic;

				 an_out: out std_logic;
		           seg_select_out : out std_logic_vector(3 downto 0);
		           seg_dis_out : out std_logic_vector(7 downto 0));
	end component;

     -- global clock buffer primary (for input pin)
	-- [Not able to display linkage but available in RTL]
	component BUFGP
         port (I: in std_logic; O: out std_logic);
     end component;   
	-- clock buffer Secondary (for internal logic)
	-- [Not able to display linkage but available in RTL]
	component BUFGS
		port (I: in STD_LOGIC;O: out STD_LOGIC);
	end component;


	-- Local Interconnects 
	signal xout_tmp: std_logic_vector( 7 downto 0);
	signal dxout_tmp: std_logic_vector( 7 downto 0);
	signal clock_fast,clock_slow: std_logic;
	signal error_dis_in : std_logic_vector(7 downto 0);
	signal CLK_SIG,clock_f,clock_s:  std_logic;

begin
	-- Clock Input through buffer
	U1:  BUFGP port map (I => clock, O => CLK_SIG);
 
	-- Test DATA generator
	data_gen1: data_gen
		port map(
			
				clock => clock_slow,
		          reset => reset,
		          xout => xout_tmp,
		          dxout => dxout_tmp
			    );

	-- LMS core UNDER test
    lms:	tf_lms
	    Port map( 
		    		 xin => xout_tmp,
		    		 dxin => dxout_tmp,
		           clock => clock_slow,
				 err => error_dis_in,
		           yout => filt_data_out,
				 adapt_en => adaption_enable 
			  );


     -- Fast clock used to avoide flicker
	err_display:display_mse
		port map(
				 reset => reset,
				 error_in => error_dis_in,
		           clock => clock_fast,

				 an_out => error_freq_out,
		           seg_select_out => seg_select,
		           seg_dis_out => error_led_out 
				
				);


	-- Clock Devider
	cd: clock_div
		port map(
				reset => reset_clk,
				in_clk => clk_sig,
				out1 => clock_f, 
				out2 => clock_s  
				);

	-- Fast clock for Seven Segment Display refresh
	U2:  BUFGS port map (I => clock_f, O => clock_fast);

	-- Slow clock for Filtering (SO we can see changes in on Sevensegment)
	-- In actual application we have to keep maximum possible clock here
	U3:  BUFGS port map (I => clock_s, O => clock_slow);


end test_chip;
-- The End --