----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       Aart Mulder
-- 
-- Create Date:    11:55:02 05/22/2011 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
-- Project Name:   VHDL course
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MyRAM is
	Generic (
		DATA_WIDTH_G   : integer;
		MEMORY_SIZE_G  : integer;
		MEMORY_ADDRESS_WIDTH_G : integer;
		BUFFER_OUTPUT_G : boolean := false
	);
	Port ( 
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		rd : in  STD_LOGIC;
		wr : in  STD_LOGIC;
		rd_addr : in  STD_LOGIC_VECTOR (MEMORY_ADDRESS_WIDTH_G-1 downto 0);
		wr_addr : in  STD_LOGIC_VECTOR (MEMORY_ADDRESS_WIDTH_G-1 downto 0);
		Data_in : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		Data_out : out  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0) := (others => '0')
	);
end MyRAM;

architecture Behavioral of MyRAM is
	type ram_type is array(MEMORY_SIZE_G-1 downto 0) of std_logic_vector(DATA_WIDTH_G-1 downto 0);
	signal mem : ram_type;	
--	attribute ram_style: string;
--	attribute ram_style of mem : signal is "block";

begin
	wrRAM : process(clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if wr = '1' then
					mem(TO_INTEGER(unsigned(wr_addr))) <= Data_in;
				end if;
			end if;
		end if;
	end process wrRAM;

	rdRAM : process(clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if BUFFER_OUTPUT_G then
					if rd = '1' then
						Data_out <= mem(TO_INTEGER(unsigned(rd_addr)));
					end if;
				else
					Data_out <= mem(TO_INTEGER(unsigned(rd_addr)));
				end if;
			end if;
		end if;
	end process rdRAM;
end Behavioral;

