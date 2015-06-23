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

entity colorconv is
generic(DATA_WIDTH	: INTEGER);
port	(
	clk				:	IN STD_LOGIC;
	rstn			:	IN STD_LOGIC;

	DATA_ENA		:	IN STD_LOGIC;
	DOUT_RDY		:	OUT STD_LOGIC;

	-- input vector
	x1				:	IN UNSIGNED( data_width-1 downto 0 );
	x2				:	IN UNSIGNED( data_width-1 downto 0 );
	x3				:	IN UNSIGNED( data_width-1 downto 0 );

	-- matrix factors
	a11,a12,a13		:	IN SIGNED( FACTORS_WIDTH-1 downto 0 );
	a21,a22,a23		:	IN SIGNED( FACTORS_WIDTH-1 downto 0 );
	a31,a32,a33		:	IN SIGNED( FACTORS_WIDTH-1 downto 0 );

	--shift vectors
	b1x,b2x,b3x		:	IN SIGNED( FACTORS_WIDTH-1 downto 0 );
	b1y,b2y,b3y		:	IN SIGNED( FACTORS_WIDTH-1 downto 0 );

	-- output vector
	y1c				:	OUT SIGNED( int_factors_part-1 downto 0 );
	y2c				:	OUT SIGNED( int_factors_part-1 downto 0 );
	y3c				:	OUT SIGNED( int_factors_part-1 downto 0 );
	y1				:	OUT UNSIGNED( data_width-1 downto 0 );
	y2				:	OUT UNSIGNED( data_width-1 downto 0 );
	y3				:	OUT UNSIGNED( data_width-1 downto 0 )
);
end colorconv;

architecture a of colorconv is

-- the result full width will be
signal m11, m12, m13		: SIGNED( (data_width+factors_width) downto 0 );
signal m21, m22, m23		: SIGNED( (data_width+factors_width) downto 0 );
signal m31, m32, m33		: SIGNED( (data_width+factors_width) downto 0 );

signal x1sh, x2sh, x3sh		: SIGNED( data_width downto 0 );

signal x1s, x2s, x3s		: SIGNED( data_width downto 0 );

signal y1s, y2s, y3s		: SIGNED( data_width+int_factors_part-1 downto 0 );

signal y1sh, y2sh, y3sh		: SIGNED( data_width+int_factors_part-1 downto 0 );

signal y1r,  y2r,  y3r		: SIGNED( data_width+int_factors_part-1 downto 0 );

signal y1ro, y2ro,  y3ro	: SIGNED( data_width+int_factors_part-1 downto 0 );

signal s1w, s2w, s3w		: SIGNED( (data_width+factors_width) downto 0 );

signal d1, d2, d3			: SIGNED( (data_width+factors_width) downto 0 );

signal y1w,y2w,y3w			: SIGNED( (data_width+factors_width) downto 0 );

signal pipe_delay			: STD_LOGIC_VECTOR( 7 downto 0 );

begin

x1s <= '0' & Signed(x1);
x2s <= '0' & Signed(x2);
x3s <= '0' & Signed(x3);

