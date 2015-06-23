-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #                Multi purpose timer                 #
-- # ************************************************** #
-- # Last modified 01.03.2012                           #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TIMER is
	port (
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- memory master clock
				WB_RST_I      : in  STD_LOGIC; -- high active sync reset
				WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_ADR_I      : in  STD_LOGIC_VECTOR(01 downto 0); -- adr in
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
				WB_WE_I       : in  STD_LOGIC; -- write enable
				WB_STB_I      : in  STD_LOGIC; -- valid cycle
				WB_ACK_O      : out STD_LOGIC; -- acknowledge
				WB_HALT_O     : out STD_LOGIC; -- throttle master
				WB_ERR_O      : out STD_LOGIC; -- abnormal termination

				-- Overflow Interrupt --
				INT_O         : out STD_LOGIC
	     );
end TIMER;

architecture Structure of TIMER is

	-- Internal Registers --
	signal COUNT_REG    : STD_LOGIC_VECTOR(31 downto 0);
	signal VALUE_REG    : STD_LOGIC_VECTOR(31 downto 0);
	signal CONFIG_REG   : STD_LOGIC_VECTOR(31 downto 0);
	signal SCRATCH_REG  : STD_LOGIC_VECTOR(31 downto 0);
	signal PRSC_REG     : STD_LOGIC_VECTOR(15 downto 0);
	signal WB_ACK_O_INT : STD_LOGIC;
	
	-- Memory Map (word boundary!!!) --
	-----------------------------------
	-- ADR_I = 00 : COUNT register
	-- ADR_I = 01 : VALUE register
	-- ADR_I = 10 : Control register
	-- ADR_I = 11 : Scratch register

	-- Config Register --
	constant TIMER_EN : natural := 0;  -- timer enable
	constant AUTO_RST : natural := 1;  -- auto reset
	constant INT_EN   : natural := 2;  -- interrupt enable
	constant PRSC_LSB : natural := 16; -- prescaler LSB
	constant PRSC_MSB : natural := 31; -- prescaler MSB

begin

	-- Timer sync config -----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		TIMER_SYNC: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					COUNT_REG   <= (others => '0');
					VALUE_REG   <= (others => '0');
					CONFIG_REG  <= (others => '0');
					SCRATCH_REG <= (others => '0');
					PRSC_REG    <= (others => '0');
				else
					-- WB write access --
					if (WB_STB_I = '1') and (WB_WE_I = '1')then
						case (WB_ADR_I) is
							when "00" => -- Counter register
								for i in 0 to 3 loop
									if (WB_SEL_I(i) = '1') then
										COUNT_REG(8*i+7 downto 8*i) <= WB_DATA_I(8*i+7 downto 8*i);
									end if;
								end loop;
							when "01" => -- Threshold register
								for i in 0 to 3 loop
									if (WB_SEL_I(i) = '1') then
										VALUE_REG(8*i+7 downto 8*i) <= WB_DATA_I(8*i+7 downto 8*i);
									end if;
								end loop;
							when "10" => -- Config register
								for i in 0 to 3 loop
									if (WB_SEL_I(i) = '1') then
										CONFIG_REG(8*i+7 downto 8*i) <= WB_DATA_I(8*i+7 downto 8*i);
									end if;
								end loop;
							when others => -- Scratch register
								for i in 0 to 3 loop
									if (WB_SEL_I(i) = '1') then
										SCRATCH_REG(8*i+7 downto 8*i) <= WB_DATA_I(8*i+7 downto 8*i);
									end if;
								end loop;
						end case;
					end if;
					
					-- Counter increment --
					if (VALUE_REG /= x"00000000") and (COUNT_REG = VALUE_REG) and (CONFIG_REG(AUTO_RST) = '1') then
						COUNT_REG <= (others => '0');
					elsif (VALUE_REG /= x"00000000") and (COUNT_REG /= VALUE_REG) and (CONFIG_REG(TIMER_EN) = '1') and (PRSC_REG = CONFIG_REG(PRSC_MSB downto PRSC_LSB)) then
						COUNT_REG <= STD_LOGIC_VECTOR(unsigned(COUNT_REG) + 1);
					end if;

					-- Prescaler increment --
					if (PRSC_REG = CONFIG_REG(PRSC_MSB downto PRSC_LSB)) then
						PRSC_REG <= (others => '0');
					elsif (VALUE_REG /= x"00000000") and (CONFIG_REG(TIMER_EN) = '1') then
						PRSC_REG <= STD_LOGIC_VECTOR(unsigned(PRSC_REG) + 1);
					end if;
				end if;
			end if;	
		end process TIMER_SYNC;



	-- Interrupt Generator ---------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INT_TOGGLE: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					INT_O <= '0';
				elsif (COUNT_REG = VALUE_REG) and (CONFIG_REG(TIMER_EN) = '1') and (CONFIG_REG(INT_EN) = '1') then
					INT_O <= '1';
				else
					INT_O <= '0';
				end if;
			end if;
		end process INT_TOGGLE;



	-- Wishbone Output Interface ---------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_R_ACCESS: process(WB_CLK_I)
		begin
			--- Sync Write ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					WB_DATA_O    <= (others => '0');
					WB_ACK_O_INT <= '0';
				else
					if (WB_STB_I = '1') and (WB_WE_I = '0') then -- valid read request
						case (WB_ADR_I) is
							when "00" => -- Counter regitser
								WB_DATA_O <= COUNT_REG;
							when "01" => -- Threshold register
								WB_DATA_O <= VALUE_REG;
							when "10" => -- Configuration register
								WB_DATA_O <= CONFIG_REG;
							when others => -- Scratch register
								WB_DATA_O <= SCRATCH_REG;
						end case;
					else
						WB_DATA_O <= (others => '0');
					end if;
				
					if (WB_CTI_I = "000") or (WB_CTI_I = "111") then
						WB_ACK_O_INT <= WB_STB_I and (not WB_ACK_O_INT);
					else
						WB_ACK_O_INT <= WB_STB_I; -- data is valid one cycle later
					end if;
				end if;
			end if;
		end process WB_R_ACCESS;

		--- ACK Signal ---
		WB_ACK_O <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!

		--- Error ---
		WB_ERR_O  <= '0'; -- nothing can go wrong ;)



end Structure;