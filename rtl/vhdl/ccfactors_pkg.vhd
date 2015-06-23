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
-- There is package with factors for different color convertions. 
-- Is used with mult3x3 matrix multiplier.
--
-- Source: "Digital Video and HDTV. Algorithms and Interfaces" 
--			Charles Poynton; ISBN 1-55860-792-7.
--
-- rev 1.0, 06.30.2006 		: Michael Tsvetkov (csimplemapi@mail.ru)
--
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package ccfactors_pkg is

	TYPE COLOR_CONVERTION IS (
		ComputerRGB_to_YCbCr601,
		YCbCr601_to_ComputerRGB,
		StudioRGB_to_YCbCr601,
		YCbCr601_to_StudioRGB,
		ComputerRGB_to_YCbCr709,
		YCbCr709_to_ComputerRGB,
		StudioRGB_to_YCbCr709,
		YCbCr709_to_StudioRGB,
		YCbCr709_to_YCbCr601,
		YCbCr601_to_YCbCr709,
		YUV601_to_YIQ601,
		StudioRGB_to_YIQ601,
		YIQ601_to_StudioRGB,
		ComputerRGB_to_YCgCo,
		YCgCo_to_ComputerRGB
	);
	CONSTANT F_FACTORS_PART	 : INTEGER := 15; -- float part width, 10-E4 accuracy
	CONSTANT INT_FACTORS_PART: INTEGER := 3;  -- integer part with, from -5 to +4 range (-4.999999 to 3.999999)

	CONSTANT FACTORS_WIDTH   : integer := (f_factors_part + int_factors_part); -- full factor width	

	-----------------------------------------------------------------------------------			
	-- Matrix factors for the Computer RGB to Rec.601 (SD) YCbCr color convertion 
	-----------------------------------------------------------------------------------
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

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.601 YCbCr to Computer RGB color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr601_crgb_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001011"; --  1.16438
	constant ycbcr601_crgb_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_crgb_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001100110001001010"; --  1.59603
	constant ycbcr601_crgb_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001011"; --  1.16438
	constant ycbcr601_crgb_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100110111011010"; -- -0.391762
	constant ycbcr601_crgb_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111001011111110000"; -- -0.812969
	constant ycbcr601_crgb_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001011"; --  1.16438
	constant ycbcr601_crgb_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000001000110100"; --  2.01723
	constant ycbcr601_crgb_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr601_crgb_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -16
	constant ycbcr601_crgb_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128
	constant ycbcr601_crgb_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128

	constant ycbcr601_crgb_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_crgb_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_crgb_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------			
	-- Matrix factors for the Studio RGB to Rec.601 (SD) YCbCr color convertion 
	-----------------------------------------------------------------------------------							
	constant srgb2ycbcr601_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010011001000110"; --  0.299000
	constant srgb2ycbcr601_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100101100100011"; --  0.587000
	constant srgb2ycbcr601_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000111010011000"; --  0.114000
 	constant srgb2ycbcr601_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110100111101001"; -- -0.172586
	constant srgb2ycbcr601_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101010010100001"; -- -0.338828
	constant srgb2ycbcr601_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000101110110"; --  0.511414
	constant srgb2ycbcr601_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000101110110"; --  0.511414
	constant srgb2ycbcr601_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100100100101111"; -- -0.428246
	constant srgb2ycbcr601_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111010101011011"; -- -0.083168

	constant srgb2ycbcr601_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2ycbcr601_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2ycbcr601_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant srgb2ycbcr601_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; -- 16
	constant srgb2ycbcr601_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128
	constant srgb2ycbcr601_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.601 YCbCr to Studio RGB color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr601_srgb_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr601_srgb_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_srgb_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001010111101110011"; --  1.37071
	constant ycbcr601_srgb_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr601_srgb_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101010011101111"; -- -0.336453
	constant ycbcr601_srgb_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111010011010100010"; -- -0.698195
	constant ycbcr601_srgb_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr601_srgb_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001101110111000001"; --  1.73245
	constant ycbcr601_srgb_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr601_srgb_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -16
	constant ycbcr601_srgb_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128
	constant ycbcr601_srgb_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128

	constant ycbcr601_srgb_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_srgb_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_srgb_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------			
	-- Matrix factors for the Computer RGB to Rec.709 (HD) YCbCr color convertion 
	-----------------------------------------------------------------------------------
	constant crgb2ycbcr709_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000001011101011111"; --  0.182586
	constant crgb2ycbcr709_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100111010011111"; --  0.614230
	constant crgb2ycbcr709_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000011111110000"; --  0.062008
 	constant crgb2ycbcr709_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111001100011110"; -- -0.100645
	constant crgb2ycbcr709_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101010010101010"; -- -0.338570
	constant crgb2ycbcr709_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000011100000111000"; --  0.439215
	constant crgb2ycbcr709_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000011100000111000"; --  0.439215
	constant crgb2ycbcr709_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100110011110000"; -- -0.398941
	constant crgb2ycbcr709_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111101011011000"; -- -0.040273

	constant crgb2ycbcr709_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant crgb2ycbcr709_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant crgb2ycbcr709_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant crgb2ycbcr709_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; --  16
	constant crgb2ycbcr709_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; --  128
	constant crgb2ycbcr709_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; --  128

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.709 YCbCr to Computer RGB color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr709_crgb_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001010"; --  1.16438
	constant ycbcr709_crgb_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_crgb_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001110010101111001"; --  1.79274
	constant ycbcr709_crgb_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001010"; --  1.16438
	constant ycbcr709_crgb_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110010010110011"; -- -0.213250
	constant ycbcr709_crgb_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111011101111001010"; -- -0.532910
	constant ycbcr709_crgb_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001001010100001010"; --  1.16438
	constant ycbcr709_crgb_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000111001100011"; --  2.11240
	constant ycbcr709_crgb_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr709_crgb_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -16
	constant ycbcr709_crgb_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128
	constant ycbcr709_crgb_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128

	constant ycbcr709_crgb_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0
	constant ycbcr709_crgb_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0
	constant ycbcr709_crgb_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0

   -----------------------------------------------------------------------------------			
	-- Matrix factors for the Studio RGB to Rec.709 (HD) YCbCr color convertion 
	-----------------------------------------------------------------------------------
	constant srgb2ycbcr709_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000001101100110111"; --  0.212602
	constant srgb2ycbcr709_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000101101110001100"; --  0.715199
	constant srgb2ycbcr709_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000100100111110"; --  0.072199
 	constant srgb2ycbcr709_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111000100000000"; -- -0.117188
	constant srgb2ycbcr709_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100110110001010"; -- -0.394227
	constant srgb2ycbcr709_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000101110110"; --  0.511414
	constant srgb2ycbcr709_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000101110110"; --  0.511414
	constant srgb2ycbcr709_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100010010001011"; -- -0.464523
	constant srgb2ycbcr709_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111100111111111"; -- -0.046895

	constant srgb2ycbcr709_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2ycbcr709_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2ycbcr709_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant srgb2ycbcr709_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; -- 16
	constant srgb2ycbcr709_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128
	constant srgb2ycbcr709_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.709 YCbCr to Studio RGB color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr709_srgb_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr709_srgb_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_srgb_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001100010100010011"; --  1.53965
	constant ycbcr709_srgb_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr709_srgb_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110100010001111"; -- -0.183145
	constant ycbcr709_srgb_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100010101101011"; -- -0.457676
	constant ycbcr709_srgb_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr709_srgb_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001110100000110111"; --  1.81418
	constant ycbcr709_srgb_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr709_srgb_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -16
	constant ycbcr709_srgb_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128
	constant ycbcr709_srgb_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128

	constant ycbcr709_srgb_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_srgb_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_srgb_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.709 YCbCr to Rec.601 YCbCr color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr709_ycbcr601_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr709_ycbcr601_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000110010110110"; --  0.099312
	constant ycbcr709_ycbcr601_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000001100010001010"; --  0.1917
	constant ycbcr709_ycbcr601_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000111111010110100"; --  0.989854
	constant ycbcr709_ycbcr601_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111000111010110"; -- -0.110653
	constant ycbcr709_ycbcr601_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111011010111010"; -- -0.072453
	constant ycbcr709_ycbcr601_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000111110111100000"; --  0.983398

	constant ycbcr709_ycbcr601_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr709_ycbcr601_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr709_ycbcr601_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.601 YCbCr to Rec.709 YCbCr color convertion 
	-----------------------------------------------------------------------------------
	constant ycbcr601_ycbcr709_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycbcr601_ycbcr709_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111111000100110110"; -- -0.11555
	constant ycbcr601_ycbcr709_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110010101100010"; -- -0.207938
	constant ycbcr601_ycbcr709_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000001001100011"; --  1.01864
	constant ycbcr601_ycbcr709_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000111010101100"; --  0.114618 
	constant ycbcr601_ycbcr709_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000100110011011"; --  0.075049
	constant ycbcr601_ycbcr709_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000001100111110"; --  1.025327

	constant ycbcr601_ycbcr709_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant ycbcr601_ycbcr709_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycbcr601_ycbcr709_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.601 YUV to Rec.601 YIQ color convertion 
	-----------------------------------------------------------------------------------
	constant yuv601_yiq601_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant yuv601_yiq601_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
   constant yuv601_yiq601_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111011101001001001"; -- -0.544639
	constant yuv601_yiq601_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000110101101011010"; --  0.838671 
	constant yuv601_yiq601_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000110101101011010"; --  0.838671
	constant yuv601_yiq601_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100010110110111"; --  0.544639

	constant yuv601_yiq601_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant yuv601_yiq601_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yuv601_yiq601_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Studio RGB to Rec.601 YIQ color convertion 
	-----------------------------------------------------------------------------------
	constant srgb2yiq601_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010011001000110"; --  0.299
	constant srgb2yiq601_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100101100100011"; --  0.587
	constant srgb2yiq601_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000111010011000"; --  0.114
	constant srgb2yiq601_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100110001000111"; --  0.595901
	constant srgb2yiq601_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101110011011011"; -- -0.274557
	constant srgb2yiq601_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101011011011110"; -- -0.321344 
	constant srgb2yiq601_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000001101100010100"; --  0.211537
	constant srgb2yiq601_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111011110100010111"; -- -0.522736
	constant srgb2yiq601_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010011111010101"; --  0.3112

	constant srgb2yiq601_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2yiq601_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2yiq601_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant srgb2yiq601_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2yiq601_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant srgb2yiq601_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	-----------------------------------------------------------------------------------
	-- Matrix factors for the Rec.601 YIQ to Studio RGB convertion 
	-----------------------------------------------------------------------------------
	constant yiq601_srgb_a11	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant yiq601_srgb_a12	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000111101001011110"; --  0.955986
	constant yiq601_srgb_a13	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100111101110111"; --  0.620825
	constant yiq601_srgb_a21	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant yiq601_srgb_a22	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111101110100101111"; -- -0.272013
	constant yiq601_srgb_a23	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111010110100101000"; -- -0.647204 
	constant yiq601_srgb_a31	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant yiq601_srgb_a32	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110111001001010110"; -- -1.106740
	constant yiq601_srgb_a33	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001101101000100100"; --  1.704230

	constant yiq601_srgb_b1x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yiq601_srgb_b2x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yiq601_srgb_b3x	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant yiq601_srgb_b1y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yiq601_srgb_b2y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant yiq601_srgb_b3y	 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

   
   -----------------------------------------------------------------------------------
	-- Matrix factors for the Computer RGB to YCgCo convertion 
	-----------------------------------------------------------------------------------
   constant crgb2ycgco_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; --  0.25
	constant crgb2ycgco_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000000000000"; --  0.50
	constant crgb2ycgco_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; --  0.25
 	constant crgb2ycgco_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000000000000"; --  0.50
	constant crgb2ycgco_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant crgb2ycgco_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111100000000000000"; -- -0.50
	constant crgb2ycgco_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -0.25
	constant crgb2ycgco_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000100000000000000"; --  0.50
	constant crgb2ycgco_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -0.25

	constant crgb2ycgco_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant crgb2ycgco_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant crgb2ycgco_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0

	constant crgb2ycgco_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000010000000000000"; -- 16
	constant crgb2ycgco_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128
	constant crgb2ycgco_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"010000000000000000"; -- 128

   -----------------------------------------------------------------------------------
	-- Matrix factors for the YCgCo to Computer RGB convertion 
	-----------------------------------------------------------------------------------
   constant ycgco2crgb_a11 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycgco2crgb_a12 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycgco2crgb_a13 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111000000000000000"; -- -1
 	constant ycgco2crgb_a21 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycgco2crgb_a22 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; --  0
	constant ycgco2crgb_a23 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycgco2crgb_a31 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"001000000000000000"; --  1
	constant ycgco2crgb_a32 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111000000000000000"; -- -1 
	constant ycgco2crgb_a33 : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111000000000000000"; -- -1

	constant ycgco2crgb_b1x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"111110000000000000"; -- -16
	constant ycgco2crgb_b2x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128
	constant ycgco2crgb_b3x : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"110000000000000000"; -- -128

	constant ycgco2crgb_b1y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0
	constant ycgco2crgb_b2y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0
	constant ycgco2crgb_b3y : SIGNED(FACTORS_WIDTH-1 DOWNTO 0) := b"000000000000000000"; -- 0


end ccfactors_pkg;


---------------------------------------------------------------
---------------------------------------------------------------

package body ccfactors_pkg is
end ccfactors_pkg;