process(clk, rstn)
begin
	if rstn = '0' then

		m11	 <= (others=>'0');
		m12	 <= (others=>'0');
		m13	 <= (others=>'0');
		m21	 <= (others=>'0');
		m22	 <= (others=>'0');
		m23	 <= (others=>'0');
		m31	 <= (others=>'0');
		m32	 <= (others=>'0');
		m33	 <= (others=>'0');

		s1w	 <= (others=>'0');
		s2w	 <= (others=>'0');
		s3w	 <= (others=>'0');

		d1	  <= (others=>'0');
		d2	  <= (others=>'0');
		d3	  <= (others=>'0');

		y1w	 <= (others=>'0');
		y2w	 <= (others=>'0');
		y3w	 <= (others=>'0');

		y1sh <= (others=>'0');
		y2sh <= (others=>'0');
		y3sh <= (others=>'0');

		y1ro <=	 (others=>'0');
		y2ro <=	 (others=>'0');
		y3ro <=	 (others=>'0');

	elsif rising_edge(clk) then

		x1sh <= x1s+b1x(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);
		x2sh <= x2s+b2x(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);
		x3sh <= x3s+b3x(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);

		m11 <= a11 * x1sh;
		m12 <= a12 * x2sh;
		m13 <= a13 * x3sh;
		m21 <= a21 * x1sh;
		m22 <= a22 * x2sh;
		m23 <= a23 * x3sh;
		m31 <= a31 * x1sh;
		m32 <= a32 * x2sh;
		m33 <= a33 * x3sh;

		s1w <= m11 + m12;
		s2w <= m21 + m22;
		s3w <= m31 + m32;

		d1 <= m13;
		d2 <= m23;
		d3 <= m33;

		y1w <= s1w + d1;
		y2w <= s2w + d2;
		y3w <= s3w + d3;
		
		y1s(data_width+int_factors_part-1 downto data_width) <= y1w(data_width+int_factors_part+f_factors_part-1 downto data_width+f_factors_part);
		y2s(data_width+int_factors_part-1 downto data_width) <= y2w(data_width+int_factors_part+f_factors_part-1 downto data_width+f_factors_part);
		y3s(data_width+int_factors_part-1 downto data_width) <= y3w(data_width+int_factors_part+f_factors_part-1 downto data_width+f_factors_part);

		y1s(data_width-1 downto 0) <= y1w(data_width+f_factors_part-1 downto f_factors_part);
		y2s(data_width-1 downto 0) <= y2w(data_width+f_factors_part-1 downto f_factors_part);
		y3s(data_width-1 downto 0) <= y3w(data_width+f_factors_part-1 downto f_factors_part);

		y1sh <= y1s + b1y(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);
		y2sh <= y2s + b2y(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);
		y3sh <= y3s + b3y(FACTORS_WIDTH-1 DOWNTO FACTORS_WIDTH-DATA_WIDTH-1);
		
		y1r <= y1sh+y1w(f_factors_part-1);
		y2r <= y2sh+y2w(f_factors_part-1);
		y3r <= y3sh+y3w(f_factors_part-1);

		if    (y1r(data_width+int_factors_part-1)='1' and y1r(data_width)='1')then y1ro(data_width-1 downto 0)<=(others=>'0');
		elsif (y1r(data_width+int_factors_part-1)='0' and y1r(data_width)='1')then y1ro(data_width-1 downto 0)<=(others=>'1');
		else y1ro<=y1r;
		end if;

		if    (y2r(data_width+int_factors_part-1)='1' and y2r(data_width)='1')then y2ro(data_width-1 downto 0)<=(others=>'0');
		elsif (y2r(data_width+int_factors_part-1)='0' and y2r(data_width)='1')then y2ro(data_width-1 downto 0)<=(others=>'1');
		else y2ro<=y2r;
		end if;

		if    (y3r(data_width+int_factors_part-1)='1' and y3r(data_width)='1')then y3ro(data_width-1 downto 0)<=(others=>'0');
		elsif (y3r(data_width+int_factors_part-1)='0' and y3r(data_width)='1')then y3ro(data_width-1 downto 0)<=(others=>'1');
		else y3ro<=y3r;
		end if;

	end if;
end process;

y1c <= y1r(data_width+int_factors_part-1 downto data_width);
y2c <= y2r(data_width+int_factors_part-1 downto data_width);
y3c <= y3r(data_width+int_factors_part-1 downto data_width);

y1 <= UNSIGNED(y1ro(data_width-1 downto 0));
y2 <= UNSIGNED(y2ro(data_width-1 downto 0));
y3 <= UNSIGNED(y3ro(data_width-1 downto 0));

-- this shift register is nessecary for generating RDY sig and easy integration with fifo
process(clk, rstn)
begin
	if rstn = '0' then
		pipe_delay <= (others=>'0');
	elsif rising_edge(clk) then
		pipe_delay(0) <= DATA_ENA;
		pipe_delay(7 downto 1) <= pipe_delay(6 downto 0);
	end if;
end process;

DOUT_RDY <= pipe_delay(7);


end a;
