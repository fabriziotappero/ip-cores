-- ***** BEGIN LICENSE BLOCK *****
----------------------------------------------------------------------
----                                                              ----
----  Color Converter IP Core 					                  ----
----                                                              ----
---- This file is part of the matrix 3x3 multiplier project       ----
---- http://www.opencores.org/projects.cgi/web/color_converter/   ----
----                                                              ----
---- Description                                                  ----
---- True matrix 3x3 color converter							  ----
---- 		                                                      ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Michael Tsvetkov, michland@opencores.org                   ----
---- - Vyacheslav Gulyaev, vv_gulyaev@opencores.org               ----	
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2006 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/lgpl.txt or  write to the   ----
---- Free Software Foundation, Inc., 51 Franklin Street,          ----
---- Fifth Floor, Boston, MA  02110-1301  USA                     ----
----                                                              ----
----------------------------------------------------------------------
-- * ***** END LICENSE BLOCK ***** */



-----------------------------------------------------------------------
--
-- There is testbench for different color conversions by the mult3x3 component.
-- 
-- Input  stimulus are read from the "X.txt" file - pure ASCII coded data.
-- Output results are written to the "Y.txt" file - pure ASCII coded data.
-- See Matlab's m-file "read_image.m" in ./fv/ dir for generating input stimulus from
-- the real image. Also Matlab is used for formal verification: comparing mult3x3 results
-- with matlab's functions "rgb2ycbcr" and "ycbcr2rgb" for data_width = 8 bit and
-- conversions ComputerRGB_to_YCbCr601 and YCbCr601_to_ComputerRGB.
--
-- Simulator software - ModelSim 6.1.
--
-----------------------------------------------------------------------

LIBRARY ieee;
LIBRARY std_developerskit;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE IEEE.std_logic_arith.all;
USE std_developerskit.std_iopak.all;
use work.ccfactors_pkg.all;
entity tb is
end tb;

ARCHITECTURE a OF tb IS 

-- select matrix factors for predefined convertions. See ccfactors_pkg.
CONSTANT DATA_WIDTH		:	INTEGER :=8;
CONSTANT CONVERTION		:	COLOR_CONVERTION := ComputerRGB_to_YCbCr601;

SIGNAL FORMAT_STR		:	string(1 to 3) :="%2x";

-- for "onion.png" image from Matlab7 installation
CONSTANT IMAGE_WIDTH	:	INTEGER := 198;
CONSTANT ROW_NUMBER		:	INTEGER := 135;
CONSTANT CLOCK_PERIOD	:	TIME := 50 ns;

SIGNAL clk				:	STD_LOGIC;
SIGNAL rstn				:	STD_LOGIC;

SIGNAL x1,x2,x3			:	UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
SIGNAL x1bv,x2bv,x3bv	:	BIT_VECTOR(DATA_WIDTH-1 DOWNTO 0);

SIGNAL y1,y2,y3			:	UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
SIGNAL y1c,y2c,y3c		:	SIGNED(INT_FACTORS_PART-1 DOWNTO 0);
SIGNAL y1bv,y2bv,y3bv	:	BIT_VECTOR(DATA_WIDTH-1 DOWNTO 0);

SIGNAL DATA_ENA			:	STD_LOGIC;
SIGNAL DOUT_RDY			:	STD_LOGIC;


BEGIN

---------- READ_DATA FROM FILE PROCESS --------------------------
READ_DATA: PROCESS(CLK, RSTN)
	FILE file_in			:	ASCII_TEXT IS  "X.txt";
	VARIABLE digits_str1	:	string(1 to (DATA_WIDTH/4)+1);
	VARIABLE digits_str2	:	string(1 to (DATA_WIDTH/4)+1);
	VARIABLE digits_str3	:	string(1 to (DATA_WIDTH/4)+1);
BEGIN

	if RSTN = '0' THEN
		DATA_ENA <= '0';
	elsif rising_edge(clk) then

		if NOT endfile(file_in) THEN

			fscan (file_in, "%x %x %x", digits_str1, digits_str2, digits_str3);

			if digits_str1(1) /= NUL then
				x1bv <= From_HexString (digits_str1);
				x2bv <= From_HexString (digits_str2);
				x3bv <= From_HexString (digits_str3);
			end if;

			DATA_ENA <= '1';

		ELSE
			DATA_ENA <= '0';
		END IF;
END IF;

END PROCESS READ_DATA;


---------- WRITE_RESULT TO FILE PROCESS --------------------------
o2: IF DATA_WIDTH/4 = 2 GENERATE
    FORMAT_STR <= "%2x";
END GENERATE o2;

o3: IF DATA_WIDTH/4 = 3 GENERATE
    FORMAT_STR <= "%3x";
END GENERATE o3;

o4: IF DATA_WIDTH/4 = 4 GENERATE
    FORMAT_STR <= "%4x";
END GENERATE o4;

