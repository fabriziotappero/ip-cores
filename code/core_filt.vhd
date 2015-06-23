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


-- A.7
-- Filter core for adaptive equalizer
-- Five tap filter
-- structuaral description

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity core_filt is
    Port ( 
    		 x_in : in std_logic_vector(7 downto 0);
           x_N_in : in std_logic_vector(7 downto 0);
           ue_in : in std_logic_vector(7 downto 0);
           clock : in std_logic;
           y_out : out std_logic_vector(7 downto 0));
end core_filt;

architecture pm_chain of core_filt is

		-- basic tap processing element
		component unit_calc
	     Port ( x_in : in std_logic_vector(7 downto 0);
	           x_N_in : in std_logic_vector(7 downto 0);
	           ue_in : in std_logic_vector(7 downto 0);
	           y_in : in std_logic_vector(7 downto 0);
	           x_out : out std_logic_vector(7 downto 0);
	           x_N_out : out std_logic_vector(7 downto 0);
	           ue_out : out std_logic_vector(7 downto 0);
			 y_out: out std_logic_vector(7 downto 0);
	           clock : in std_logic);
		end component ;


	signal x_out_t1  :std_logic_vector(7 downto 0);
	signal x_out_t2  :std_logic_vector(7 downto 0);
	signal x_out_t3  :std_logic_vector(7 downto 0);
	signal x_out_t4  :std_logic_vector(7 downto 0);

	signal x_N_out_t1  :std_logic_vector(7 downto 0);
	signal x_N_out_t2  :std_logic_vector(7 downto 0);
	signal x_N_out_t3  :std_logic_vector(7 downto 0);
	signal x_N_out_t4  :std_logic_vector(7 downto 0);

 	signal ue_out_t1  :std_logic_vector(7 downto 0);
 	signal ue_out_t2  :std_logic_vector(7 downto 0);
 	signal ue_out_t3  :std_logic_vector(7 downto 0);
 	signal ue_out_t4  :std_logic_vector(7 downto 0);

 	signal y_out_t1  :std_logic_vector(7 downto 0);
 	signal y_out_t2  :std_logic_vector(7 downto 0);
 	signal y_out_t3  :std_logic_vector(7 downto 0);
 	signal y_out_t4  :std_logic_vector(7 downto 0);

 

begin

   tap1: unit_calc
   port map (
 		      x_in 	=> x_in,
       		 x_N_in 	=> x_N_in,
			 ue_in  	=> ue_in,
			 y_in 	=> "00000000",
			 x_out	=> x_out_t1,
			 x_N_out	=> x_N_out_t1,
			 ue_out 	=> ue_out_t1,
			 y_out 	=> y_out_t1,
			 clock 	=> clock
           );
   tap2: unit_calc
   port map (
 		      x_in 	=> x_out_t1,
       		 x_N_in 	=> x_N_out_t1,
			 ue_in  	=> ue_out_t1,
			 y_in 	=> y_out_t1,
			 x_out	=> x_out_t2,
			 x_N_out	=> x_N_out_t2,
			 ue_out 	=> ue_out_t2,
			 y_out 	=> y_out_t2,
			 clock 	=> clock
           );
   tap3: unit_calc
   port map (
 		      x_in 	=> x_out_t2,
       		 x_N_in 	=> x_N_out_t2,
			 ue_in  	=> ue_out_t2,
			 y_in 	=> y_out_t2,
			 x_out	=> x_out_t3,
			 x_N_out	=> x_N_out_t3,
			 ue_out 	=> ue_out_t3,
			 y_out 	=> y_out_t3,
			 clock 	=> clock
           );
   tap4: unit_calc
   port map (
 		      x_in 	=> x_out_t3,
       		 x_N_in 	=> x_N_out_t3,
			 ue_in  	=> ue_out_t3,
			 y_in 	=> y_out_t3,
			 x_out	=> x_out_t4,
			 x_N_out	=> x_N_out_t4,
			 ue_out 	=> ue_out_t4,
			 y_out 	=> y_out_t4,
			 clock 	=> clock
         );
   tap5: unit_calc
   port map (
 		      x_in 	=> x_out_t4,
       		 x_N_in 	=> x_N_out_t4,
			 ue_in  	=> ue_out_t4,
			 y_in 	=> y_out_t4,
			 x_out	=> open,
			 x_N_out	=> open,
			 ue_out 	=> open,
			 y_out 	=> y_out,
			 clock 	=> clock
           );




end pm_chain;
