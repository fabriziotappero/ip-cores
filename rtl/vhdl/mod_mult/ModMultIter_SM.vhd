-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   This is state machine for the modular multiplier it consists----
----   of three states, NOP the preparation stage, CALCULATE_START ----
----   for the modular multiply and STOP for the presentation      ----
----   result.                                                     ----
----                                                               ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.properties.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModMultIter_SM is
    generic (
	     word_size : integer := WORD_LENGTH;
	     word_binary : integer := WORD_INTEGER
	 );
    port(
        x             : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);
		  start         : in  STD_LOGIC;
		  clk           : in  STD_LOGIC;
		  s_0           : in  STD_LOGIC;
		  y_0           : in  STD_LOGIC;
		  ready         : out STD_LOGIC;
		  out_reg_en    : out STD_LOGIC;
		  mux_mult_ctrl : out STD_LOGIC;
		  mux_4in_ctrl  : out STD_LOGIC_VECTOR(1 downto 0)
	 );
end ModMultIter_SM;

architecture Behavioral of ModMultIter_SM is

signal state            : multiplier_states := NOP;
signal next_state       : multiplier_states := NOP;	
signal position_counter : STD_LOGIC_VECTOR(word_binary downto 0) := (others => '0');
signal shift_reg        : STD_LOGIC_VECTOR(word_size - 1 downto 0) := (others => '0');

signal q : STD_LOGIC;

begin
    q <= (shift_reg(0) and y_0) xor s_0;
    mux_4in_ctrl <= shift_reg(0) & q;
    
	 SM : process(state, start, position_counter)
	     begin
				case state is
				    -- Prepare for the Montgomery iterations
				    when NOP =>
					     ready <= '0';
					     if (start = '1') then
								next_state <= CALCULATE_START;
								out_reg_en <= '1';
		                  mux_mult_ctrl <= '1';
						  else
						      out_reg_en <= '0';
		                  mux_mult_ctrl <= '0';
								next_state <= NOP;
						  end if;
					 -- State for the calculations of the Montgomery iterations
					 when CALCULATE_START =>
						      mux_mult_ctrl <= '1';
								ready <= '0';
							  -- End of iterations (counter contains the 'word_size' number)
						      if (position_counter = (word_size - 1)) then
								    out_reg_en <= '0';
									 next_state <= STOP;
							   -- Calculation process
							   else
								    out_reg_en <= '1';
								    next_state <= CALCULATE_START;
								end if;
					 -- End of the calculations
					 when STOP =>
					     ready <= '1';
					     mux_mult_ctrl <= '1';
						  out_reg_en <= '0';
					     if (start = '1') then
								next_state <= STOP;
						  else 
						      next_state <= NOP;
						  end if;
			   end case;
		  end process SM;

	-- Shift register enabling proper calculations of the all Montgomery iterations
    shift : process (clk, state)
	 begin
	     if (clk = '0' and clk'Event) then
			   if (state = CALCULATE_START) then
					 shift_reg <= shift_reg(0) & shift_reg(word_size - 1 downto 1);
			   else
					 shift_reg <= x;
			   end if;
		  end if;
	 end process shift;

	-- Process for the state change between each clock tick
    state_control : process (clk, start)
        begin
            if (start = '0') then
                    state <= NOP;
					 elsif (clk = '1' and clk'Event) then
                    state <= next_state;
            end if;
        end process state_control;

    -- Counter for controlling the number of the montgomery iterations during counting
    couner_modifier : process (clk)
	     begin
		      if (clk = '1' and clk'Event) then
					if (state = CALCULATE_START) then
						 position_counter <= position_counter + 1;
					else
						 position_counter <= (others => '0');
					end if;
				end if;
		  end process couner_modifier;
end Behavioral;