-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #             Internal Memory Component              #
-- # ************************************************** #
-- # Last modified: 25.02.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEMORY is
	generic	(
				MEM_SIZE      : natural := 256;  -- memory cells
				LOG2_MEM_SIZE : natural := 8;    -- log2(memory cells)
				OUTPUT_GATE   : boolean := FALSE -- output and-gate, might be necessary for some bus systems
			);
	port	(
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- memory master clock
				WB_RST_I      : in  STD_LOGIC; -- high active sync reset
				WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_ADR_I      : in  STD_LOGIC_VECTOR(LOG2_MEM_SIZE-1 downto 0); -- adr in
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
				WB_WE_I       : in  STD_LOGIC; -- write enable
				WB_STB_I      : in  STD_LOGIC; -- valid cycle
				WB_ACK_O      : out STD_LOGIC; -- acknowledge
				WB_HALT_O     : out STD_LOGIC; -- throttle master
				WB_ERR_O      : out STD_LOGIC  -- abnormal cycle termination
			);
end MEMORY;

architecture Behavioral of MEMORY is

	--- Buffer ---
	signal WB_ACK_O_INT : STD_LOGIC;
	signal WB_DATA_INT  : STD_LOGIC_VECTOR(31 downto 0);

	--- Memory Type ---
	type MEM_FILE_TYPE is array (0 to MEM_SIZE - 1) of STD_LOGIC_VECTOR(31 downto 0);

	--- INIT MEMORY IMAGE ---
	------------------------------------------------------
	signal MEM_FILE : MEM_FILE_TYPE :=
	(
		000000 => x"E3A0F000", -- MOV PC, #0
		others => x"F0013007"  -- NOP
	);
	------------------------------------------------------

begin

	-- STORM data/instruction memory -----------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		MEM_FILE_ACCESS: process(WB_CLK_I)
		begin
			--- Sync Write ---
			if rising_edge(WB_CLK_I) then

				--- Data Read/Write ---
				if (WB_STB_I = '1') then
					if (WB_WE_I = '1') then
						MEM_FILE(to_integer(unsigned(WB_ADR_I))) <= WB_DATA_I;
					end if;
					WB_DATA_INT <= MEM_FILE(to_integer(unsigned(WB_ADR_I)));
				end if;

				--- ACK Control ---
				if (WB_RST_I = '1') then
					WB_ACK_O_INT <= '0';
				elsif (WB_CTI_I = "000") or (WB_CTI_I = "111") then
					WB_ACK_O_INT <= WB_STB_I and (not WB_ACK_O_INT);
				else
					WB_ACK_O_INT <= WB_STB_I;
				end if;

			end if;
		end process MEM_FILE_ACCESS;

		--- Output Gate ---
		WB_DATA_O <= WB_DATA_INT when (OUTPUT_GATE = FALSE) or ((OUTPUT_GATE = TRUE) and (WB_STB_I = '1')) else (others => '0');

		--- ACK Signal ---
		WB_ACK_O  <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!

		--- Error ---
		WB_ERR_O  <= '0'; -- nothing can go wrong ;)



end Behavioral;