WRITE_RESULT: PROCESS(CLK, RSTN)
	FILE file_out			:	ASCII_TEXT IS OUT "Y.txt";
	VARIABLE digit_out1		:	string(1 to (DATA_WIDTH/4)):=(others=>'0');
	VARIABLE digit_out2		:	string(1 to (DATA_WIDTH/4)):=(others=>'0');
	VARIABLE digit_out3		:	string(1 to (DATA_WIDTH/4)):=(others=>'0');
	VARIABLE i,k			:	INTEGER;
BEGIN

	if RSTN = '0' THEN
		i := 0;k:=1;
		elsif rising_edge(clk) then
			if DOUT_RDY = '1' then
				if k<=ROW_NUMBER then
					i:=i+1;

					digit_out1 :=To_string(y1bv,FORMAT_STR);
					digit_out2 :=To_string(y2bv,FORMAT_STR);
					digit_out3 :=To_string(y3bv,FORMAT_STR);

					fprint(file_out,"%s %s %s ", digit_out1, digit_out2, digit_out3);

			end if;

			if i = IMAGE_WIDTH then
				i := 0; k:=k+1;
				fprint(file_out,"\n");
			end if;
		end if;
	end if;
END PROCESS WRITE_RESULT;


x1 <= UNSIGNED(TO_STDLOGICVECTOR(x1bv));
x2 <= UNSIGNED(TO_STDLOGICVECTOR(x2bv));
x3 <= UNSIGNED(TO_STDLOGICVECTOR(x3bv));

y1bv<=To_Bitvector(STD_LOGIC_VECTOR(y1));
y2bv<=To_Bitvector(STD_LOGIC_VECTOR(y2));
y3bv<=To_Bitvector(STD_LOGIC_VECTOR(y3));

--------------------------------------------------------------------
-- instantiate the mult3x3_fullcomponent
--------------------------------------------------------------------

gen1:IF  CONVERTION = ComputerRGB_to_YCbCr601 GENERATE

	cconv : entity work.colorconv(a)
	GENERIC MAP( DATA_WIDTH)
	PORT MAP(
		clk	 => clk,
		rstn	 => rstn,
		data_ena => DATA_ENA,
		dout_rdy => DOUT_RDY,
		x1  => x1,
		x2  => x2,
		x3  => x3,
		a11 => crgb2ycbcr601_a11,
		a12 => crgb2ycbcr601_a12,
		a13 => crgb2ycbcr601_a13,
		a21 => crgb2ycbcr601_a21,
		a22 => crgb2ycbcr601_a22,
		a23 => crgb2ycbcr601_a23,
		a31 => crgb2ycbcr601_a31,
		a32 => crgb2ycbcr601_a32,
		a33 => crgb2ycbcr601_a33,
		b1x => crgb2ycbcr601_b1x,
		b2x => crgb2ycbcr601_b2x,
		b3x => crgb2ycbcr601_b3x,
		b1y => crgb2ycbcr601_b1y,
		b2y => crgb2ycbcr601_b2y,
		b3y => crgb2ycbcr601_b3y,
		y1c => y1c,
		y2c => y2c,
		y3c => y3c,
		y1  => y1,
		y2  => y2,
		y3  => y3
	);
END GENERATE gen1;

gen2:IF CONVERTION = YCbCr601_to_ComputerRGB GENERATE

	cconv : entity work.colorconv(a)
	GENERIC MAP( DATA_WIDTH )
	PORT MAP(
		clk	 => clk,
		rstn	 => rstn,
		data_ena => DATA_ENA,
		dout_rdy => DOUT_RDY,        
		x1  => x1,
		x2  => x2,
		x3  => x3,
		a11 => ycbcr601_crgb_a11,
		a12 => ycbcr601_crgb_a12,
		a13 => ycbcr601_crgb_a13,
		a21 => ycbcr601_crgb_a21,
		a22 => ycbcr601_crgb_a22,
		a23 => ycbcr601_crgb_a23,
		a31 => ycbcr601_crgb_a31,
		a32 => ycbcr601_crgb_a32,
		a33 => ycbcr601_crgb_a33,
		b1x => ycbcr601_crgb_b1x,
		b2x => ycbcr601_crgb_b2x,
		b3x => ycbcr601_crgb_b3x,
		b1y => ycbcr601_crgb_b1y,
		b2y => ycbcr601_crgb_b2y, 
		b3y => ycbcr601_crgb_b3y,
		y1c => y1c,
		y2c => y2c,
		y3c => y3c,
		y1  => y1,
		y2  => y2,
		y3  => y3
	);

END GENERATE gen2;
--------------------------------------------------------------------
-- clock and reset stuff
--------------------------------------------------------------------
CLOCK : PROCESS
BEGIN
	clk  <= '1'  ;
	wait for CLOCK_PERIOD/2;
	clk  <= '0'  ;
	wait for CLOCK_PERIOD/2 ;     
END PROCESS CLOCK;

RESET : PROCESS
BEGIN
	rstn<='0';
	wait for 10*CLOCK_PERIOD;
	rstn<='1';
	wait;
END PROCESS RESET;

END a;
