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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

use work.ccfactors_pkg.all;

entity colorconv_wb is
generic( DATA_WIDTH	 : INTEGER:=16);
port	(
	-- Data Bus (piped stream, our own bus) - x input and y output
	x_clk			   	: 	IN STD_LOGIC;
	x_rstn			   	: 	IN STD_LOGIC;

	x_we_i	  			: 	IN STD_LOGIC;
	y_rdy_o	   			: 	OUT STD_LOGIC;	

	-- input vector
	x1_i			    : 	IN UNSIGNED( data_width-1 downto 0 );
	x2_i			    : 	IN UNSIGNED( data_width-1 downto 0 );
	x3_i			    : 	IN UNSIGNED( data_width-1 downto 0 );
	
	-- output vector
	y1c_o			    : 	OUT SIGNED( int_factors_part-1 downto 0 );
	y2c_o			    : 	OUT SIGNED( int_factors_part-1 downto 0 );
	y3c_o	     		: 	OUT SIGNED( int_factors_part-1 downto 0 );

	y1_o		        : 	OUT UNSIGNED( data_width-1 downto 0 );
	y2_o	    	    : 	OUT UNSIGNED( data_width-1 downto 0 );
	y3_o	      	    : 	OUT UNSIGNED( data_width-1 downto 0 );

	-- Control Bus (WishBone Bus slave) - set factors and shifts regs for mult3x3
	wb_clk_i			: 	IN STD_LOGIC;
	wb_rst_i			: 	IN STD_LOGIC;
	wb_stb_i			: 	IN STD_LOGIC;
	wb_we_i				: 	IN STD_LOGIC;
	
	-- data bus
	wb_adr_i			: IN  STD_LOGIC_VECTOR (3 downto 0);
	wb_dat_i			: IN  STD_LOGIC_VECTOR (f_factors_part+int_factors_part-1 downto 0);
	wb_dat_o			: OUT STD_LOGIC_VECTOR (f_factors_part+int_factors_part-1 downto 0)
);
end colorconv_wb;

architecture a of colorconv_wb is

constant	factors_width	: integer := (f_factors_part + int_factors_part); -- one sign bit
--factors for rgb2ycbcr conversion
SIGNAL    a11		:	signed(factors_width-1 downto 0); 
SIGNAL    a12		:	signed(factors_width-1 downto 0); 
SIGNAL    a13		:	signed(factors_width-1 downto 0); 
SIGNAL    a21		:	signed(factors_width-1 downto 0); 
SIGNAL    a22		:	signed(factors_width-1 downto 0); 
SIGNAL    a23		:	signed(factors_width-1 downto 0); 
SIGNAL    a31		:	signed(factors_width-1 downto 0); 
SIGNAL    a32		:	signed(factors_width-1 downto 0); 
SIGNAL    a33		:	signed(factors_width-1 downto 0); 

--shift vectors for rgb2ycbcr conversion
SIGNAL	b1x		:	signed(factors_width-1 downto 0);
SIGNAL	b2x		:	signed(factors_width-1 downto 0);
SIGNAL	b3x		:	signed(factors_width-1 downto 0);
SIGNAL	b1y		:	signed(factors_width-1 downto 0);
SIGNAL	b2y		:	signed(factors_width-1 downto 0);
SIGNAL	b3y		:	signed(factors_width-1 downto 0);

COMPONENT colorconv

generic( DATA_WIDTH	 : INTEGER := 8);
port	(
	clk			   : 	IN STD_LOGIC;
	rstn		   : 	IN STD_LOGIC;

	DATA_ENA	   : 	IN STD_LOGIC;
	DOUT_RDY	   : 	OUT STD_LOGIC;	

	-- input vector
	x1			   : 	IN UNSIGNED( data_width-1 downto 0 );
	x2			   : 	IN UNSIGNED( data_width-1 downto 0 );
	x3			   : 	IN UNSIGNED( data_width-1 downto 0 );

	-- matrix factors
	a11,a12,a13	: 	IN SIGNED( factors_width-1 downto 0 );
	a21,a22,a23	: 	IN SIGNED( factors_width-1 downto 0 );
	a31,a32,a33	: 	IN SIGNED( factors_width-1 downto 0 );

	--shift vectors
	b1x,b2x,b3x : 	IN SIGNED( factors_width-1 downto 0 );
	b1y,b2y,b3y : 	IN SIGNED( factors_width-1 downto 0 );
		
	-- output vector
	y1c	      : 	OUT SIGNED( int_factors_part-1 downto 0 );
	y2c	      : 	OUT SIGNED( int_factors_part-1 downto 0 );
	y3c	      : 	OUT SIGNED( int_factors_part-1 downto 0 );

	y1	       : 	OUT UNSIGNED( data_width-1 downto 0 );
	y2	       : 	OUT UNSIGNED( data_width-1 downto 0 );
	y3	       : 	OUT UNSIGNED( data_width-1 downto 0 )
);
END COMPONENT ;

begin

	-- WB address decoder
	process(wb_clk_i, wb_rst_i)
	begin
		if wb_rst_i='1' then
			a11		<= (others=>'0');
			a12		<= (others=>'0');
			a13		<= (others=>'0');
			a21		<= (others=>'0');
			a22		<= (others=>'0');
			a23		<= (others=>'0');
			a31		<= (others=>'0');
			a32		<= (others=>'0');
			a33		<= (others=>'0');
			b1x		<= (others=>'0');
			b2x		<= (others=>'0');
			b3x		<= (others=>'0');
			b1y		<= (others=>'0');
			b2y		<= (others=>'0');
			b3y		<= (others=>'0');

		elsif rising_edge(wb_clk_i) then
			if wb_stb_i='1' then 
				if wb_we_i='1' then

					case wb_adr_i is
						when x"0" =>
							a11		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"1" =>
							a12		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"2" =>
							a13		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"3" =>
							a21		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"4" =>
							a22		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"5" =>
							a23		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"6" =>
							a31		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"7" =>
							a32		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"8" =>
							a33		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"9" =>
							b1x		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"A" =>
							b2x		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"B" =>
							b3x		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"C" =>
							b1y		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"D" =>
							b2y		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when x"E" =>
							b3y		<= SIGNED(wb_dat_i(factors_width-1 downto 0));
						when others => null;
					end case;

				else

					case wb_adr_i is
						when x"0" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a11);
						when x"1" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a12);
						when x"2" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a13);
						when x"3" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a21);
						when x"4" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a22);
						when x"5" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a23);
						when x"6" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a31);
						when x"7" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a32);
						when x"8" =>
							wb_dat_o	<= STD_LOGIC_VECTOR(a33);
						when x"9" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b1x);
						when x"A" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b2x);
						when x"B" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b3x);
						when x"C" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b1y);
						when x"D" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b2y);
						when x"E" =>
							wb_dat_o(factors_width-1 downto 0)	<= STD_LOGIC_VECTOR(b3y);
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;

	converter:colorconv
	GENERIC MAP( DATA_WIDTH)
	PORT MAP (x_clk, x_rstn, x_we_i, y_rdy_o,
				x1_i, x2_i, x3_i,
				a11, a12, a13,
				a21, a22, a23,
				a31, a32, a33,
				b1x, b2x, b3x,
				b1y, b2y, b3y,
				y1c_o, y2c_o, y3c_o,
				y1_o, y2_o, y3_o
				);
				
end a;
