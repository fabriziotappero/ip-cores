library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
 
entity Analyser is
    port (reset, clk : in  std_logic;
       analyse : in std_logic;
		 store : in std_logic;
		 
		 debounced: out std_logic;    
       keychanged : out std_logic;
       released : out std_logic;
       
       sample_col : in col;
       sample_row_number : in row_number;
       
       conv_col : out col_number;
       conv_row : out row_number
       
       );
    
end Analyser;

architecture Analyser_arc of Analyser is
   

function ones_in_column(inp: col) return col_number is
variable number : col_number;
begin
    number := 0;
    for i in inp'range loop
       if inp(i)='1' then number := number+1;
       end if;
    end loop;
    return number;
end ones_in_column;

function ones_in_row(inp: row) return row_number is
variable number : row_number;
begin
    number := 0;
    for i in inp'range loop
       if inp(i)='1' then number := number + 1;
       end if;
    end loop;
    return number;
end ones_in_row;

function priority_encode(inp: col) return col_number is
variable tmp: col_number;
begin
    if inp(5)='1' then tmp:= 5;
    elsif inp(4)='1' then tmp:= 4;
    elsif inp(3)='1' then tmp:= 3;
    elsif inp(2)='1' then tmp:= 2;
    elsif inp(1)='1' then tmp:= 1;
    else tmp:= 0;
    end if;
    return tmp;
end priority_encode;


--reduce or function to look for key press in a column
function key_pressed(inp : row) return std_logic is
   variable tmp: std_logic;
begin
    tmp:='0';
    for i in inp'range loop
       tmp := tmp or inp(i);
    end loop;
    return tmp;
end key_pressed;

--function that checks whether the new key specified by col_number and row_number is valid
--large input is necessary to make it a legal function

function valid_key(colnum: col_number; rownum: row_number; row0:row; row1:row; row2:row; row3:row; row4:row; row5:row; keysdown: key_number) return std_logic is
variable colpress : col;
variable rowpress : row;
variable valid :std_logic;
  
begin
    valid := '1'; --valid until proven otherwise
    colpress := "000000";
    rowpress := "000000000000";
    
    colpress(0):= key_pressed(row0);
    colpress(1):= key_pressed(row1);
    colpress(2):= key_pressed(row2);
    colpress(3):= key_pressed(row3);
    colpress(4):= key_pressed(row4);
    colpress(5):= key_pressed(row5);
    
    for i in number_of_cols-1 downto 0 loop
    	rowpress(i) := row0(i) or row1(i)  or row2(i)  or row3(i)  or row4(i)  or row5(i);
    end loop;
    
    --add virtual key
    
    colpress(colnum) := '1';
    rowpress(rownum) := '1';
    
      
    if (keysdown >= max_keys_pressed) then  --too many keys pressed
       valid := '0';
    elsif (keysdown = 2) then --check for ghosting
       if (ones_in_column(colpress)=2 and ones_in_row(rowpress)=2) then 
          valid := '0';
       end if;
    end if;
   
    
    return valid;

end valid_key;

signal debounce_state : col;
signal keysdown : natural range 0 to max_keys_pressed ;
signal next_keysdown : natural range 0 to max_keys_pressed;
signal keychange : std_logic;
signal release : std_logic;
signal conv_col_number : col_number;
signal conv_row_number : row_number;
signal previous_sample : col; --last sampled column

signal row0 : row;
signal row1 : row;	
signal row2 : row;
signal row3 : row;
signal row4 : row;
signal row5 : row;

begin
    
		
	--look for valid keychange
	detector: process ( conv_col_number, conv_row_number, keysdown, row0, row1, row2, row3, row4, row5, sample_row_number, previous_sample)
	variable colpress : col_number;
	
	begin
	colpress := 0;
	if ((row0(sample_row_number) xor previous_sample(0))='1') then
	--change detected
	--keychange if valid or !pressed_down
			keychange <= (not previous_sample(0)) or valid_key(0, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(0);		 
			colpress := 0;
	elsif((row1(sample_row_number) xor previous_sample(1))='1') then
			keychange <= (not previous_sample(1)) or valid_key(1, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(1);		 
			colpress := 1;
	elsif((row2(sample_row_number) xor previous_sample(2))='1') then
			keychange <= (not previous_sample(2)) or valid_key(2, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(2);		 
			colpress := 2;
	elsif((row3(sample_row_number) xor previous_sample(3))='1') then
			keychange <= (not previous_sample(3)) or valid_key(3, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(3);		 
			colpress := 3;
	elsif((row4(sample_row_number) xor previous_sample(4))='1') then
			keychange <= (not previous_sample(4)) or valid_key(4, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(4);		 
			colpress := 4;
	elsif ((row5(sample_row_number) xor previous_sample(5))='1') then
			keychange <= (not previous_sample(5)) or valid_key(5, sample_row_number, row0, row1, row2, row3, row4, row5, keysdown);
			release <= not previous_sample(5);		 
			colpress := 5;
	else
			keychange <= '0';
			release <= '0';
	end if;
	
	conv_col_number <= colpress;
	conv_row_number <= sample_row_number;
	end process;

	next_keysdown <= keysdown+1 when keychange='1' and release='0'
							else
						  keysdown-1 when keychange='1' and release='1'
						  	else
						  keysdown;
						  
	storer:process 
	begin
	wait until rising_edge(clk);
	if (reset='1') then
	   row0 <= "000000000000";
		row1 <= "000000000000";
		row2 <= "000000000000";
		row3 <= "000000000000";
		row4 <= "000000000000";
		row5 <= "000000000000";
		keychanged <= '0';
		released <= '0';
		keysdown <= 0;
		conv_col <= 0;
		conv_row <= 0;
 	elsif (store='1') then 
 		 	if (debounce_state = "000000") then
       		 	keychanged <= keychange;
				   released <= release;
				   keysdown <= next_keysdown;
			      conv_col <= conv_col_number;	
     	         conv_row <= conv_row_number;
				   if (keychange='1') then 		
						case conv_col_number is
							when 0 => row0(conv_row_number) <= previous_sample(0);
							when 1 => row1(conv_row_number) <= previous_sample(1);
							when 2 => row2(conv_row_number) <= previous_sample(2);
							when 3 => row3(conv_row_number) <= previous_sample(3);
							when 4 => row4(conv_row_number) <= previous_sample(4);
							when 5 => row5(conv_row_number) <= previous_sample(5);
							when others => null;
						end case; 	 
				   end if;
			else
			   keychanged <= '0';
           	released <= '0';
  		   end if;
	else
	  keychanged <= '0';
	  released <= '0';
	end if;
	end process;

	--debouncing
	debouncer: process
	variable counter : natural range 0 to debounce_count;
	begin
	wait until rising_edge(clk);	
	if (reset = '1') then
	   debounce_state <= (others=> '0');
	   previous_sample <= (others => '0');
		counter := debounce_count;
		debounced <= '0';
	else
		if (analyse='1') then

	 		if (counter > 0 and counter < debounce_count) then
            counter := counter - 1;
	 	      debounce_state <= debounce_state or (previous_sample xor sample_col);
	 	      debounced <= '0';
	 	   end if;
	 	   
	 	 	if (counter = debounce_count) then
	 		   previous_sample <= sample_col; 
	 		   counter := counter -1 ;
	 		end if;
	 		
	 		if (counter = 0) then
	 		   debounced <= '1';
			end if; 	
		  
		else 
		   counter := debounce_count;
		   debounced <= '0';
		   debounce_state <= (others=> '0');
		end if;		
 	end if;
	end process;
	

end Analyser_arc;   
    
