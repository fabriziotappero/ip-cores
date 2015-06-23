-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Present decoder with suitable key generator for decoding  ----
---- (basing on given encode key).                                 ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PresentFullDecoder is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_32: integer := 32;
			w_64: integer := 64;
			w_80: integer := 80
	);
	port(
		ciphertext : in std_logic_vector(w_64 - 1 downto 0);
		key		  : in std_logic_vector(w_80 - 1 downto 0);
		plaintext  : out std_logic_vector(w_64 - 1 downto 0);
		start, clk, reset : in std_logic;
		ready : out std_logic		
	);
end PresentFullDecoder;

architecture Behavioral of PresentFullDecoder is

-- Key generator component
component PresentEncKeyGen is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_80: integer := 80
	);
	port(
		key		: in std_logic_vector(w_80 - 1 downto 0);
		key_end	: out std_logic_vector(w_80 - 1 downto 0);		
		start, clk, reset : in std_logic;
		ready : out std_logic		
	);
end component PresentEncKeyGen;

-- 'pure' Present decoder
component PresentDec is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_32: integer := 32;
			w_64: integer := 64;
			w_80: integer := 80
	);
	port(
		plaintext  : in std_logic_vector(w_64 - 1 downto 0);
		key		  : in std_logic_vector(w_80 - 1 downto 0);
		ciphertext : out std_logic_vector(w_64 - 1 downto 0);		
		start, clk, reset : in std_logic;
		ready : out std_logic		
	);
end component PresentDec;

component FullDecoderSM is
	port(
		key_gen_start : out std_logic;
		key_gen_ready : in std_logic;
		decode_start  : out std_logic;
		decode_ready  : in std_logic;
		full_decoder_start :in std_logic;
		full_decoder_ready : out std_logic;
		clk, reset  :in std_logic
	);
end component FullDecoderSM;

-- signals

signal key_gen_output : std_logic_vector(w_80 - 1 downto 0);

signal key_gen_start : std_logic;
signal key_gen_ready : std_logic;

signal decode_start  : std_logic;
signal decode_ready  : std_logic;

begin

    -- connections

	keyGen : PresentEncKeyGen 
		port map(
			key 		=> key,
			key_end	=> key_gen_output,
			start		=> key_gen_start,
			clk		=> clk,
			reset		=> reset,
			ready		=> key_gen_ready
	);

	decoder : PresentDec
		port map(
			plaintext	=> ciphertext,
			key			=> key_gen_output,
			ciphertext	=> plaintext,
			start			=> decode_start,
			clk			=> clk,
			reset			=> reset,
			ready 		=> decode_ready
	);

	SM : FullDecoderSM
		port map(
			key_gen_start => key_gen_start,
			key_gen_ready => key_gen_ready,
			decode_start  => decode_start,
			decode_ready  => decode_ready,
			full_decoder_start => start,
			full_decoder_ready => ready,
			clk => clk,
			reset => reset
	);

end Behavioral;
