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


-- A.6 tf_lms.vhd
-- Adaptive equalizer routine
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity tf_lms is
    Port ( 
    		 xin : in std_logic_vector(7 downto 0);	  -- data input
    		 dxin : in std_logic_vector(7 downto 0);  -- desired response input
           clock : in std_logic;				  -- clock
		 err:out std_logic_vector(7 downto 0);	  -- error output
           yout : out std_logic_vector(7 downto 0); -- output data		
		 adapt_en: in std_logic		 		  -- enable adaption
	     );
end tf_lms;

architecture structural of tf_lms is

	-- filter core 
	component core_filt
	    Port ( 
	    		 x_in : in std_logic_vector(7 downto 0);
	           x_N_in : in std_logic_vector(7 downto 0);
	           ue_in : in std_logic_vector(7 downto 0);
	           clock : in std_logic;
	           y_out : out std_logic_vector(7 downto 0));
	end component ;

	-- shift regesters
	component shift_21d 
	    Port ( xin : in std_logic_vector(7 downto 0);
	           x_N_out : out std_logic_vector(7 downto 0);
			 x_1_out : out std_logic_vector(7 downto 0);
	           clock : in std_logic);
	end component;

	component shift_20d 
	    Port ( xin : in std_logic_vector(7 downto 0);
	           xout : out std_logic_vector(7 downto 0);
	           clock : in std_logic);
	end component;

	signal e,e_t,y_o,x_1,x_N:std_logic_vector(7 downto 0);

begin

	-- if Adaption is not enabled then ERROR signal is ZERO
	with adapt_en select 
		e <= y_o - e_t when '1',
			"00000000" when others;

	err <= e;
	
	shift_1:shift_20d
	   	port map (
				  xin => dxin,
				  xout => e_t,
				  clock => clock
			    );

	shift_2:shift_21d
	   	port map (
				  xin => xin,
				  x_N_out =>x_N,
				  x_1_out =>x_1,
				  clock => clock
			    );

	cflt: core_filt 
	   	port map (  
			       x_in   => x_1,
			       x_N_in => x_N,
				  ue_in  => e,
				  y_out  => y_o,
				  clock  => clock
	     	    );

	yout <= y_o;
end structural;
