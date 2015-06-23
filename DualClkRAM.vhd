----------------------------------------------------------------------------------
-- Company:        
-- Engineer: 	    Aart Mulder
-- 
-- Create Date:    11:42:02 12/28/2012 
-- Design Name: 
-- Module Name:    Dual clock RAM - Behavioral 
-- Project Name: 	 CCITT4
--
-- Revision: 
-- Revision 0.01 - File Created
--		             This RAM module can work with independent read
--		             and write clock.
--                 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DualClkRAM is
	Generic (
		DATA_WIDTH_G   : integer := 8;
		MEMORY_SIZE_G  : integer := 1024;
		MEMORY_ADDRESS_WIDTH_G : integer := 10
	);
	Port ( 
		wr_clk_i  : in  STD_LOGIC;
		rd_clk_i  : in  STD_LOGIC;
		wr_en_i   : in  STD_LOGIC;
		rd_en_i   : in  STD_LOGIC;
		rd_i      : in  STD_LOGIC;
		wr_i      : in  STD_LOGIC;
		rd_addr_i : in  UNSIGNED (MEMORY_ADDRESS_WIDTH_G-1 downto 0);
		wr_addr_i : in  UNSIGNED (MEMORY_ADDRESS_WIDTH_G-1 downto 0);
		d_i       : in  STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0);
		d_o       : out STD_LOGIC_VECTOR (DATA_WIDTH_G-1 downto 0)
	);
end DualClkRAM;

architecture Behavioral of DualClkRAM is
	type ram_type is array(MEMORY_SIZE_G-1 downto 0) of std_logic_vector(DATA_WIDTH_G-1 downto 0);
	signal mem : ram_type;	
	attribute ram_style: string;
	attribute ram_style of mem : signal is "block";

begin
	write_RAM_process : process(wr_clk_i)
	begin
		if wr_clk_i'event and wr_clk_i = '1' then
			if wr_en_i = '1' then
				if wr_i = '1' then
					mem(TO_INTEGER(wr_addr_i)) <= d_i;
				end if;
			end if;
		end if;
	end process write_RAM_process;

	read_RAM_process : process(rd_clk_i)
	begin
		if rd_clk_i'event and rd_clk_i = '1' then
			if rd_en_i = '1' then
				if rd_i = '1' then
					d_o <= mem(TO_INTEGER(rd_addr_i));
				end if;
			end if;
		end if;
	end process read_RAM_process;
end Behavioral;

