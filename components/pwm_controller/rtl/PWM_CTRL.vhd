-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #     8 channel Pulse-Width-Modulation Controller    #
-- # ************************************************** #
-- # Last modified: 10.05.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_CTRL is
	port (
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- master clock
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

				-- PWM Port --
				PWM_O         : out STD_LOGIC_VECTOR(07 downto 0)
	     );
end PWM_CTRL;

architecture Structure of PWM_CTRL is

	-- PWM counter --
	type PWM_CNT_TYPE is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	signal PWM_CNT  : PWM_CNT_TYPE;
	signal PWM_CONF : PWM_CNT_TYPE;

	-- internal Buffer --
	signal WB_ACK_O_INT : STD_LOGIC;
	signal CLK_DIV      : STD_LOGIC_VECTOR(5 downto 0);
	signal PWM_CLK      : STD_LOGIC;
	
	-- Memory Map (word boundary)
	-- ADR_I = 0 : pwm duty-cycle config 0 = channel 3,2,1,0
	-- ADR_I = 1 : pwm duty-cycle config 1 = channel 7,6,5,4

begin

	-- Wishbone Input Interface ----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_W_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					PWM_CONF <= (others => (others => '0'));
				elsif (WB_STB_I = '1') and (WB_WE_I = '1') then -- valid write access
					if (WB_ADR_I = '0') then
						for i in 0 to 3 loop
							if (WB_SEL_I(i) = '1') then
								PWM_CONF(i) <= WB_DATA_I(8*i+7 downto 8*i+0);
							end if;
						end loop;
					else
						for i in 0 to 3 loop
							if (WB_SEL_I(i) = '1') then
								PWM_CONF(i+4) <= WB_DATA_I(8*i+7 downto 8*i+0);
							end if;
						end loop;
					end if;
				end if;
			end if;	
		end process WB_W_ACCESS;



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
							WB_DATA_O <= PWM_CONF(3) & PWM_CONF(2) & PWM_CONF(1) & PWM_CONF(0);
						else
							WB_DATA_O <= PWM_CONF(7) & PWM_CONF(6) & PWM_CONF(5) & PWM_CONF(4);
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



	-- PWM Counter -----------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CLK_DIVIDER: process(WB_RST_I, WB_CLK_I)
		begin
			if (WB_RST_I = '1') then
				CLK_DIV <= (others => '0');
			elsif rising_edge(WB_CLK_I) then -- PWM counter
				CLK_DIV <= Std_Logic_Vector(unsigned(CLK_DIV) + 1);
			end if;
		end process CLK_DIVIDER;

		-- PWM_CLK is 1/64 of WB_CLK --
		PWM_CLK <= CLK_DIV(5);



	-- PWM Counter -----------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		PWM_COUNTER_CTRL: process(WB_RST_I, PWM_CLK)
		begin
			if (WB_RST_I = '1') then
				PWM_CNT <= (others => (others => '0'));
				PWM_O   <= (others => '0');
			elsif rising_edge(PWM_CLK) then -- PWM counter
				for i in 0 to 7 loop
					if (PWM_CONF(i) = x"00") then -- port inactive?
						PWM_O(i)   <= '0';
						PWM_CNT(i) <= (others => '0');
					elsif (PWM_CONF(i) = x"FF") then -- port always active?
						PWM_O(i)   <= '1';
						PWM_CNT(i) <= (others => '0');
					else
						PWM_CNT(i) <= Std_Logic_Vector(unsigned(PWM_CNT(i)) + 1);
						if (unsigned(PWM_CNT(i)) < unsigned(PWM_CONF(i))) then
							PWM_O(i) <= '1';
						else
							PWM_O(i) <= '0';
						end if;
					end if;
				end loop;
			end if;
		end process PWM_COUNTER_CTRL;



end Structure;