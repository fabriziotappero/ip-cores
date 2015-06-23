library ieee;
use ieee.std_logic_1164.all;

package z80soc_pack is
	
	constant vid_cols			: integer := 40; -- video number of columns
	constant vid_lines		: integer := 30; -- video number of lines
	constant vram_base_addr		: std_logic_vector(15 downto 0) := x"4000";
	constant pixelsxchar		: integer := 1;

end  z80soc_pack;