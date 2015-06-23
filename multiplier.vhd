LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY multiplier IS
-- Declarations
port (CLK   	: in  std_logic;
			RESET 	: in  std_logic;
			input1  	: in  std_logic_vector(7 downto 0);
      input2  	: in  signed(7 downto 0);
      output  	: out signed(7 downto 0)
		);
END multiplier ;


ARCHITECTURE behavior OF multiplier IS

signal out_temp : signed(15 downto 0);
signal input1_buf : signed(15 downto 0);
signal part0, part1, part2, part3, part4, part5, part6, part7 : signed(15 downto 0);

begin

process(CLK, RESET)
begin
    if (RESET='1') then
    	out_temp <= (others => '0');
	  	output <= (others => '0');
	  	input1_buf <= (others => '0');
	  	part0 <= (others => '0');
	  	part1 <= (others => '0');
	  	part2 <= (others => '0');
	  	part3 <= (others => '0');
	  	part4 <= (others => '0');
	  	part5 <= (others => '0');
	  	part6 <= (others => '0');
	  	part7 <= (others => '0');
		elsif rising_edge(CLK) then
			input1_buf <= input1(7)&input1(7)&input1(7)&input1(7)&input1(7)&input1(7)&input1(7)&input1(7)&signed(input1);
			if (input2(0)='1') then
				part0 <= -(input1_buf); 
					else 
							part0 <= (others => '0');
			end if;
			if (input2(1)='1') then
				if (input2(0)='1') then
					part1 <= (others => '0');
						else
							part1 <= -(input1_buf); 
				end if;
				else
					if (input2(0)='1') then
						part1 <= input1_buf; 
							else
								part1 <= (others => '0');
					end if;
			end if;
			if (input2(2)='1') then
				if (input2(1)='1') then
					part2 <= (others => '0');
						else
							part2 <= -(input1_buf); 
				end if;
				else
					if (input2(1)='1') then
						part2 <= input1_buf; 
							else
								part2 <= (others => '0');
					end if;
			end if;
			if (input2(3)='1') then
				if (input2(2)='1') then
					part3 <= (others => '0');
						else
							part3 <= -(input1_buf); 
				end if;
				else
					if (input2(2)='1') then
						part3 <= input1_buf; 
							else
								part3 <= (others => '0');
					end if;
			end if;
			if (input2(4)='1') then
				if (input2(3)='1') then
					part4 <= (others => '0');
						else
							part4 <= -(input1_buf); 
				end if;
				else
					if (input2(3)='1') then
						part4 <= input1_buf; 
							else
								part4 <= (others => '0');
					end if;
			end if;
			if (input2(5)='1') then
				if (input2(4)='1') then
					part5 <= (others => '0');
						else
							part5 <= -(input1_buf); 
				end if;
				else
					if (input2(4)='1') then
						part5 <= input1_buf; 
							else
								part5 <= (others => '0');
					end if;
			end if;
			if (input2(6)='1') then
				if (input2(5)='1') then
					part6 <= (others => '0');
						else
							part6 <= -(input1_buf); 
				end if;
				else
					if (input2(5)='1') then
						part6 <= input1_buf; 
							else
								part6 <= (others => '0');
					end if;
			end if;
			if (input2(7)='1') then
				if (input2(6)='1') then
					part7 <= (others => '0');
						else
							part7 <= -(input1_buf); 
				end if;
				else
					if (input2(6)='1') then
						part7 <= input1_buf; 
							else
								part7 <= (others => '0');
					end if;
			end if;
		out_temp <= part0+(part1(14 downto 0)&'0')+(part2(13 downto 0)&"00")+(part3(12 downto 0)&"000")+(part4(11 downto 0)&"0000")+(part5(10 downto 0)&"00000")+(part6(9 downto 0)&"000000")+(part7(8 downto 0)&"0000000");
		output <= out_temp(15 downto 8); 
end if;
end process;
END behavior;

