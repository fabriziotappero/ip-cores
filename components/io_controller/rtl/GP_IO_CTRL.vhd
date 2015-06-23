-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #        General Purpose 32-bit IO Controller        #
-- # ************************************************** #
-- # Last modified: 20.02.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GP_IO_CTRL is
	port (
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- memory master clock
				WB_RST_I      : in  STD_LOGIC; -- high active sync reset
				WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_ADR_I      : in  STD_LOGIC; -- adr in
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
				WB_WE_I       : in  STD_LOGIC; -- write enable
				WB_STB_I      : in  STD_LOGIC; -- valid cycle
				WB_ACK_O      : out STD_LOGIC; -- acknowledge
				WB_HALT_O     : out STD_LOGIC; -- throttle master
				WB_ERR_O      : out STD_LOGIC; -- abnormal termination

				-- IO Port --
				GP_IO_O       : out STD_LOGIC_VECTOR(31 downto 00);
				GP_IO_I       : in  STD_LOGIC_VECTOR(31 downto 00);

				-- Input Change INT --
				IO_IRQ_O      : out STD_LOGIC
	     );
end GP_IO_CTRL;

architecture Structure of GP_IO_CTRL is

	-- Input / Output Sync Register --
	signal IO_I_SYNC, IO_O_SYNC, IRQ_SYNC : STD_LOGIC_VECTOR(31 downto 0);

	-- internal Buffer --
	signal WB_ACK_O_INT : STD_LOGIC;
	
	-- Memory Map (word boundary)
	-- ADR_I = 0 : Access to OUTPUT register
	-- ADR_I = 1 : Access to INPUT register

begin

	-- Wishbone Input Interface ----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_W_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					IO_O_SYNC <= (others => '0');
				elsif (WB_STB_I = '1') and (WB_WE_I = '1') and (WB_ADR_I = '0') then -- valid write access
					for i in 0 to 3 loop
						if (WB_SEL_I(i) = '1') then
							IO_O_SYNC(8*i+7 downto 8*i) <= WB_DATA_I(8*i+7 downto 8*i);
						end if;
					end loop;
				end if;
			end if;	
		end process WB_W_ACCESS;

		--- Out-Port ---
		GP_IO_O <= IO_O_SYNC;



	-- Wishbone Output Interface ---------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_R_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					WB_DATA_O    <= (others => '0');
					WB_ACK_O_INT <= '0';
				else
					--- Data Output ---
					if (WB_STB_I = '1') and (WB_WE_I = '0') then -- valid read request
						if (WB_ADR_I = '0') then
							WB_DATA_O <= IO_O_SYNC;
						else
							WB_DATA_O <= IO_I_SYNC;
						end if;
					else
						WB_DATA_O <= (others => '0');
					end if;

					--- ACK Control ---
					if (WB_CTI_I = "000") or (WB_CTI_I = "111") then
						WB_ACK_O_INT <= WB_STB_I and (not WB_ACK_O_INT);
					else
						WB_ACK_O_INT <= WB_STB_I; -- data is valid one cycle later
					end if;
				end if;
			end if;
		end process WB_R_ACCESS;

		--- ACK Signal ---
		WB_ACK_O  <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!

		--- Error ---
		WB_ERR_O  <= '0'; -- nothing can go wrong ;)



	-- Synchronize Input -------------------------------------------------
	-- ----------------------------------------------------------------------
		SYNC_INPUT: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					IO_I_SYNC <= (others => '0');
					IRQ_SYNC  <= (others => '0');
				else
					IO_I_SYNC <= GP_IO_I;
					IRQ_SYNC  <= IO_I_SYNC;
				end if;
			end if;
		end process SYNC_INPUT;



	-- Input Change IRQ --------------------------------------------------
	-- ----------------------------------------------------------------------
		INPUT_CHANGE_IRQ: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					IO_IRQ_O <= '0';
				else
					if (IRQ_SYNC /= IO_I_SYNC) then
						IO_IRQ_O <= '1';
					else
						IO_IRQ_O <= '0';
					end if;
				end if;
			end if;
		end process INPUT_CHANGE_IRQ;



end Structure;