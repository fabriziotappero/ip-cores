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

-- A.8
-- unit program module of filter core
-- we have to cascade instance of this module to make multi tap filter


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity unit_calc is
    Port ( x_in : in std_logic_vector(7 downto 0);
           x_N_in : in std_logic_vector(7 downto 0);
           ue_in : in std_logic_vector(7 downto 0);
           y_in : in std_logic_vector(7 downto 0);
           x_out : out std_logic_vector(7 downto 0);
           x_N_out : out std_logic_vector(7 downto 0);
           ue_out : out std_logic_vector(7 downto 0);
		 y_out: out std_logic_vector(7 downto 0);
           clock : in std_logic);

end unit_calc;

architecture standard of unit_calc is
	-- component declarations
	-- 8 bit multiplier 
	component mul8
	    Port ( d1_in : in std_logic_vector(7 downto 0);
	           d2_in : in std_logic_vector(7 downto 0);
	           d_out : out std_logic_vector(15 downto 0));

	end component;
	-- 16 bit adder
	component add16
	    Port ( d1_in : in std_logic_vector(15 downto 0);
	           d2_in : in std_logic_vector(15 downto 0);
	           d_out : out std_logic_vector(15 downto 0));

	end component;

	-- saturation circuit
	component saturation 
     	Port ( d_in : in std_logic_vector(15 downto 0);
           	  d_out : out std_logic_vector(15 downto 0));
	end component;

	-- u scaling circuit
	component u_scaling 
	    Port ( d_in : in std_logic_vector(15 downto 0);
	           d_out : out std_logic_vector(15 downto 0);
			 clock : in std_logic);
	end component;

	-- truncation circuit	
	component truncation 
	    Port ( d_in : in std_logic_vector(15 downto 0);
	           d_out : out std_logic_vector(7 downto 0));
	end component;
	-- one sample delay
	component shift_1d 
	    Port ( xin : in std_logic_vector(7 downto 0);
	           xout : out std_logic_vector(7 downto 0);
	           clock : in std_logic);
	end component;
	
	-- shift regester
	component shift_1d_16 
	    Port ( xin : in std_logic_vector(15 downto 0);
	           xout : out std_logic_vector(15 downto 0);
	           clock : in std_logic);
	end component;


	signal shiftx: std_logic_vector(31 downto 0);
	signal shiftxn: std_logic_vector(31 downto 0);
	signal shiftue: std_logic_vector(23 downto 0);
	signal shifty: std_logic_vector(15 downto 0);

     signal coeff8: std_logic_vector(7 downto 0);
	signal coeff16:std_logic_vector(15 downto 0);
	signal xnin_ue:std_logic_vector(15 downto 0);
	signal xnin_ue_scaled:std_logic_vector(15 downto 0);
	signal new_coeff_true:std_logic_vector(15 downto 0);
	signal delayed_new_coeff_true:std_logic_vector(15 downto 0);
	signal y_out16:std_logic_vector(15 downto 0);
	signal y_out8:std_logic_vector(7 downto 0);
begin
	-- basic pipelining 
	unit_process:
	process (clock)
	begin
		if(clock'event and clock = '1') then

			shiftx <= x_in & shiftx(31 downto 8);
			shiftxn <= x_N_in & shiftxn(31 downto 8);
			shiftue <= ue_in & shiftue(23 downto 8);
			shifty <= y_in & shifty(15 downto 8);

   		end if;
	end process;

	x_out <= shiftx(7 downto 0);
	x_N_out <= shiftxn(7 downto 0);
	ue_out <= shiftue(7 downto 0);

    mul_xnin_ue: mul8	   -- no delay
    port map( d1_in => x_N_in,
              d2_in => ue_in,
              d_out => xnin_ue);

    u1:u_scaling		   -- 1 clock cycle
    port map(	d_in  => xnin_ue,
			d_out => xnin_ue_scaled,
			clock => clock
    				);

    add1:add16			  -- no delay
    port map(	d1_in => xnin_ue_scaled,
              	d2_in => coeff16,
              	d_out => new_coeff_true
			);

    delay_2:shift_1d_16	   -- each clock
    port map( 	clock => clock,
    		    	xin => new_coeff_true,
		   	xout => delayed_new_coeff_true	
    			);

    
    sat_1:saturation
    port map(	d_in  => delayed_new_coeff_true,
    			d_out => coeff16
    				);
    trunc_1:truncation
    port map(
    			d_in  => coeff16,
    			d_out => coeff8	
    		   );
    	
    mul_coeff_x_in:mul8
    port map( d1_in => coeff8,
              d2_in => shiftx(31 downto 24),
              d_out => y_out16
		    );
    trunc_2:truncation
    port map(
    			d_in  => y_out16,
    			d_out => y_out8	
    		   );
    y_out <= y_out8 + shifty(7 downto 0);
end standard;

