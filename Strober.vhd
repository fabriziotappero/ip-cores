library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
 
entity Strober is
    port (reset, clk : in  std_logic;
       strobe : in std_logic;
       sample : in std_logic;
       env_col : in col;
       env_row : out row;
       sample_col : out col; --rows and cols to be analysed
       sample_row_number : out row_number
       );
    
end Strober;

architecture Strober_arc of Strober is

function decode_row(inp: row_number) return row is
variable rowstrobe : row;
begin
	case inp is
	when 11 => rowstrobe := "011111111111";
	when 10 => rowstrobe := "101111111111";
	when 9 => rowstrobe :=  "110111111111";
	when 8 => rowstrobe :=  "111011111111";
	when 7 => rowstrobe :=  "111101111111";
	when 6 => rowstrobe :=  "111110111111";
	when 5 => rowstrobe :=  "111111011111";
	when 4 => rowstrobe :=  "111111101111";
	when 3 => rowstrobe :=  "111111110111";
	when 2 => rowstrobe :=  "111111111011";
	when 1 => rowstrobe :=  "111111111101";
	when 0 => rowstrobe :=  "111111111110";
	when others => rowstrobe := "111111111111";
	end case;
	return rowstrobe;
end decode_row;
    
begin
   
   strober: process
   variable row_counter : integer;   
   begin
       wait until rising_edge(clk);
       if (reset = '1') then
           env_row <= "111111111111";
           row_counter := 0;       
       elsif (strobe = '1') then
           if (row_counter < number_of_cols-1) then
           	row_counter := row_counter + 1;
           elsif(row_counter = number_of_cols-1)then
           	row_counter := 0;
           end if;
           env_row <= decode_row(row_counter);           
       elsif (sample ='1') then --first sample
           sample_row_number <= row_counter;
           sample_col <= not env_col;
       end if;
   end process;
      
end strober_arc;
    
    


