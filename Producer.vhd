library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.sxt;
use work.Constants.all;
 
entity Producer is
	port (reset, clk: in  std_logic;
       produce : in std_logic;
       released : in std_logic;
       
       conv_col : in col_number;
       conv_row : in row_number;
       
       scanc : out scancode;
       interrupt : out std_logic
   );
    
end Producer;

architecture Producer_arc of Producer is

signal next_scanc: std_logic_vector(scancode_width-1 downto 0);

       
begin
   
   process(released, conv_row, conv_col)
       
       variable index: natural range 0 to 93;
		 variable tmp : std_logic_vector(6 downto 0);
       
   begin
		--make address out of col and row number of the pressed/released key
		tmp := std_logic_vector(to_unsigned(conv_row,4)) & std_logic_vector(to_unsigned(conv_col,3));
		index := to_integer(unsigned(tmp)); 
		--look-up scancode
		next_scanc <= set1_scancodes_lut(index);
		if (released='1') then
			next_scanc(scancode_width-1)<='1'; --add 0x80 for keyrelease scancode
		end if;
	end process;
   
	--put values in registers on next rising edge
   process
   begin
   wait until rising_edge(clk);
   if (reset='1') then
      scanc <= "00000000";
      interrupt <= '0';
   elsif(produce = '1') then
      scanc <= next_scanc;
      interrupt <= '1';
   else
      interrupt <= '0';
  	end if;
   end process;
   
end Producer_arc;