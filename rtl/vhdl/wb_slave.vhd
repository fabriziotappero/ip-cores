--
-- file: wb_slave.vhd
-- project: VGA/LCD controller
-- author: Richard Herveille
-- rev 1.0 May  10th, 2001
-- rev 1.1 June  3rd, 2001. Changed WISHBONE ADR_I. Addresses are defined as byte-oriented, instead of databus independent.
-- rev 1.2 July 15th, 2001. Added CLUT bank switching.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity wb_slave is
	port (
		CLK_I : in std_logic;
		RST_I : in std_logic;
		NRESET : in std_logic;
		ADR_I : in unsigned(4 downto 2);
		DAT_I : in std_logic_vector(31 downto 0);
		DAT_O : out std_logic_vector(31 downto 0);
		SEL_I : in std_logic_vector(3 downto 0);
		WE_I : in std_logic;
		STB_I : in std_logic;
		CYC_I : in std_logic;
		ACK_O : out std_logic;
		ERR_O : out std_logic;
		INTA_O : out std_logic;

		-- control register settings
		BL   : out std_logic;		                  -- blanking level
		CSL  : out std_logic;                    -- composite sync level
		VSL  : out std_logic;                    -- vsync level
		HSL  : out std_logic;                    -- hsync level
		PC   : out std_logic;                    -- pseudo color
 		CD   : out std_logic_vector(1 downto 0); -- color depth
		VBL  : out std_logic_vector(1 downto 0); -- burst length
		CBSW : out std_logic;                    -- clut bank switching enable
		VBSW : out std_logic;                    -- video page bank switching enable
		Ven  : out std_logic;                    -- video system enable

		-- status register inputs
		AVMP,                -- active video memory page
		ACMP : in std_logic; -- active clut page
		bsint_in,
		hint_in,
		vint_in,
		luint_in,
		sint_in : in std_logic; -- interrupt request signals

		-- Horizontal Timing Register
		Thsync : out unsigned(7 downto 0);
		Thgdel : out unsigned(7 downto 0);
		Thgate : out unsigned(15 downto 0);
		Thlen : out unsigned(15 downto 0);

		-- Vertical Timing Register
		Tvsync : out unsigned(7 downto 0);
		Tvgdel : out unsigned(7 downto 0);
		Tvgate : out unsigned(15 downto 0);
		Tvlen : out unsigned(15 downto 0);

		VBARa,
		VBARb : buffer unsigned(31 downto  2);
		CBAR  : buffer unsigned(31 downto 11)
);
end entity wb_slave;

architecture structural of wb_slave is
	signal ctrl, stat, htim, vtim, hvlen : std_logic_vector(31 downto 0);
	signal HINT, VINT, BSINT, LUINT, SINT : std_logic;
	signal HIE, VIE, BSIE : std_logic;
	signal acc, acc32, reg_acc : std_logic;
begin
	acc     <= CYC_I and STB_I;
	acc32   <= SEL_I(3) and SEL_I(2) and SEL_I(1) and SEL_I(0);
	reg_acc <= acc and acc32 and WE_I;
	ACK_O   <= acc and acc32;
	ERR_O   <= acc and not acc32;

	gen_regs: process(CLK_I, nRESET)
	begin
		if (nReset = '0') then
			ctrl  <= (others => '0');
			htim  <= (others => '0');
			vtim  <= (others => '0');
			hvlen <= (others => '0');
			VBARa <= (others => '0');
			VBARb <= (others => '0');
			CBAR  <= (others => '0');
		elsif(CLK_I'event and CLK_I = '1') then
			if (RST_I = '1') then
				ctrl  <= (others => '0');
				htim  <= (others => '0');
				vtim  <= (others => '0');
				hvlen <= (others => '0');
				VBARa <= (others => '0');
				VBARb <= (others => '0');
				CBAR  <= (others => '0');
			elsif (reg_acc = '1') then
				case ADR_I is
					when "000" => ctrl <= DAT_I;
					when "001" => null; -- status register (see gen_stat process)
					when "010" => htim <= DAT_I;
					when "011" => vtim <= DAT_I;
					when "100" => hvlen <= DAT_I;
					when "101" => VBARa <= unsigned(DAT_I(31 downto 2));
					when "110" => VBARb <= unsigned(DAT_I(31 downto 2));
					when "111" => CBAR  <= unsigned(DAT_I(31 downto 11));

					when others => null; -- should never happen
				end case;
			end if;
		end if;
	end process gen_regs;

	-- generate status register
	gen_stat: process(CLK_I, nRESET)
	begin
		if (nReset = '0') then
			stat <= (others => '0');
		elsif(CLK_I'event and CLK_I = '1') then
			if (RST_I = '1') then
				stat <= (others => '0');
			else
				stat(17) <= ACMP;
				stat(16) <= AVMP;
				stat( 6) <= bsint_in or (stat(6) and not (reg_acc and WE_I and DAT_I(6)) );
				stat( 5) <= hint_in  or (stat(5) and not (reg_acc and WE_I and DAT_I(5)) );
				stat( 4) <= vint_in  or (stat(4) and not (reg_acc and WE_I and DAT_I(4)) );
				stat( 1) <= luint_in or (stat(1) and not (reg_acc and WE_I and DAT_I(1)) );
				stat( 0) <= sint_in  or (stat(0) and not (reg_acc and WE_I and DAT_I(0)) );
			end if;
		end if;
	end process gen_stat;

	-- decode control register
	BL   <= ctrl(15);
	CSL  <= ctrl(14);
	VSL  <= ctrl(13);
	HSL  <= ctrl(12);
	PC   <= ctrl(11);
	CD   <= ctrl(10 downto 9);
	VBL  <= ctrl(8 downto 7);
	CBSW <= ctrl(5);
	VBSW <= ctrl(4);
	BSIE <= ctrl(3);
	HIE  <= ctrl(2);
	VIE  <= ctrl(1);
	Ven  <= ctrl(0);

	-- decode status register
	BSINT <= stat(6);
	HINT  <= stat(5);
	VINT  <= stat(4);
	LUINT <= stat(1);
	SINT  <= stat(0);

	-- decode Horizontal Timing Register
	Thsync <= unsigned(htim(31 downto 24));
	Thgdel <= unsigned(htim(23 downto 16));
	Thgate <= unsigned(htim(15 downto 0));
	Thlen  <= unsigned(hvlen(31 downto 16));

	-- decode Vertical Timing Register
	Tvsync <= unsigned(vtim(31 downto 24));
	Tvgdel <= unsigned(vtim(23 downto 16));
	Tvgate <= unsigned(vtim(15 downto 0));
	Tvlen  <= unsigned(hvlen(15 downto 0));

	
	-- assign output
	with ADR_I select
		DAT_O <= ctrl  when "000",
		         stat  when "001",
		         htim  when "010",
		         vtim  when "011",
		         hvlen when "100",
		         std_logic_vector(VBARa & "00") when "101",
		         std_logic_vector(VBARb & "00") when "110",
		         std_logic_vector(CBAR & ACMP & "0000000000")  when others;

	-- generate interrupt request signal
	INTA_O <= (HINT and HIE) or (VINT and VIE) or (BSINT and BSIE) or LUINT or SINT;
end architecture structural;

