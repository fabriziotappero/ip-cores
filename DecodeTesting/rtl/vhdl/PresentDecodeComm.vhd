-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Top level part of 'pure' Present decode with RS-232       ----
---- communication with PC. It contains all suitable components    ----
---- with links between each others. For more informations see     ----
---- below and http://homes.esat.kuleuven.be/~abogdano/papers/     ----
---- present_ches07.pdf                                            ----
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

entity PresentDecodeComm is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_64: integer := 64;
			w_80: integer := 80
	);
	port (
		DATA_RXD : in  STD_LOGIC;
		CLK		: in  STD_LOGIC;
		RESET		: in  STD_LOGIC;
		DATA_TXD	: out STD_LOGIC
	);
end PresentDecodeComm;

architecture Behavioral of PresentDecodeComm is

-- Shift register is used for translation 8 bit input of RS-232 data (both RXD and TXD)
-- 64 bit and 80 bit data in dependence of the data type (key, text, result). SM ocntrols it
-- If data are not fully retrieved, last received data are shifted by 8 bits. This is repeated
-- 8 times for text and output value (8 x 8 bits) or 10 times (10 x 8 bits) for key.
-- Width of the word is fully configurable.
component ShiftReg is
	generic (
		length_1      : integer :=  8;
		length_2      : integer :=  w_64;
		internal_data : integer :=  w_64
	);
	port ( 
		input  : in  STD_LOGIC_VECTOR(length_1 - 1 downto 0);
		output : out STD_LOGIC_VECTOR(length_2 - 1 downto 0);
		en     : in  STD_LOGIC;
		shift  : in  STD_LOGIC;
		clk    : in  STD_LOGIC;
		reset  : in  STD_LOGIC
	);
end component ShiftReg;

-- Component given by Digilent in Eval board for RS-232 communication
component Rs232RefComp is
    Port ( 
		TXD 	: out std_logic  	:= '1';
    	RXD 	: in  std_logic;					
    	CLK 	: in  std_logic;								--Master Clock
		DBIN 	: in  std_logic_vector (7 downto 0);	--Data Bus in
		DBOUT : out std_logic_vector (7 downto 0);	--Data Bus out
		RDA	: inout std_logic;						--Read Data Available
		TBE	: inout std_logic 	:= '1';			--Transfer Bus Empty
		RD		: in  std_logic;					--Read Strobe
		WR		: in  std_logic;					--Write Strobe
		PE		: out std_logic;					--Parity Error Flag
		FE		: out std_logic;					--Frame Error Flag
		OE		: out std_logic;					--Overwrite Error Flag
		RST		: in  std_logic	:= '0');	--Master Reset
end component Rs232RefComp;

-- Present decoder - nothing special
component PresentFullDecoder is
	generic (
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
end component PresentFullDecoder;

-- State machine
component PresentDecodeCommSM is
	port (
		clk				: in STD_LOGIC;
		reset				: in STD_LOGIC;
		RDAsig			: in STD_LOGIC;
		TBEsig			: in STD_LOGIC;
		RDsig				: out STD_LOGIC;
		WRsig				: out STD_LOGIC;
		textDataEn     : out STD_LOGIC;
		textDataShift	: out STD_LOGIC;
		keyDataEn		: out STD_LOGIC;
		keyDataShift	: out STD_LOGIC;
		ciphDataEn     : out STD_LOGIC;
		ciphDataShift  : out STD_LOGIC;
		startSig			: out STD_LOGIC;
		readySig			: in STD_LOGIC
	);
end component PresentDecodeCommSM;

--Signals
signal keyText    : STD_LOGIC_VECTOR(w_80 - 1 downto 0);
signal plaintext  : STD_LOGIC_VECTOR(w_64 - 1 downto 0);
signal ciphertext : STD_LOGIC_VECTOR(w_64 - 1 downto 0);

signal dataTXD : STD_LOGIC_VECTOR(7 downto 0);
signal dataRXD : STD_LOGIC_VECTOR(7 downto 0);
signal RDAsig  : STD_LOGIC;
signal TBEsig  : STD_LOGIC;
signal RDsig   : STD_LOGIC;
signal WRsig   : STD_LOGIC;
signal PEsig   : STD_LOGIC;
signal FEsig   : STD_LOGIC;
signal OEsig   : STD_LOGIC;

signal keyDataEn    : STD_LOGIC;
signal keyDataShift : STD_LOGIC;

signal textDataEn    : STD_LOGIC;
signal textDataShift : STD_LOGIC;

signal ciphDataEn    : STD_LOGIC;
signal ciphDataShift : STD_LOGIC;

signal startSig : STD_LOGIC;
signal readySig : STD_LOGIC;

begin

    -- Connections
	RS232 : Rs232RefComp
		Port map( 
			TXD 	=> DATA_TXD,
			RXD 	=> DATA_RXD,
			CLK 	=> clk,
			DBIN 	=> dataTXD,
			DBOUT => dataRXD,
			RDA	=> RDAsig,
			TBE	=> TBEsig,
			RD		=> RDsig,
			WR		=> WRsig,
			PE		=> PEsig,
			FE		=> FEsig,
			OE		=> OEsig,
			RST	=> reset
		);

	textReg : ShiftReg
		generic map(
			length_1 => 8,
			length_2 => w_64,
			internal_data => w_64
		)
		port map( 
			input  => dataRXD,
			output => plaintext,
			en     => textDataEn,
			shift  => textDataShift,
			clk    => clk,
			reset  => reset
		);

	keyReg : ShiftReg
		generic map(
			length_1 => 8,
			length_2 => w_80,
			internal_data => w_80
		)
		port map( 
			input  => dataRXD,
			output => keyText,
			en     => keyDataEn,
			shift  => keyDataShift,
			clk    => clk,
			reset  => reset
		);

	present :PresentFullDecoder
		port map(
			ciphertext 	=> plaintext,
			key		 	=> keyText,
			plaintext	=> ciphertext,
			start			=> startSig,
			clk			=> clk,
			reset			=> reset,
			ready			=> readySig
		);

	outReg : ShiftReg
		generic map(
			length_1 => w_64,
			length_2 => 8,
			internal_data => w_64
		)
		port map( 
			input  => ciphertext,
			output => dataTXD,
			en     => ciphDataEn,
			shift  => ciphDataShift,
			clk    => clk,
			reset  => reset
		);

	SM : PresentDecodeCommSM 
		port map(
			clk				=> clk,
			reset				=> reset,
			RDAsig			=> RDAsig,
			TBEsig			=> TBEsig,
			RDsig				=> RDsig,
			WRsig				=> WRsig,
			textDataEn     => textDataEn,
			textDataShift	=> textDataShift,
			keyDataEn		=> keyDataEn,
			keyDataShift	=> keyDataShift,
			ciphDataEn     => ciphDataEn,
			ciphDataShift  => ciphDataShift,
			startSig			=> startSig,
			readySig			=> readySig
		);

end Behavioral;

