-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #      Seven Segment Controller for 4 displays       #
-- # ************************************************** #
-- # Last modified: 12.03.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SEVEN_SEG_CTRL is
	generic	(
				HIGH_ACTIVE_OUTPUT : boolean := FALSE
			);
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

				-- HEX-Display output --
				HEX_O         : out STD_LOGIC_VECTOR(27 downto 00)
	     );
end SEVEN_SEG_CTRL;

architecture Structure of SEVEN_SEG_CTRL is

	-- Segment Data Register --
	signal SEG_DATA     : STD_LOGIC_VECTOR(31 downto 0); -- R0 (rw): Hex value register, bits 15:0

	-- Segment Control Register --
	signal SEG_CTRL     : STD_LOGIC_VECTOR(31 downto 0); -- R1 (rw): direct hex display control, bits 27:0

	-- Internal decoded hex ctrl --
	signal HEX_DECODE   : STD_LOGIC_VECTOR(27 downto 0);
	signal OUTPUT_DATA  : STD_LOGIC_VECTOR(27 downto 0);

	-- Ack buffer --
	signal WB_ACK_O_INT : STD_LOGIC;

	-- Output select --
	signal OUTPUT_SEL   : STD_LOGIC;

begin

	-- Wishbone Write Access ----------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------
		WB_W_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					SEG_DATA    <= (others => '0');
					SEG_CTRL    <= (others => '0');
					OUTPUT_SEL  <= '1'; -- output direct control on reset to deactivate all displays
					OUTPUT_DATA <= (others => '0');
				elsif (WB_STB_I = '1') and (WB_WE_I = '1') then -- valid write access
					--- WB Write Access --
					if (WB_ADR_I = '0') then -- R0 access
						SEG_DATA   <= WB_DATA_I;
						OUTPUT_SEL <= '0';
					elsif (WB_ADR_I = '1') then -- R1 access
						SEG_CTRL   <= WB_DATA_I;
						OUTPUT_SEL <= '1';
					end if;

					--- Output Update ---
					if (OUTPUT_SEL = '0') then
						OUTPUT_DATA <= HEX_DECODE;
					else
						OUTPUT_DATA <= SEG_CTRL(27 downto 0);
					end if;
				end if;
			end if;	
		end process WB_W_ACCESS;

		--- Driver Control ---
		HEX_O <= OUTPUT_DATA when (HIGH_ACTIVE_OUTPUT = TRUE) else (not OUTPUT_DATA);



	-- Wishbone Read Access -----------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------
		WB_R_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					WB_DATA_O    <= (others => '0');
					WB_ACK_O_INT <= '0';
				else
					--- Data Read ---
					if (WB_STB_I = '1') and (WB_WE_I = '0') then
						if (WB_ADR_I = '0') then
							WB_DATA_O <= SEG_DATA;
						else
							WB_DATA_O <= SEG_CTRL;
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
		WB_ACK_O <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!

		--- Error ---
		WB_ERR_O  <= '0'; -- nothing can go wrong ;)



	-- Segment Control Decoder --------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------

		--  AAAAA      AAAAA      AAAAA     AAAAA  
		-- F     B    F     B    F     B   F     B 
		-- F     B    F     B    F     B   F     B 
		-- F     B    F     B    F     B   F     B 
		--  GGGGG      GGGGG      GGGGG     GGGGG  
		-- E     C    E     C    E     C   E     C 
		-- E     C    E     C    E     C   E     C 
		-- E     C    E     C    E     C   E     C 
		--  DDDDD      DDDDD      DDDDD     DDDDD  
		-- [27:21]    [20:14]    [13:07]   [06:00]

		SEG_DECODER: process(SEG_DATA)
			variable temp_v : STD_LOGIC_VECTOR(3 downto 0);
			variable outp_v : STD_LOGIC_VECTOR(6 downto 0);
		begin
			for i in 0 to 3 loop -- 4 x 7-segment units
				temp_v := SEG_DATA(i*4+3 downto i*4+0);
				case (temp_v) is          --| GFEDCBA |--
				    when "0000" => outp_v := "0111111"; -- 0
				    when "0001" => outp_v := "0000110"; -- 1
				    when "0010" => outp_v := "1011011"; -- 2
				    when "0011" => outp_v := "1001111"; -- 3
				    when "0100" => outp_v := "1100110"; -- 4
				    when "0101" => outp_v := "1101101"; -- 5
				    when "0110" => outp_v := "1111101"; -- 6
				    when "0111" => outp_v := "0000111"; -- 7
				    when "1000" => outp_v := "1111111"; -- 8
				    when "1010" => outp_v := "1110111"; -- 9
				    when "1001" => outp_v := "1101111"; -- A
				    when "1011" => outp_v := "1111100"; -- b
				    when "1100" => outp_v := "0111001"; -- C
				    when "1101" => outp_v := "1011110"; -- d
				    when "1110" => outp_v := "1111001"; -- E
				    when others => outp_v := "1110001"; -- F
				end case;
				HEX_DECODE(i*7+6 downto i*7+0) <= outp_v;
			end loop;
		end process SEG_DECODER;



end Structure;