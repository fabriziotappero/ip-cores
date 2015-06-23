-- optimized version of a 10 tap FIR hilbert filter
-- The impulse response is h={-0.1066 0 -0.1781 0 -0.5347 0  0.5347 0 0.1781 0 0.1066}
--
-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

package hilbert_filter_pkg is
  component hilbert_filter
    generic(
      input_data_width : integer;
      output_data_width : integer;
      internal_data_width : integer
    );
    port( 
      clk         : in  std_logic; 
      clk_enable  : in  std_logic; 
      reset       : in  std_logic; 
      filter_in   : in  std_logic_vector(15 downto 0); -- sfix16_en15
      filter_out  : out std_logic_vector(15 downto 0)  -- sfix16_en10
    );
  end component; 
end hilbert_filter_pkg;

package body hilbert_filter_pkg is
end hilbert_filter_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.resize_tools_pkg.all;

entity hilbert_filter is
  generic(
    input_data_width : integer := 16;
    output_data_width : integer := 16;
    internal_data_width : integer := 16
  );
  port( 
    clk         : in  std_logic; 
    clk_enable  : in  std_logic; 
    reset       : in  std_logic; 
    filter_in   : in  std_logic_vector(15 downto 0); -- sfix16_en15
    filter_out  : out std_logic_vector(15 downto 0)  -- sfix16_en10
  );

end hilbert_filter;


architecture hilbert_filter_arch of hilbert_filter is

constant no_of_coefficients : integer := 3;

constant h0_real : real := -32.0/256.0; -- -0.106635588611691;
constant h2_real : real := -54.0/256.0;-- -0.178063554399423;
constant h4_real : real := -163.0/256.0;-- -0.534697271169593;

constant h0_int : std_logic_vector(internal_data_width-1 downto 0) := std_logic_vector(to_signed(integer(h0_real * 2.0**(internal_data_width-1)),internal_data_width));  
constant h2_int : std_logic_vector(internal_data_width-1 downto 0) := std_logic_vector(to_signed(integer(h2_real * 2.0**(internal_data_width-1)),internal_data_width));  
constant h4_int : std_logic_vector(internal_data_width-1 downto 0) := std_logic_vector(to_signed(integer(h4_real * 2.0**(internal_data_width-1)),internal_data_width));  


type xmh_type is array(0 to no_of_coefficients-1) of std_logic_vector(internal_data_width-1 downto 0);
signal xmh : xmh_type;  --x mult with coeff. h
signal xmhd : xmh_type; --xmh delayed one clock

signal xmhd0inv : std_logic_vector(internal_data_width-1 downto 0);
signal xmhd0invd : std_logic_vector(internal_data_width-1 downto 0);
signal xmhd0invdd : std_logic_vector(internal_data_width-1 downto 0);

type tmp_type is array(0 to no_of_coefficients) of std_logic_vector(internal_data_width-1 downto 0);
signal t : tmp_type;    --temporary signal ater each addition
signal td : tmp_type;   --t delayed one clock
signal tdd : tmp_type;  --t delayed two clocks

signal y : std_logic_vector(internal_data_width-1 downto 0);

begin

  xmh(0) <= std_logic_vector(shift_left(signed(resize_to_msb_trunc(filter_in,internal_data_width/2)) * signed(resize_to_msb_round(h0_int,internal_data_width/2)),1));
  xmh(1) <= std_logic_vector(shift_left(signed(resize_to_msb_trunc(filter_in,internal_data_width/2)) * signed(resize_to_msb_round(h2_int,internal_data_width/2)),1));
  xmh(2) <= std_logic_vector(shift_left(signed(resize_to_msb_trunc(filter_in,internal_data_width/2)) * signed(resize_to_msb_round(h4_int,internal_data_width/2)),1));

  xmhd0inv <= std_logic_vector(to_signed(-1 * to_integer(signed(xmhd(0))),internal_data_width));

  t(0) <= std_logic_vector(signed(xmhd0invdd) - signed(xmhd(1)));
  t(1) <= std_logic_vector(signed(tdd(0)) - signed(xmhd(2)));
  t(2) <= std_logic_vector(signed(tdd(1)) + signed(xmhd(2)));
  t(3) <= std_logic_vector(signed(tdd(2)) + signed(xmhd(1)));
  y <= std_logic_vector(signed(tdd(3)) + signed(xmhd(0)));

  process (clk, reset)
  begin
	  if reset = '1' then
      for i in 0 to no_of_coefficients-1 loop
        xmhd(i) <= (others => '0');
      end loop;
      for i in 0 to no_of_coefficients loop
        td(i) <= (others => '0');
        tdd(i) <= (others => '0');
      end loop;
      xmhd0invd <= (others => '0');
      xmhd0invdd <= (others => '0');
      filter_out <= (others => '0');
	  elsif clk'event and clk = '1' then
	    if clk_enable = '1' then	
        for i in 0 to no_of_coefficients-1 loop
          xmhd(i) <= xmh(i);
        end loop;
        for i in 0 to no_of_coefficients loop
          td(i) <= t(i);
          tdd(i) <= td(i);
        end loop;
        xmhd0invd <= xmhd0inv;
        xmhd0invdd <= xmhd0invd;
        filter_out <= resize_to_msb_trunc(y,output_data_width);
      end if;
    end if;
  end process; 
  
end hilbert_filter_arch;
