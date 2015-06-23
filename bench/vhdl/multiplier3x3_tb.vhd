-- ***** BEGIN LICENSE BLOCK *****
----------------------------------------------------------------------
----                                                              ----
----  True matrix 3x3 multiplication IP Core                      ----
----                                                              ----
---- This file is part of the matrix 3x3 multiplier project       ----
---- http://www.opencores.org/projects.cgi/web/matrix3x3/         ----
----                                                              ----
---- Description                                                  ----
---- True matrix 3x3 multiplier									  ----
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


-----------------------------------------------------------------------------------
--
-- There is testbench for the myltiplier3x3. Converion realized by multiplication
-- of shifted vectors and matrix of factors, and shift of result of multiplication.
--
-- Input  stimulus are read from the "X.txt" file - pure ASCII coded data.
-- Output results are written to the "Y.txt" file - pure ASCII coded data.
-- See Matlab's m-file "read_image.m" in ./fv/ dir for generating input stimulus from
-- the real image.
--
-- Simulator software - ModelSim 6.1.
--
-----------------------------------------------------------------------------------

LIBRARY ieee;
LIBRARY std_developerskit;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE IEEE.std_logic_arith.all;
USE std_developerskit.std_iopak.all;

entity tb is
end tb;

ARCHITECTURE a OF tb IS 

CONSTANT DATA_WIDTH		: INTEGER :=8;

CONSTANT IMAGE_WIDTH	: INTEGER := 198;
CONSTANT ROW_NUMBER		: INTEGER := 135;

CONSTANT CLOCK_PERIOD	: TIME := 50 ns;

CONSTANT F_FACTORS_PART	 : INTEGER := 15; -- float part width, 10-E4 accuracy
CONSTANT INT_FACTORS_PART: INTEGER := 3;  -- integer part with, from -5 to +4 range (-4.999999 to 3.999999)
CONSTANT FACTORS_WIDTH   : integer := (f_factors_part + int_factors_part); -- full factor width	


constant crgb2ycbcr601_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000011011111"; --  0.256789
constant crgb2ycbcr601_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000010000110"; --  0.504129
constant crgb2ycbcr601_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000110010001000"; --  0.0979
constant crgb2ycbcr601_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110110100000111"; -- -0.148223
constant crgb2ycbcr601_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101101011000001"; -- -0.290992
constant crgb2ycbcr601_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000011100000111000"; --  0.439215
constant crgb2ycbcr601_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000011100000111000"; --  0.439215
constant crgb2ycbcr601_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101000011101100"; -- -0.367789
constant crgb2ycbcr601_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111011011011100"; -- -0.071426

constant crgb2ycbcr601_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
constant crgb2ycbcr601_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
constant crgb2ycbcr601_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

constant crgb2ycbcr601_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; -- 16
constant crgb2ycbcr601_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128
constant crgb2ycbcr601_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128

SIGNAL clk				: STD_LOGIC;
SIGNAL rstn				: STD_LOGIC;

SIGNAL x1,x2,x3			: UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
SIGNAL x1bv,x2bv,x3bv	: BIT_VECTOR(DATA_WIDTH-1 DOWNTO 0);

SIGNAL y1,y2,y3			: UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
SIGNAL y1c,y2c,y3c		: SIGNED(INT_FACTORS_PART-1 DOWNTO 0);
SIGNAL y1bv,y2bv,y3bv	: BIT_VECTOR(DATA_WIDTH-1 DOWNTO 0);

SIGNAL DATA_ENA			: STD_LOGIC;
SIGNAL DOUT_RDY			: STD_LOGIC;


BEGIN

---------- READ_DATA FROM FILE PROCESS --------------------------
READ_DATA: PROCESS(CLK, RSTN)
	FILE file_in			: ASCII_TEXT IS  "X.txt";
	VARIABLE digits_str1	: string(1 to 3);
	VARIABLE digits_str2	: string(1 to 3);
	VARIABLE digits_str3	: string(1 to 3);
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
WRITE_RESULT: PROCESS(CLK, RSTN) 
    	FILE file_out      	: ASCII_TEXT IS OUT "Y.txt";    
    	VARIABLE digit_out1	: string(1 to 2):=(others=>'0');
    	VARIABLE digit_out2 	: string(1 to 2):=(others=>'0');
    	VARIABLE digit_out3 	: string(1 to 2):=(others=>'0');
	VARIABLE i,k		: INTEGER;
BEGIN

	if RSTN = '0' THEN 
		i := 0;k:=1;       
    	elsif rising_edge(clk) then 
		if DOUT_RDY = '1' then
		   if k<=ROW_NUMBER then 
       	    i:=i+1;
       	    digit_out1 :=To_string(y1bv,"%2x");
            digit_out2 :=To_string(y2bv,"%2x");
            digit_out3 :=To_string(y3bv,"%2x");        
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

	mult : entity work.multiplier3x3(a)
	GENERIC MAP(
                 DATA_WIDTH,
                 F_FACTORS_PART,
                 INT_FACTORS_PART
              )
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
   wait ;
END PROCESS RESET;

    
END a;
	
				