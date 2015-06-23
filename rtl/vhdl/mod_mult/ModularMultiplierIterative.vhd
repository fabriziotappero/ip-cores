-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   Montgomery modular multiplier main module. It combines all  ----
----   subomponents. It takes two numbers and modulus as the input ----
----   and returns the Montgomery product A*B*(R^{-1}) mod M       ----
----   where R^{-1} is the modular multiplicative inverse.         ----
----   R*R^{-1} == 1 mod M                                         ----
----   R = 2^word_length mod M                                     ----
----               and word_length is the binary width of the      ----
----               operated word (in this case 64 bit)             ----
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
use IEEE.NUMERIC_STD.ALL;
use work.properties.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModularMultiplierIterative is
    generic (
	     word_size : integer := WORD_LENGTH
    );
    port (
        A       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- multiplicand
		  B       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- multiplier
		  M       : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);     -- modulus
		  start   : in  STD_LOGIC;
		  product : out STD_LOGIC_VECTOR(word_size - 1 downto 0); -- product
		  ready   : out STD_LOGIC;
		  clk     : in  STD_LOGIC
    );
end ModularMultiplierIterative;

architecture Behavioral of ModularMultiplierIterative is

-- Multiplexer
component MontMult4inMux is
    generic (
	     word_size : integer := WORD_LENGTH
	 );
    port ( 
	     ctrl   : in  STD_LOGIC_VECTOR(1 downto 0);
	     zero   : in  STD_LOGIC_VECTOR(word_size downto 0);
        M      : in  STD_LOGIC_VECTOR(word_size downto 0);
        Y      : in  STD_LOGIC_VECTOR(word_size downto 0);
        YplusM : in  STD_LOGIC_VECTOR(word_size downto 0);
		  output : out STD_LOGIC_VECTOR(word_size downto 0)
    );
end component MontMult4inMux;

-- State machine
component ModMultIter_SM is
    generic (
	     word_size : integer := WORD_LENGTH
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
end component ModMultIter_SM;

-- Signals
signal Mi              : STD_LOGIC_VECTOR(word_size downto 0);
signal Yi              : STD_LOGIC_VECTOR(word_size downto 0);
signal sumYM           : STD_LOGIC_VECTOR(word_size downto 0);
signal zero_sig        : STD_LOGIC_VECTOR(word_size downto 0) := (others => '0');
signal four_in_mux_out : STD_LOGIC_VECTOR(word_size downto 0);

signal mux_4in_ctrl_sig  : STD_LOGIC_VECTOR(1 downto 0);
signal mult_mux_ctrl_sig : STD_LOGIC;

signal mult_mux_out     : STD_LOGIC_VECTOR(word_size downto 0);
signal out_reg_sig      : STD_LOGIC_VECTOR(word_size downto 0);
signal product_sig      : STD_LOGIC_VECTOR(word_size downto 0);
signal out_en           : STD_LOGIC;

signal sum_mult_out     : STD_LOGIC_VECTOR(word_size + 1 downto 0);
signal sum_div_2        : STD_LOGIC_VECTOR(word_size downto 0);

begin
     zero_sig <= (others => '0'); -- '0'
	 -- 'widening' to store the intermediate steps
	 Mi <= '0' & M;
	 Yi <= '0' & B;
	 
	 -- Operations needed to compute the Montgomery multiplications
	 sum_div_2 <= sum_mult_out(word_size + 1 downto 1);
	 sum_mult_out <= ('0' & four_in_mux_out) + ('0' & mult_mux_out);
	 sumYM <= ('0' & B) + ('0' & M);

	 -- Multiplexer component
	 four_in_mux : MontMult4inMux port map(
	     ctrl => mux_4in_ctrl_sig, zero => zero_sig, M => Mi, Y => Yi,
        YplusM => sumYM, output => four_in_mux_out
	 );

	 -- Two input asynchronuos multiplexer for output 'not clear' code due to
	 -- 'historical works'
	 mult_mux_out <= (others => '0') when (mult_mux_ctrl_sig = '0') else
	           out_reg_sig;

	 -- State machine
	 state_machine : ModMultIter_SM port map(
        x => A, 
		  start => start, 
		  clk => clk, 
		  s_0 => out_reg_sig(0),
		  y_0 => B(0), 
		  ready => ready, 
		  out_reg_en => out_en, 
		  mux_mult_ctrl => mult_mux_ctrl_sig, 
		  mux_4in_ctrl => mux_4in_ctrl_sig
	 );
	 
	     -- Register like structure for signal synchronous work
	 	 clock : process(clk, start)
	     begin
		      if (clk = '1' and clk'Event) then
				    if (start = '0') then
				        out_reg_sig <= (others => '0');
					 elsif out_en = '1' then
						  out_reg_sig <= sum_div_2;
					end if;
			   end if;
		  end process clock;
		  
		  -- One additional 'subtract' component which was added after
		  -- first experiments with Montgomery multiplication. It was
		  -- observed that sometimes intermediate step can be higher 
		  -- than modulus. In this situation 'M' substraction is 
		  -- compulsory
		  product_proc : process(clk, Mi, out_reg_sig)
		  begin
				if(out_reg_sig < ("0" & Mi)) then
					 product_sig <= out_reg_sig;
				else
					 product_sig <= out_reg_sig - Mi;
				end if;
		  end process product_proc;
		  product <= product_sig(word_size - 1 downto 0);

end Behavioral;