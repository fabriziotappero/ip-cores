-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #            Vector Interrupt Controller             #
-- #         with active component acknowledge          #
-- # ************************************************** #
-- # Last modified: 15.03.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity VIC is
	port (
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- memory master clock
				WB_RST_I      : in  STD_LOGIC; -- high active sync reset
				WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_ADR_I      : in  STD_LOGIC_VECTOR(05 downto 0); -- adr in (word boundary)
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
				WB_WE_I       : in  STD_LOGIC; -- write enable
				WB_STB_I      : in  STD_LOGIC; -- valid cycle
				WB_ACK_O      : out STD_LOGIC; -- acknowledge
				WB_HALT_O     : out STD_LOGIC; -- throttle master
				WB_ERR_O      : out STD_LOGIC; -- abnormal termination

				-- INT Lines & ACK --
				IRQ_LINES_I   : in  STD_LOGIC_VECTOR(31 downto 0);
				ACK_LINES_O   : out STD_LOGIC_VECTOR(31 downto 0);

				-- Global FIQ/IRQ signal to STORM --
				STORM_IRQ_O   : out STD_LOGIC;
				STORM_FIQ_O   : out STD_LOGIC
	     );
end VIC;

architecture Structure of VIC is

	-- Local signals --
	signal SYNC_A,  SYNC_B  : STD_LOGIC_VECTOR(31 downto 0); -- edgde detector
	signal FIQ_ACK, IRQ_ACK : STD_LOGIC_VECTOR(31 downto 0); -- pending IRQ/FIQ acks
	signal IRQ_TRIGGER      : STD_LOGIC;
	signal FIQ_TRIGGER      : STD_LOGIC;
	signal IRQ_ID           : STD_LOGIC_VECTOR(04 downto 0); -- interrupt id
	signal WB_ACK_O_INT     : STD_LOGIC; -- wb ack buffer

	-- Configuration Registers --
	type   slot_addr_type is array (15 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	type   slot_asgn_type is array (15 downto 0) of STD_LOGIC_VECTOR(05 downto 0);
	signal TRIG_LEVL   : STD_LOGIC_VECTOR(31 downto 0); -- high/low rising/falling edge
	signal TRIG_MODE   : STD_LOGIC_VECTOR(31 downto 0); -- level oder edge triggered
	signal IRQ_STATUS  : STD_LOGIC_VECTOR(31 downto 0); -- masked IRQ requests
	signal FIQ_STATUS  : STD_LOGIC_VECTOR(31 downto 0); -- masked FIQ requests
	signal INT_RAW     : STD_LOGIC_VECTOR(31 downto 0); -- unmasked INT requests
	signal SISR_ADR    : slot_addr_type; -- Slot -> ISR address register
	signal SCHN_ASN    : slot_asgn_type; -- Slot <-> channel assigment register
	signal ISR_ADR     : STD_LOGIC_VECTOR(31 downto 0); -- ISR slot address output
	signal UV_ISR_ADR  : STD_LOGIC_VECTOR(31 downto 0); -- unvectorized ISR address
	signal INT_ENABLE  : STD_LOGIC_VECTOR(31 downto 0); -- interrupt lines enable
	signal SWI_ENABLE  : STD_LOGIC_VECTOR(31 downto 0); -- manual interrupt lines activate
	signal INT_SELECT  : STD_LOGIC_VECTOR(31 downto 0); -- interrupt lines IRQ/FIQ select
	signal VIC_PROTEC  : STD_LOGIC; -- protected access config

begin

	-- Interrupt Detector ----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INT_DETECT: process(WB_CLK_I)
		begin
			--- Edge Detector ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					SYNC_B <= (others => '0');
					SYNC_A <= (others => '0');
				else
					SYNC_B <= SYNC_A;
					SYNC_A <= IRQ_LINES_I xor TRIG_LEVL;
				end if;
			end if;

			--- INT Trigger ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					INT_RAW    <= (others => '0');
					IRQ_STATUS <= (others => '0');
					FIQ_STATUS <= (others => '0');
				else
					for i in 0 to 31 loop
						--- Level / Edge ---
						if (TRIG_MODE(i) = '0') then -- Level triggered
							INT_RAW(i) <= SYNC_A(i) or SWI_ENABLE(i);
						else -- Edge triggered
							INT_RAW(i) <= (SYNC_A(i) and (not SYNC_B(i))) or SWI_ENABLE(i);
						end if;

						--- INT Detector ---
						if (IRQ_ACK(i) = '1') then -- IRQ acknowledge
							IRQ_STATUS(i) <= '0';
						elsif (INT_RAW(i) = '1') and (INT_ENABLE(i) = '1') and (INT_SELECT(i) = '0') then
							IRQ_STATUS(i) <= '1';
						end if;
						if (FIQ_ACK(i) = '1') then -- FIQ acknowledge
							FIQ_STATUS(i) <= '0';
						elsif (INT_RAW(i) = '1') and (INT_ENABLE(i) = '1') and (INT_SELECT(i) = '1') then
							FIQ_STATUS(i) <= '1';
						end if;
					end loop;
				end if;
			end if;
		end process INT_DETECT;



	-- IRQ Interrupt Service Address Encoder ---------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		IRQ_ISR_ENC: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					ISR_ADR <= (others => '0');
					IRQ_ID  <= (others => '0');
				elsif (IRQ_TRIGGER = '0') then
					ISR_ADR <= UV_ISR_ADR;
					IRQ_ID  <= "11111"; -- id is unimportant -> unvectorized
					for i in 0 to 15 loop
						if (SCHN_ASN(i)(5) = '1') and (IRQ_STATUS(to_integer(unsigned(SCHN_ASN(i)(4 downto 0)))) = '1') then
							ISR_ADR <= SISR_ADR(i);
							IRQ_ID  <= std_logic_vector(to_unsigned(i,5));
							exit;
						end if;
					end loop;
				end if;
			end if;
		end process IRQ_ISR_ENC;



	-- IRQ/FIQ Trigger -------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		TRIGGER: process(WB_CLK_I, WB_ADR_I, WB_STB_I, WB_WE_I, WB_TGC_I)
			variable valid_ack_v : std_logic;
		begin
			--- Global ACK ---
			valid_ack_v := '0';
			if (WB_STB_I = '1') and (WB_WE_I = '1') and (WB_ADR_I = "001100") then -- access to x"030"
				valid_ack_v := '1';
			end if;

			--- Sync Update ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					IRQ_ACK     <= (others => '0');
					FIQ_ACK     <= (others => '0');
					IRQ_TRIGGER <= '0';
					FIQ_TRIGGER <= '0';
				else
					IRQ_ACK <= (others => '0');
					FIQ_ACK <= (others => '0');
					--- IRQ ---
					if (valid_ack_v = '1') and (WB_TGC_I(4 downto 0) = IRQ32_MODE) then
						IRQ_TRIGGER <= '0';
						if (IRQ_ID = "11111") then -- unvectorized irq
							IRQ_ACK <= IRQ_STATUS; -- clear all active IRQs
						else
							IRQ_ACK(to_integer(unsigned(IRQ_ID))) <= '1'; -- clear irq with highest priority
						end if;
					elsif (to_integer(unsigned(IRQ_STATUS)) /= 0) then
						IRQ_TRIGGER <= '1';
					end if;
					--- FIQ ---
					if (valid_ack_v = '1') and (WB_TGC_I(4 downto 0) = FIQ32_MODE) then
						FIQ_TRIGGER <= '0';
						FIQ_ACK <= FIQ_STATUS; -- clr all active FIQs
					elsif (to_integer(unsigned(FIQ_STATUS)) /= 0) then
						FIQ_TRIGGER <= '1';
					end if;
				end if;
			end if;
		end process TRIGGER;

		--- INT REQ output ---
		STORM_IRQ_O <= IRQ_TRIGGER;
		STORM_FIQ_O <= FIQ_TRIGGER;
		ACK_LINES_O <= FIQ_ACK or IRQ_ACK;



	-- Wishbone Input Interface ----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_W_ACCESS: process(WB_CLK_I, WB_STB_I, WB_WE_I, WB_TGC_I, VIC_PROTEC, WB_ADR_I)
			variable acc_adr_v  : std_logic_vector(7 downto 0);
			variable valid_we_v : std_logic;
		begin
			--- Valid write request? ---
			valid_we_v := WB_STB_I and WB_WE_I;
			if (WB_TGC_I(4 downto 0) = User32_MODE) and (VIC_PROTEC = '1') then
				valid_we_v := '0'; -- unauthorized access
			end if;

			--- Access Address ---
			acc_adr_v := WB_ADR_I & "00";

			--- Sync Update ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					INT_SELECT <= (others => '0');
					INT_ENABLE <= (others => '0');
					SWI_ENABLE <= (others => '0');
					VIC_PROTEC <= '0';
					UV_ISR_ADR <= (others => '0');
					TRIG_LEVL  <= (others => '0');
					TRIG_MODE  <= (others => '0');
					SISR_ADR   <= (others => (others => '0'));
					SCHN_ASN   <= (others => (others => '0'));
				elsif (valid_we_v = '1') then
					case (acc_adr_v) is
						when x"0C" => INT_SELECT   <= WB_DATA_I; -- VICIntSelect
						when x"10" => INT_ENABLE   <= INT_ENABLE or WB_DATA_I; -- VICIntEnable
						when x"14" => INT_ENABLE   <= INT_ENABLE and (not WB_DATA_I); -- VICIntEnClear
						when x"18" => SWI_ENABLE   <= SWI_ENABLE or WB_DATA_I;        -- VICSoftInt
						when x"1C" => SWI_ENABLE   <= SWI_ENABLE and (not WB_DATA_I); -- VICSoftIntClear
						when x"20" => VIC_PROTEC   <= WB_DATA_I(0); -- VICProtection
						when x"34" => UV_ISR_ADR   <= WB_DATA_I;    -- VICDefVectAddr
						when x"38" => TRIG_LEVL    <= WB_DATA_I;
						when x"3C" => TRIG_MODE    <= WB_DATA_I;
						when x"40" => SISR_ADR(00) <= WB_DATA_I; -- VICVectAddr0
						when x"44" => SISR_ADR(01) <= WB_DATA_I; -- VICVectAddr1
						when x"48" => SISR_ADR(02) <= WB_DATA_I; -- VICVectAddr2
						when x"4C" => SISR_ADR(03) <= WB_DATA_I; -- VICVectAddr3
						when x"50" => SISR_ADR(04) <= WB_DATA_I; -- VICVectAddr4
						when x"54" => SISR_ADR(05) <= WB_DATA_I; -- VICVectAddr5
						when x"58" => SISR_ADR(06) <= WB_DATA_I; -- VICVectAddr6
						when x"5C" => SISR_ADR(07) <= WB_DATA_I; -- VICVectAddr7
						when x"60" => SISR_ADR(08) <= WB_DATA_I; -- VICVectAddr8
						when x"64" => SISR_ADR(09) <= WB_DATA_I; -- VICVectAddr9
						when x"68" => SISR_ADR(10) <= WB_DATA_I; -- VICVectAddr10
						when x"6C" => SISR_ADR(11) <= WB_DATA_I; -- VICVectAddr11
						when x"70" => SISR_ADR(12) <= WB_DATA_I; -- VICVectAddr12
						when x"74" => SISR_ADR(13) <= WB_DATA_I; -- VICVectAddr13
						when x"78" => SISR_ADR(14) <= WB_DATA_I; -- VICVectAddr14
						when x"7C" => SISR_ADR(15) <= WB_DATA_I; -- VICVectAddr15
						when x"80" => SCHN_ASN(00) <= WB_DATA_I(05 downto 0); -- VICVectCntl0
						when x"84" => SCHN_ASN(01) <= WB_DATA_I(05 downto 0); -- VICVectCntl1
						when x"88" => SCHN_ASN(02) <= WB_DATA_I(05 downto 0); -- VICVectCntl2
						when x"8C" => SCHN_ASN(03) <= WB_DATA_I(05 downto 0); -- VICVectCntl3
						when x"90" => SCHN_ASN(04) <= WB_DATA_I(05 downto 0); -- VICVectCntl4
						when x"94" => SCHN_ASN(05) <= WB_DATA_I(05 downto 0); -- VICVectCntl5
						when x"98" => SCHN_ASN(06) <= WB_DATA_I(05 downto 0); -- VICVectCntl6
						when x"9C" => SCHN_ASN(07) <= WB_DATA_I(05 downto 0); -- VICVectCntl7
						when x"A0" => SCHN_ASN(08) <= WB_DATA_I(05 downto 0); -- VICVectCntl8
						when x"A4" => SCHN_ASN(09) <= WB_DATA_I(05 downto 0); -- VICVectCntl9
						when x"A8" => SCHN_ASN(10) <= WB_DATA_I(05 downto 0); -- VICVectCntl10
						when x"AC" => SCHN_ASN(11) <= WB_DATA_I(05 downto 0); -- VICVectCntl11
						when x"B0" => SCHN_ASN(12) <= WB_DATA_I(05 downto 0); -- VICVectCntl12
						when x"B4" => SCHN_ASN(13) <= WB_DATA_I(05 downto 0); -- VICVectCntl13
						when x"B8" => SCHN_ASN(14) <= WB_DATA_I(05 downto 0); -- VICVectCntl14
						when x"BC" => SCHN_ASN(15) <= WB_DATA_I(05 downto 0); -- VICVectCntl15
						when others => NULL;
					end case;
				end if;
			end if;	
		end process WB_W_ACCESS;



	-- Wishbone Output Interface ---------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_R_ACCESS: process(WB_CLK_I, WB_ADR_I)
			variable acc_adr_v : std_logic_vector(7 downto 0);
		begin
			--- Access Address ---
			acc_adr_v := WB_ADR_I & "00";

			--- Sync Output ---
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					WB_DATA_O    <= (others => '0');
					WB_ACK_O_INT <= '0';
					WB_ERR_O     <= '0';
				else
					--- Data Output ---
					if (WB_STB_I = '1') and (WB_WE_I = '0') then -- valid read request
						case (acc_adr_v) is
							when x"00" => WB_DATA_O <= IRQ_STATUS; -- VICIRQStatus
							when x"04" => WB_DATA_O <= FIQ_STATUS; -- VICFIQStatus
							when x"08" => WB_DATA_O <= INT_RAW;    -- VICRawIntr
							when x"0C" => WB_DATA_O <= INT_SELECT; -- VICIntSelect
							when x"10" => WB_DATA_O <= INT_ENABLE; -- VICIntEnable
							when x"18" => WB_DATA_O <= SWI_ENABLE; -- VICSoftInt
							when x"20" => WB_DATA_O <= x"0000000" & "000" & VIC_PROTEC; -- VICProtection
							when x"30" => WB_DATA_O <= ISR_ADR;    -- VICVectAddr
							when x"34" => WB_DATA_O <= UV_ISR_ADR; -- VICDefVectAddr
							when x"38" => WB_DATA_O <= TRIG_LEVL;
							when x"3C" => WB_DATA_O <= TRIG_MODE;
							when x"40" => WB_DATA_O <= SISR_ADR(00); -- VICVectAddr0
							when x"44" => WB_DATA_O <= SISR_ADR(01); -- VICVectAddr1
							when x"48" => WB_DATA_O <= SISR_ADR(02); -- VICVectAddr2
							when x"4C" => WB_DATA_O <= SISR_ADR(03); -- VICVectAddr3
							when x"50" => WB_DATA_O <= SISR_ADR(04); -- VICVectAddr4
							when x"54" => WB_DATA_O <= SISR_ADR(05); -- VICVectAddr5
							when x"58" => WB_DATA_O <= SISR_ADR(06); -- VICVectAddr6
							when x"5C" => WB_DATA_O <= SISR_ADR(07); -- VICVectAddr7
							when x"60" => WB_DATA_O <= SISR_ADR(08); -- VICVectAddr8
							when x"64" => WB_DATA_O <= SISR_ADR(09); -- VICVectAddr9
							when x"68" => WB_DATA_O <= SISR_ADR(10); -- VICVectAddr10
							when x"6C" => WB_DATA_O <= SISR_ADR(11); -- VICVectAddr11
							when x"70" => WB_DATA_O <= SISR_ADR(12); -- VICVectAddr12
							when x"74" => WB_DATA_O <= SISR_ADR(13); -- VICVectAddr13
							when x"78" => WB_DATA_O <= SISR_ADR(14); -- VICVectAddr14
							when x"7C" => WB_DATA_O <= SISR_ADR(15); -- VICVectAddr15
							when x"80" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(00); -- VICVectCntl0
							when x"84" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(01); -- VICVectCntl1
							when x"88" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(02); -- VICVectCntl2
							when x"8C" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(03); -- VICVectCntl3
							when x"90" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(04); -- VICVectCntl4
							when x"94" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(05); -- VICVectCntl5
							when x"98" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(06); -- VICVectCntl6
							when x"9C" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(07); -- VICVectCntl7
							when x"A0" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(08); -- VICVectCntl8
							when x"A4" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(09); -- VICVectCntl9
							when x"A8" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(10); -- VICVectCntl10
							when x"AC" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(11); -- VICVectCntl11
							when x"B0" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(12); -- VICVectCntl12
							when x"B4" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(13); -- VICVectCntl13
							when x"B8" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(14); -- VICVectCntl14
							when x"BC" => WB_DATA_O <= x"000000" & "00" & SCHN_ASN(15); -- VICVectCntl15
							when others => WB_DATA_O <= (others => '0');
						end case;
					else
						WB_DATA_O <= (others => '0');
					end if;

					--- ACK Control ---
					if (WB_CTI_I = "000") or (WB_CTI_I = "111") then
						WB_ACK_O_INT <= WB_STB_I and (not WB_ACK_O_INT);
					else
						WB_ACK_O_INT <= WB_STB_I; -- data is valid one cycle later
					end if;

					--- Unauthorized Access Error ---
					WB_ERR_O <= '0';
					if (WB_STB_I = '1') and (VIC_PROTEC = '1') and (WB_TGC_I(4 downto 0) = User32_MODE) then
						WB_ERR_O <= '1';
					end if;
				end if;
			end if;
		end process WB_R_ACCESS;

		--- ACK Signal ---
		WB_ACK_O <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!



end Structure;